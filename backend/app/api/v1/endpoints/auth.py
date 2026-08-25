import json
from datetime import timedelta
from html import escape
from typing import Optional

from fastapi import (APIRouter, BackgroundTasks, Depends, Header, HTTPException,
                     Query, Request, status)
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session

from app.core import rate_limit
from app.core.database import get_db
from app.core.deps import get_current_user
from app.core.email import public_link, send_email_verification, send_password_reset
from app.core.email_texts import normalize_lang, t
from app.core.config import settings
from app.core.security import (generate_email_token, hash_email_token, hash_password,
                               issue_tokens, decode_token, utcnow, verify_password)
from app.models.email_token import EmailToken
from app.models.user import User
from app.schemas.user import (AccountDeleteRequest, EmailTokenRequest,
                              ForgotPasswordRequest, RefreshRequest,
                              ResendVerificationRequest,
                              ResetPasswordRequest, TokenResponse, UserCreate,
                              UserLogin, UserOut, UserPasswordChange, UserUpdate)
from app.utils.file_handler import delete_user_files

router = APIRouter(prefix="/auth", tags=["Autentificare"])


# ── Ajutoare ─────────────────────────────────────────────────────────

def _tokens_for(user: User) -> TokenResponse:
    access, refresh = issue_tokens(user)
    return TokenResponse(access_token=access, refresh_token=refresh,
                         user=UserOut.model_validate(user))


def _pick_lang(requested: Optional[str], accept_language: Optional[str]) -> str:
    """Limba emailului: cea trimisa de aplicatie, altfel cea a browserului."""
    return normalize_lang(requested or accept_language or "")


def _new_email_token(db: Session, user: User, purpose: str) -> str:
    """Creeaza un token de email si il anuleaza pe cel anterior de acelasi fel.

    Un singur link activ la un moment dat: daca ai cerut doua resetari,
    functioneaza doar ultima.
    """
    (db.query(EmailToken)
       .filter(EmailToken.user_id == user.id,
               EmailToken.purpose == purpose,
               EmailToken.used_at.is_(None))
       .update({"used_at": utcnow()}, synchronize_session=False))

    lifetime = (timedelta(minutes=settings.RESET_TOKEN_EXPIRE_MINUTES)
                if purpose == "reset"
                else timedelta(hours=settings.VERIFY_TOKEN_EXPIRE_HOURS))

    raw, token_hash = generate_email_token()
    db.add(EmailToken(user_id=user.id, token_hash=token_hash, purpose=purpose,
                      expires_at=utcnow() + lifetime))
    db.commit()
    return raw


def _consume_email_token(db: Session, raw: str, purpose: str) -> Optional[User]:
    """Valideaza un token si il marcheaza folosit. None daca nu e bun."""
    if not raw:
        return None
    record = (db.query(EmailToken)
                .filter(EmailToken.token_hash == hash_email_token(raw),
                        EmailToken.purpose == purpose)
                .first())
    if not record or not record.is_usable:
        return None

    user = db.query(User).filter(User.id == record.user_id).first()
    if not user:
        return None

    record.used_at = utcnow()
    return user


def _send_verification(background: BackgroundTasks, db: Session, user: User, lang: str) -> None:
    raw = _new_email_token(db, user, "verify")
    background.add_task(send_email_verification, user.email, user.full_name,
                        public_link("verify-email", raw, lang), lang)


