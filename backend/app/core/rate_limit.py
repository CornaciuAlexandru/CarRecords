"""Limitare de rata, in memoria procesului.

Doua feluri de folosire:

* `check()` — numara fiecare cerere. Potrivit pentru endpointurile care
  trimit emailuri: fara ele, oricine poate cere la nesfarsit resetari de
  parola pentru adresa altcuiva (spam catre victima si consum de cota SMTP).
* `guard()` + `record()` + `reset()` — numara doar esecurile. Potrivit pentru
  autentificare: cine isi greseste parola de doua ori si apoi nimereste nu
  trebuie sa ramana cu contorul incarcat.

Limitele se tin intr-un dictionar, deci sunt valabile per proces. Cu un
singur uvicorn (cazul de acum, si local si pe VPS) e suficient; daca vreodata
rulam mai multe workere, contorul trebuie mutat in Redis.
"""
import time
from collections import defaultdict
from typing import Dict, List

from fastapi import HTTPException, Request, status

_hits: Dict[str, List[float]] = defaultdict(list)


def check(key: str, limit: int, window_seconds: int) -> None:
    """Inregistreaza o incercare si arunca 429 daca s-a depasit limita."""
    guard(key, limit, window_seconds)
    record(key)


def guard(key: str, limit: int, window_seconds: int) -> None:
    """Arunca 429 daca s-a depasit limita, fara sa inregistreze nimic."""
    recent = _recent(key, window_seconds)
    if len(recent) >= limit:
        retry_after = int(window_seconds - (time.time() - recent[0])) + 1
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Prea multe incercari. Reincearca mai tarziu.",
            headers={"Retry-After": str(max(retry_after, 1))},
        )


def record(key: str) -> None:
    """Inregistreaza o incercare pe cheia data."""
    _hits[key].append(time.time())


def reset(key: str) -> None:
    """Sterge contorul unei chei (dupa o autentificare reusita)."""
    _hits.pop(key, None)


def _recent(key: str, window_seconds: int) -> List[float]:
    """Incercarile din fereastra curenta, cu cele vechi uitate."""
    now = time.time()
    recent = [t for t in _hits.get(key, []) if now - t < window_seconds]
    if recent:
        _hits[key] = recent
    else:
        _hits.pop(key, None)
    return recent


def client_ip(request: Request) -> str:
    """IP-ul clientului, tinand cont de reverse proxy (Caddy/nginx in cloud)."""
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def clear() -> None:
    """Goleste contoarele (folosit in teste)."""
    _hits.clear()
