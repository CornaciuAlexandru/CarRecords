"""Trimiterea emailurilor: resetare parola si confirmarea adresei.

Fara SMTP configurat (SMTP_HOST gol) mesajele nu se pierd si nu dau eroare:
se scriu in backend/sent_emails.log si in consola. Asa functioneaza fluxul
complet in dezvoltare, fara cont de mail — linkul se copiaza din fisier.

Trimiterea se face din BackgroundTasks: un server SMTP lent nu trebuie sa
tina utilizatorul in asteptare, iar o eroare de retea nu trebuie sa strice
raspunsul HTTP.
"""
import smtplib
import ssl
import traceback
from datetime import datetime
from email.message import EmailMessage
from html import escape
from pathlib import Path
from typing import Optional

from app.core.config import settings
from app.core.email_texts import t

LOG_FILE = Path(__file__).resolve().parents[2] / "sent_emails.log"

# Ultimele mesaje "trimise", pentru teste si depanare. Nu inlocuieste
# fisierul de log — e doar copia din memoria procesului curent.
outbox: list = []
_OUTBOX_MAX = 50


def send_email(to: str, subject: str, html_body: str, text_body: str) -> bool:
    """Trimite un email. Nu arunca niciodata: returneaza True/False."""
    outbox.append({"to": to, "subject": subject, "text": text_body,
                   "html": html_body, "at": datetime.now()})
    del outbox[:-_OUTBOX_MAX]

    if not settings.mail_enabled:
        _write_to_log(to, subject, text_body)
        return False

    msg = EmailMessage()
    msg["From"] = settings.SMTP_FROM
    msg["To"] = to
    msg["Subject"] = subject
    msg.set_content(text_body)
    msg.add_alternative(html_body, subtype="html")

    try:
        if settings.SMTP_PORT == 465:
            with smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT,
                                  context=ssl.create_default_context(), timeout=20) as s:
                _login_and_send(s, msg)
        else:
            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=20) as s:
                if settings.SMTP_STARTTLS:
                    s.starttls(context=ssl.create_default_context())
                _login_and_send(s, msg)
        return True
    except Exception:
        # Emailul netrimis nu trebuie sa opreasca aplicatia, dar trebuie sa
        # se vada in log — altfel resetarile de parola dispar in tacere.
        print(f"[email] Trimitere esuata catre {to}: {traceback.format_exc()}")
        _write_to_log(to, subject, text_body, error=True)
        return False


def _login_and_send(server: smtplib.SMTP, msg: EmailMessage) -> None:
    if settings.SMTP_USER:
        server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
    server.send_message(msg)


def _write_to_log(to: str, subject: str, body: str, error: bool = False) -> None:
    prefix = "NETRIMIS (eroare SMTP)" if error else "NETRIMIS (SMTP neconfigurat)"
    entry = (f"\n{'=' * 70}\n{datetime.now():%Y-%m-%d %H:%M:%S}  {prefix}\n"
             f"Catre:   {to}\nSubiect: {subject}\n{'-' * 70}\n{body}\n")
    try:
        with LOG_FILE.open("a", encoding="utf-8") as f:
            f.write(entry)
    except Exception:
        pass
    print(entry)


# ── Mesajele ─────────────────────────────────────────────────────────

def send_password_reset(email: str, name: str, link: str, lang: str) -> bool:
    minutes = settings.RESET_TOKEN_EXPIRE_MINUTES
    return send_email(
        to=email,
        subject=t("resetSubject", lang),
        **_build(
            lang=lang,
            title=t("resetSubject", lang),
            greeting=t("hello", lang, name=name),
            intro=t("resetIntro", lang),
            button=t("resetButton", lang),
            link=link,
            notes=[t("resetExpiry", lang, minutes=minutes), t("resetIgnore", lang)],
        ),
    )


def send_email_verification(email: str, name: str, link: str, lang: str) -> bool:
    hours = settings.VERIFY_TOKEN_EXPIRE_HOURS
    return send_email(
        to=email,
        subject=t("verifySubject", lang),
        **_build(
            lang=lang,
            title=t("verifySubject", lang),
            greeting=t("hello", lang, name=name),
            intro=t("verifyIntro", lang),
            button=t("verifyButton", lang),
            link=link,
            notes=[t("verifyExpiry", lang, hours=hours)],
        ),
    )


def _build(lang: str, title: str, greeting: str, intro: str, button: str,
           link: str, notes: list) -> dict:
    """Varianta HTML si varianta text a aceluiasi mesaj."""
    notes_html = "".join(
        f'<p style="margin:0 0 8px;color:#6b7280;font-size:13px">{escape(n)}</p>'
        for n in notes)
    html_body = f"""<!DOCTYPE html>
<html><body style="margin:0;padding:24px;background:#f3f4f6;
 font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif">
  <div style="max-width:520px;margin:0 auto;background:#ffffff;border-radius:16px;
   overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,.1)">
    <div style="background:#1E3A5F;padding:24px;text-align:center">
      <div style="color:#ffffff;font-size:22px;font-weight:bold">CarRecords</div>
    </div>
    <div style="padding:28px">
      <h1 style="margin:0 0 16px;font-size:19px;color:#111827">{escape(title)}</h1>
      <p style="margin:0 0 12px;color:#374151;font-size:15px">{escape(greeting)}</p>
      <p style="margin:0 0 24px;color:#374151;font-size:15px">{escape(intro)}</p>
      <p style="margin:0 0 24px;text-align:center">
        <a href="{escape(link, quote=True)}" style="display:inline-block;background:#1E3A5F;
         color:#ffffff;text-decoration:none;padding:13px 26px;border-radius:10px;
         font-weight:600;font-size:15px">{escape(button)}</a>
      </p>
      {notes_html}
      <hr style="border:none;border-top:1px solid #e5e7eb;margin:20px 0">
      <p style="margin:0 0 6px;color:#9ca3af;font-size:12px">{escape(t("fallback", lang))}</p>
      <p style="margin:0 0 16px;font-size:12px;word-break:break-all">
        <a href="{escape(link, quote=True)}" style="color:#1E3A5F">{escape(link)}</a></p>
      <p style="margin:0;color:#9ca3af;font-size:12px">{escape(t("footer", lang))}</p>
    </div>
  </div>
</body></html>"""

    text_body = "\n".join([
        greeting, "", intro, "", link, "", *notes, "", t("footer", lang)])
    return {"html_body": html_body, "text_body": text_body}


def public_link(path: str, token: str, lang: Optional[str] = None) -> str:
    """Link absolut catre backend, folosit in emailuri."""
    base = settings.PUBLIC_URL.rstrip("/")
    url = f"{base}/api/v1/auth/{path}?token={token}"
    return f"{url}&lang={lang}" if lang else url
