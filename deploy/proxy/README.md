# Proxy comun

Un singur Caddy pentru toate aplicațiile de pe server: termină TLS, obține și
reînnoiește certificatele, și trimite fiecare cerere către aplicația potrivită.

## De ce există

Fiecare aplicație venea cu propriul Caddy, care cerea porturile 80 și 443. Pe
un server cu două aplicații, a doua nu mai pornește — porturile sunt deja
luate. Nu e o problemă de configurare, ci una structurală: **o singură mașină
are o singură ușă din față.**

Stivele aplicațiilor nu mai publică porturi. Se conectează la rețeaua Docker
`web`, iar Caddy le găsește după numele serviciului: `backend` pentru
CarRecords, `api` pentru DriveChat.

Locul lui în repo-ul CarRecords e o comoditate, nu o apartenență: proxy-ul
servește întreaga mașină. Dacă muți vreodată aplicațiile pe servere separate,
fiecare stivă își poate lua înapoi propriul Caddy.

## Pornire

```bash
docker network create web        # o singură dată pe server
cp .env.example .env && nano .env
docker compose --env-file .env up -d
```

Înainte de prima pornire, validează configurația. O greșeală de sintaxă lasă
Caddy în repornire continuă, iar atunci **toate** aplicațiile sunt căzute, nu
doar cea greșită:

```bash
docker compose run --rm caddy caddy validate --config /etc/caddy/Caddyfile
```

## Înainte să pornești

Fiecare domeniu din `Caddyfile` trebuie să aibă deja o înregistrare A către
IP-ul acestui server. Caddy cere certificatul la prima pornire, iar dacă DNS-ul
nu e propagat, cererea eșuează și se reia — până la limita săptămânală impusă
de Let's Encrypt.

```bash
for h in carrecords.ro www.carrecords.ro api.carrecords.ro drivechat.carrecords.ro; do
  echo -n "$h "; dig +short $h
done
```

## Operare

```bash
docker compose logs -f caddy                 # inclusiv emiterea certificatelor
docker compose restart caddy                 # după o modificare în Caddyfile
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
```

**Nu folosi `docker compose down -v`.** Ar șterge volumul cu certificatele, iar
Let's Encrypt limitează câte poți cere pe săptămână. Fără ele, toate
aplicațiile rămân fără HTTPS până se ridică limita.

## Cum adaugi o aplicație nouă

1. În stiva aplicației: scoate serviciul `caddy`, scoate `ports`, adaugă
   serviciul pe rețeaua `web` (păstrând `default` pentru baza de date).
2. Aici: un bloc nou în `Caddyfile` cu domeniul și `reverse_proxy <serviciu>:<port>`.
3. Un A record către server, apoi `docker compose restart caddy`.
