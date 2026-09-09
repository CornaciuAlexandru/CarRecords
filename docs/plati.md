# Plăți — ce se configurează în Google Play

Codul e gata: aplicația deschide plata, serverul verifică chitanța la Google și
acordă. Ce urmează sunt lucrurile care nu se pot scrie în cod — produsele din
Play Console și cheia cu care serverul întreabă Google.

Până când amândouă există, `POST /billing/verify` răspunde **503** și niciun
cont nu urcă. Asta e intenționat: un abonament acordat fără verificare nu se
mai ia înapoi.

---

## 1. Produsele

**ID-urile trebuie să fie exact acestea.** Sunt scrise în
`backend/app/core/billing.py`; dacă diferă cu o literă, verificarea eșuează și
omul plătește fără să primească nimic.

### Abonamente
*Play Console → Monetize → Subscriptions*

| ID produs | Nume | Plan de bază | Preț |
|---|---|---|---|
| `pro_yearly` | PRO | anual, reînnoire automată | 10 EUR / an |
| `maxi_yearly` | MAXI | anual, reînnoire automată | 15 EUR / an |

### Produse consumabile
*Play Console → Monetize → In-app products*

| ID produs | Nume | Preț |
|---|---|---|
| `scans_1` | 1 scanare | 0,70 EUR |
| `scans_10` | 10 scanări | 6,00 EUR |

Ambele trebuie marcate **consumabile**: altfel nu pot fi cumpărate a doua oară.

> Prețurile se introduc pe țară. Cele de mai sus sunt referința în euro; pentru
> România pune echivalentul în lei. Aplicația afișează prețul primit de la
> magazin, nu pe cel din `/billing/catalog` — deci ce vede omul e ce se
> încasează.

---

## 2. Cheia cu care serverul verifică

Serverul întreabă Google dacă o chitanță e reală. Pentru asta are nevoie de un
cont de serviciu cu acces la Google Play Android Developer API.

1. **Google Cloud Console** → proiect nou (sau cel existent) → *IAM & Admin* →
   *Service Accounts* → creează unul.
2. La contul creat: *Keys* → *Add key* → *JSON*. Se descarcă un fișier. **Ăsta
   e secretul** — nu ajunge pe git și nu se trimite pe chat.
3. **Play Console** → *Users and permissions* → invită adresa de email a
   contului de serviciu, cu permisiunea de a vedea datele financiare și
   comenzile.
4. În Google Cloud, activează **Google Play Android Developer API** pentru
   proiect.

### Pe server

```bash
# fișierul, undeva unde nu-l vede nimeni altcineva
install -m 600 google-play.json /root/secrets/google-play.json
```

În `~/CarRecords/deploy/.env`:

```
GOOGLE_PLAY_KEY_HOST_PATH=/root/secrets/google-play.json
GOOGLE_PLAY_SERVICE_ACCOUNT_FILE=/run/secrets/google-play.json
ANDROID_PACKAGE_NAME=ro.carrecords.app
```

Prima e calea **pe server**, a doua e calea **în container**. Apoi:

```bash
cd ~/CarRecords/deploy && docker compose --env-file .env up -d
```

---

## 3. Testarea

Plățile nu se pot testa dintr-un APK instalat direct. Trebuie:

1. Aplicația urcată pe un canal de testare (internal testing e cel mai rapid).
2. Contul tău adăugat ca **license tester** în *Play Console → Setup → License
   testing*. Testerii cumpără cu carduri de test, fără să fie taxați.
3. Aplicația instalată **din Play**, cu contul de tester.

### Ce verifici

- Cumpărarea unui pachet de scanări → numărul crește în Profil.
- Cumpărarea PRO → limita de mașini urcă la 10, reclamele dispar, raportul PDF
  se generează.
- **Oprește serverul și cumpără.** Aplicația trebuie să spună că plata nu s-a
  putut confirma, iar la repornire, cu serverul pornit, cumpărarea trebuie să
  se acorde singură. Ăsta e cazul care contează: altfel omul plătește și nu
  primește nimic.
- Dezinstalează și reinstalează, apoi apasă **„Am cumpărat deja"** — abonamentul
  trebuie să revină.

---

## 4. Înainte de producție

- [ ] `ALLOW_MOCK_BILLING` nu e setat nicăieri în `.env`. Cu el pornit, orice
      cont își acordă singur MAXI. Aplicația refuză să pornească dacă îl
      găsește în producție — dar mai bine nu ajunge acolo.
- [ ] ID-urile AdMob reale, în loc de cele de test (vezi `reclame.md`).
      Publicat cu cele de test, contul poate fi suspendat.
- [ ] `SMTP_HOST` completat, altfel nimeni nu-și poate reseta parola.