# ── Cont ─────────────────────────────────────────────────────────────

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(
    data: UserCreate,
    background: BackgroundTasks,
    request: Request,
    db: Session = Depends(get_db),
    accept_language: Optional[str] = Header(None),
):
    """Cont nou, cu doua contoare pe adresa IP.

    Unul numara conturile chiar create — fara el, cineva poate fabrica
    conturi in lant, fiecare trimitand un email de confirmare catre o adresa
    care nu i-a cerut nimic. Celalalt numara orice cerere, inclusiv cele
    respinse: raspunsul "Email deja inregistrat" spune altfel oricui, la
    nesfarsit, care adrese au cont.

    Cererile respinse nu consuma din contorul de conturi: cine se impiedica
    de o adresa deja folosita trebuie sa poata incerca cu alta.
    """
    ip = rate_limit.client_ip(request)
    window = settings.REGISTER_WINDOW_MINUTES * 60
    created_key = f"register-new:{ip}"

    rate_limit.check(f"register-ip:{ip}", settings.REGISTER_MAX_ATTEMPTS_PER_IP, window)
    rate_limit.guard(created_key, settings.REGISTER_MAX_ACCOUNTS_PER_IP, window)

    if db.query(User).filter(User.email == data.email).first():
        raise HTTPException(status_code=400, detail="Email deja inregistrat")

    user = User(
        email=data.email,
        password_hash=hash_password(data.password),
        full_name=data.full_name,
        phone=data.phone,
        max_cars=3,
        role="user",
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    rate_limit.record(created_key)

    _send_verification(background, db, user, _pick_lang(data.lang, accept_language))
    return _tokens_for(user)


@router.post("/login", response_model=TokenResponse)
def login(data: UserLogin, request: Request, db: Session = Depends(get_db)):
    """Autentificare, cu doua contoare impotriva incercarilor repetate.

    Unul numara orice cerere venita de la un IP, celalalt doar parolele
    gresite pentru o anumita adresa de la acel IP. Al doilea se sterge la o
    autentificare reusita, ca greselile de tastare sa nu se adune peste zile.

    Contorul de esecuri e legat de IP + adresa, nu doar de adresa: altfel
    oricine iti stie emailul te-ar putea tine blocat afara din propriul cont.
    """
    ip = rate_limit.client_ip(request)
    window = settings.LOGIN_WINDOW_MINUTES * 60
    failures_key = f"login-fail:{ip}:{data.email}"

    rate_limit.check(f"login-ip:{ip}", settings.LOGIN_MAX_ATTEMPTS_PER_IP, window)
    rate_limit.guard(failures_key, settings.LOGIN_MAX_FAILURES, window)

    user = db.query(User).filter(User.email == data.email).first()
    if not user or not verify_password(data.password, user.password_hash):
        rate_limit.record(failures_key)
        raise HTTPException(status_code=401, detail="Email sau parola incorecta")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Contul este dezactivat")
    if settings.REQUIRE_EMAIL_VERIFICATION and not user.email_verified:
        raise HTTPException(status_code=403, detail="Adresa de email nu este confirmata")

    rate_limit.reset(failures_key)
    return _tokens_for(user)


@router.post("/refresh", response_model=TokenResponse)
def refresh_token(data: RefreshRequest, db: Session = Depends(get_db)):
    payload = decode_token(data.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Refresh token invalid")

    user = db.query(User).filter(User.id == payload["sub"], User.is_active == True).first()
    if not user:
        raise HTTPException(status_code=401, detail="Utilizator negasit")
    # Dupa o schimbare de parola, refresh tokenurile vechi nu mai merg
    if (payload.get("tv") or 0) != (user.token_version or 0):
        raise HTTPException(status_code=401, detail="Sesiune incheiata")

    return _tokens_for(user)


@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserOut)
def update_me(data: UserUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    for field, value in data.model_dump(exclude_none=True).items():
        setattr(current_user, field, value)
    db.commit()
    db.refresh(current_user)
    return current_user


@router.put("/me/password", response_model=TokenResponse)
def change_password(
    data: UserPasswordChange,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Schimba parola si incheie celelalte sesiuni.

    Raspunde cu tokenuri noi: schimbarea parolei invalideaza tot ce a fost
    emis inainte, inclusiv pentru dispozitivul de pe care se face cererea.
    """
    if not verify_password(data.current_password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="Parola curenta incorecta")

    current_user.password_hash = hash_password(data.new_password)
    current_user.token_version = (current_user.token_version or 0) + 1
    db.commit()
    db.refresh(current_user)
    return _tokens_for(current_user)


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
def delete_my_account(
    data: AccountDeleteRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Sterge definitiv contul si tot ce tine de el.

    Cerinta obligatorie Google Play. Stergerea e in cascada pe masini,
    documente si notificari; fisierele incarcate se sterg de pe disc.
    """
    if not verify_password(data.password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="Parola incorecta")

    if current_user.role == "admin":
        others = (db.query(User)
                    .filter(User.role == "admin", User.id != current_user.id)
                    .count())
        if others == 0:
            raise HTTPException(
                status_code=400,
                detail="Esti singurul administrator. Numeste alt admin inainte de stergere.")

    user_id = current_user.id
    db.delete(current_user)
    db.commit()
    delete_user_files(user_id)


# ── Resetarea parolei ────────────────────────────────────────────────

@router.post("/forgot-password", status_code=status.HTTP_204_NO_CONTENT)
def forgot_password(
    data: ForgotPasswordRequest,
    background: BackgroundTasks,
    request: Request,
    db: Session = Depends(get_db),
    accept_language: Optional[str] = Header(None),
):
    """Trimite linkul de resetare.

    Raspunde 204 si cand adresa nu exista: altfel endpointul ar spune
    oricui care adrese au cont.
    """
    rate_limit.check(f"forgot:{data.email}", limit=3, window_seconds=3600)
    rate_limit.check(f"forgot-ip:{rate_limit.client_ip(request)}", limit=10, window_seconds=3600)

    user = db.query(User).filter(User.email == data.email).first()
    if user and user.is_active:
        lang = _pick_lang(data.lang, accept_language)
        raw = _new_email_token(db, user, "reset")
        background.add_task(send_password_reset, user.email, user.full_name,
                            public_link("reset-password", raw, lang), lang)


@router.post("/reset-password", status_code=status.HTTP_204_NO_CONTENT)
def reset_password(data: ResetPasswordRequest, request: Request, db: Session = Depends(get_db)):
    """Seteaza parola noua pe baza tokenului din email."""
    rate_limit.check(f"reset-ip:{rate_limit.client_ip(request)}", limit=20, window_seconds=3600)

    user = _consume_email_token(db, data.token, "reset")
    if not user:
        raise HTTPException(status_code=400, detail="Link invalid sau expirat")

    user.password_hash = hash_password(data.new_password)
    # Cine a cerut resetarea nu mai are incredere in sesiunile existente
    user.token_version = (user.token_version or 0) + 1
    # Cine dovedeste ca are acces la casuta de email confirma implicit adresa
    if not user.email_verified:
        user.email_verified = True
        user.email_verified_at = utcnow()
    db.commit()


@router.get("/reset-password", response_class=HTMLResponse, include_in_schema=False)
def reset_password_page(
    token: str = Query(""),
    lang: str = Query(""),
    db: Session = Depends(get_db),
    accept_language: Optional[str] = Header(None),
):
    """Pagina din email, unde se scrie parola noua.

    Formularul e servit de backend ca sa functioneze din orice client de
    mail, fara sa depinda de aplicatia instalata.
    """
    lang = _pick_lang(lang, accept_language)
    record = (db.query(EmailToken)
                .filter(EmailToken.token_hash == hash_email_token(token),
                        EmailToken.purpose == "reset")
                .first())
    if not token or not record or not record.is_usable:
        return HTMLResponse(_page(lang, t("pageLinkInvalid", lang), ok=False), status_code=400)
    return HTMLResponse(_reset_form(lang, token))


# ── Confirmarea adresei de email ─────────────────────────────────────

@router.post("/verify-email", status_code=status.HTTP_200_OK)
def verify_email(data: EmailTokenRequest, db: Session = Depends(get_db)):
    user = _consume_email_token(db, data.token, "verify")
    if not user:
        raise HTTPException(status_code=400, detail="Link invalid sau expirat")
    _mark_verified(db, user)
    return {"email_verified": True}


@router.get("/verify-email", response_class=HTMLResponse, include_in_schema=False)
def verify_email_page(
    token: str = Query(""),
    lang: str = Query(""),
    db: Session = Depends(get_db),
    accept_language: Optional[str] = Header(None),
):
    """Pagina deschisa la clic pe linkul din emailul de confirmare."""
    lang = _pick_lang(lang, accept_language)
    user = _consume_email_token(db, token, "verify")
    if not user:
        return HTMLResponse(_page(lang, t("pageLinkInvalid", lang), ok=False), status_code=400)
    _mark_verified(db, user)
    return HTMLResponse(_page(lang, t("pageVerifyDone", lang)))


@router.post("/resend-verification", status_code=status.HTTP_204_NO_CONTENT)
def resend_verification(
    data: ResendVerificationRequest,
    background: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    accept_language: Optional[str] = Header(None),
):
    if current_user.email_verified:
        return
    rate_limit.check(f"verify:{current_user.id}", limit=3, window_seconds=3600)
    _send_verification(background, db, current_user, _pick_lang(data.lang, accept_language))


def _mark_verified(db: Session, user: User) -> None:
    if not user.email_verified:
        user.email_verified = True
        user.email_verified_at = utcnow()
    db.commit()


# ── Paginile HTML servite catre browser ──────────────────────────────

_STYLE = """
 body{margin:0;padding:24px;background:#f3f4f6;color:#111827;
  font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif}
 .card{max-width:420px;margin:40px auto;background:#fff;border-radius:16px;
  box-shadow:0 1px 3px rgba(0,0,0,.1);overflow:hidden}
 .head{background:#1E3A5F;color:#fff;padding:22px;text-align:center;
  font-size:21px;font-weight:700}
 .body{padding:26px}
 h1{font-size:18px;margin:0 0 18px}
 label{display:block;font-size:13px;color:#374151;margin:14px 0 6px}
 input{width:100%;box-sizing:border-box;padding:12px;border:1px solid #d1d5db;
  border-radius:10px;font-size:15px}
 button{width:100%;margin-top:20px;padding:13px;border:0;border-radius:10px;
  background:#1E3A5F;color:#fff;font-size:15px;font-weight:600;cursor:pointer}
 button[disabled]{opacity:.6;cursor:default}
 .hint{font-size:12px;color:#6b7280;margin-top:8px}
 .msg{margin-top:16px;font-size:14px}
 .err{color:#c0392b}
 .ok{color:#15803d}
"""


def _page(lang: str, message: str, ok: bool = True) -> str:
    """Pagina simpla cu un singur mesaj (confirmare sau link invalid)."""
    return f"""<!DOCTYPE html><html lang="{escape(lang)}"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>CarRecords</title><style>{_STYLE}</style></head><body>
<div class="card"><div class="head">CarRecords</div><div class="body">
<p class="msg {'ok' if ok else 'err'}">{escape(message)}</p>
</div></div></body></html>"""


def _reset_form(lang: str, token: str) -> str:
    """Formularul de parola noua, cu validare identica cu cea din API."""
    return f"""<!DOCTYPE html><html lang="{escape(lang)}"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>CarRecords</title><style>{_STYLE}</style></head><body>
<div class="card"><div class="head">CarRecords</div><div class="body">
<h1>{escape(t("pageResetTitle", lang))}</h1>
<form id="f">
  <label for="p1">{escape(t("pageNewPassword", lang))}</label>
  <input id="p1" type="password" autocomplete="new-password" required>
  <label for="p2">{escape(t("pageConfirmPassword", lang))}</label>
  <input id="p2" type="password" autocomplete="new-password" required>
  <div class="hint">{escape(t("pageRules", lang))}</div>
  <button id="b" type="submit">{escape(t("pageSubmit", lang))}</button>
</form>
<p id="m" class="msg"></p>
</div></div>
<script>
const TOKEN = {json.dumps(token)};
const MISMATCH = {json.dumps(t("pageMismatch", lang))};
const DONE = {json.dumps(t("pageResetDone", lang))};
const RULES = {json.dumps(t("pageRules", lang))};
const f = document.getElementById('f'), m = document.getElementById('m'),
      b = document.getElementById('b');
f.addEventListener('submit', async (e) => {{
  e.preventDefault();
  const p1 = document.getElementById('p1').value,
        p2 = document.getElementById('p2').value;
  m.className = 'msg err';
  if (p1 !== p2) {{ m.textContent = MISMATCH; return; }}
  if (p1.length < 8 || !/[A-Z]/.test(p1) || !/[0-9]/.test(p1)) {{
    m.textContent = RULES; return;
  }}
  b.disabled = true;
  try {{
    const r = await fetch('reset-password', {{
      method: 'POST',
      headers: {{'Content-Type': 'application/json'}},
      body: JSON.stringify({{token: TOKEN, new_password: p1}})
    }});
    if (r.status === 204) {{
      f.style.display = 'none';
      m.className = 'msg ok';
      m.textContent = DONE;
      return;
    }}
    const data = await r.json().catch(() => ({{}}));
    m.textContent = Array.isArray(data.detail)
      ? (data.detail[0] && data.detail[0].msg) || RULES
      : (data.detail || RULES);
  }} catch (err) {{
    m.textContent = String(err);
  }}
  b.disabled = false;
}});
</script></body></html>"""
