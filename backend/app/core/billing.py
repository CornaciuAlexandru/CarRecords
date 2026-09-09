"""Ce se vinde si cum se verifica la Google.

Doua reguli care nu se negociaza:

1. Ce da bani se decide pe server. Aplicatia trimite doar chitanta primita de la
   magazin; ea nu spune niciodata "acest cont e PRO".
2. Cand verificarea nu se poate face, cumpararea se respinge. Un cont care
   primeste PRO dintr-o eroare de retea nu se mai ia inapoi niciodata.
"""
import json
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

import httpx
from jose import jwt

from app.core import entitlements
from app.core.config import settings

GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
ANDROIDPUBLISHER = "https://androidpublisher.googleapis.com/androidpublisher/v3"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"

SUBSCRIPTION = "subscription"
SCANS = "scans"


@dataclass(frozen=True)
class Product:
    """Un produs din Play Console.

    `product_id` trebuie sa fie identic cu cel din Play Console. Daca difera,
    verificarea esueaza si nimeni nu primeste nimic.
    """
    product_id: str
    kind: str
    price_eur: float
    label: str
    tier: Optional[str] = None
    scans: int = 0


# Preturile sunt in euro pentru ca asa au fost stabilite. In Play Console se
# introduc separat, pe tara, iar magazinul afiseaza moneda locala - lista de
# aici e pentru ecranul din aplicatie si pentru documentatie.
CATALOG = {
    p.product_id: p
    for p in (
        Product("pro_yearly", SUBSCRIPTION, 10.00,
                "PRO - 10 masini", tier=entitlements.PRO),
        Product("maxi_yearly", SUBSCRIPTION, 15.00,
                "MAXI - 25 masini", tier=entitlements.MAXI),
        # Bucata exista pentru cine vrea exact o scanare in plus. Pachetul
        # exista pentru ca nimeni nu deschide portofelul pentru 70 de centi,
        # iar comisionul magazinului se ia si dintr-o suma mica.
        Product("scans_1", SCANS, 0.70, "1 scanare", scans=1),
        Product("scans_10", SCANS, 6.00, "10 scanari", scans=10),
    )
}


def catalog_for_client() -> list:
    """Lista pentru ecranul de planuri. Fara detalii de verificare."""
    return [
        {
            "product_id": p.product_id,
            "kind": p.kind,
            "price_eur": p.price_eur,
            "label": p.label,
            "tier": p.tier,
            "scans": p.scans,
            "max_cars": entitlements.MAX_CARS[p.tier] if p.tier else None,
        }
        for p in CATALOG.values()
    ]


# ── Verificarea la Google ────────────────────────────────────────────

class BillingUnavailable(RuntimeError):
    """Nu se poate verifica acum. Cumpararea se respinge, nu se acorda."""


_token_cache = {"value": None, "expires_at": 0.0}


def _service_account() -> dict:
    path = settings.GOOGLE_PLAY_SERVICE_ACCOUNT_FILE
    if not path or not Path(path).is_file():
        raise BillingUnavailable(
            "GOOGLE_PLAY_SERVICE_ACCOUNT_FILE lipseste sau nu e un fisier")
    return json.loads(Path(path).read_text(encoding="utf-8"))


def _access_token() -> str:
    """Token OAuth pentru androidpublisher, obtinut cu contul de serviciu.

    Se tine in memorie pana aproape de expirare: Google da tokenuri de o ora, si
    n-are rost o pereche de cereri in plus la fiecare cumparare.
    """
    now = time.time()
    if _token_cache["value"] and now < _token_cache["expires_at"]:
        return _token_cache["value"]

    sa = _service_account()
    claims = {
        "iss": sa["client_email"],
        "scope": SCOPE,
        "aud": GOOGLE_TOKEN_URL,
        "iat": int(now),
        "exp": int(now) + 3600,
    }
    assertion = jwt.encode(claims, sa["private_key"], algorithm="RS256")
    try:
        r = httpx.post(GOOGLE_TOKEN_URL, timeout=10, data={
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": assertion,
        })
        r.raise_for_status()
        data = r.json()
    except Exception as e:
        raise BillingUnavailable(f"nu am putut obtine token de la Google: {e}")

    _token_cache["value"] = data["access_token"]
    # Un minut de margine, ca sa nu folosim un token care expira intre timp.
    _token_cache["expires_at"] = now + int(data.get("expires_in", 3600)) - 60
    return _token_cache["value"]


def _get(url: str) -> dict:
    try:
        r = httpx.get(url, timeout=15,
                      headers={"Authorization": f"Bearer {_access_token()}"})
    except BillingUnavailable:
        raise
    except Exception as e:
        raise BillingUnavailable(f"Google nu a raspuns: {e}")
    if r.status_code == 404:
        # Chitanta nu exista la Google. Nu e o indisponibilitate, e o cerere
        # invalida - si trebuie sa se vada altfel.
        return {}
    if r.status_code >= 400:
        raise BillingUnavailable(f"Google a raspuns {r.status_code}: {r.text[:200]}")
    return r.json()


def verify_purchase(product: Product, purchase_token: str) -> bool:
    """Chitanta e valabila si cumpararea e platita?

    Ridica BillingUnavailable daca verificarea nu se poate face. Apelantul
    respinge cumpararea - niciodata nu o acorda "pana se lamureste".
    """
    if settings.ALLOW_MOCK_BILLING:
        # Doar pentru teste. In productie variabila nu se seteaza niciodata:
        # cu ea pornita, orice sir de caractere devine o cumparare valida.
        return purchase_token.startswith("test-")

    pkg = settings.ANDROID_PACKAGE_NAME
    if product.kind == SUBSCRIPTION:
        data = _get(f"{ANDROIDPUBLISHER}/applications/{pkg}"
                    f"/purchases/subscriptionsv2/tokens/{purchase_token}")
        state = data.get("subscriptionState")
        # Perioada de gratie inseamna ca plata a esuat dar abonamentul e inca
        # activ. Taierea accesului acolo ar pedepsi un card expirat.
        return state in ("SUBSCRIPTION_STATE_ACTIVE",
                         "SUBSCRIPTION_STATE_IN_GRACE_PERIOD")

    data = _get(f"{ANDROIDPUBLISHER}/applications/{pkg}"
                f"/purchases/products/{product.product_id}/tokens/{purchase_token}")
    # 0 = cumparat, 1 = anulat, 2 = in asteptare.
    return data.get("purchaseState") == 0
