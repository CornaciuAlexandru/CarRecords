# Publicarea pe Microsoft Store

Aplicația se împachetează ca **MSIX**, formatul cerut de Store. Installer-ul
Inno Setup rămâne disponibil în paralel, pentru distribuție directă.

## Diferența dintre cele două variante

| | Installer (`.exe`) | Pachet Store (`.msix`) |
|---|---|---|
| Distribuție | Direct, de pe site sau prin fișier | Microsoft Store |
| Actualizări | Auto-updater propriu | Gestionate de Store |
| Semnare | Nesemnat (avertisment SmartScreen) | Semnat de Microsoft |
| Instalare | Necesită acceptarea avertismentului | Un clic |

Pachetul MSIX se construiește cu `--dart-define=STORE_BUILD=true`, ceea ce
**dezactivează auto-updater-ul propriu** — un updater care descarcă și
rulează executabile duce la respingerea aplicației din Store.

Ambele se generează automat: `python release.py <versiune> "<changelog>"`.

---

## Pașii pentru publicare

### 1. Cont de dezvoltator

[partner.microsoft.com](https://partner.microsoft.com/dashboard) →
**Windows & Xbox** → înregistrare.

Cost: **~19 $, o singură dată** (cont individual). Verificarea identității
poate dura câteva zile.

### 2. Rezervă numele aplicației

**Apps and games → New product → MSIX or PWA app** → introdu `CarRecords`.

Dacă numele e liber, îl rezervi pe loc.

### 3. Ia identitatea produsului

În produsul nou creat: **Product management → Product identity**.

Vei găsi trei valori:

```
Package/Identity/Name          →  12345Nume.CarRecords
Package/Identity/Publisher     →  CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Package/Properties/PublisherDisplayName  →  Numele tău de dezvoltator
```

### 4. Pune-le în `pubspec.yaml`

Secțiunea `msix_config` — înlocuiește valorile provizorii:

```yaml
msix_config:
  identity_name: 12345Nume.CarRecords
  publisher: CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
  publisher_display_name: Numele tău de dezvoltator
```

> Dacă acestea nu se potrivesc exact cu cele din Partner Center, pachetul
> este **respins la încărcare**. E cea mai frecventă cauză de eșec.

### 5. Construiește pachetul

```bash
python release.py 1.0.20 "Descrierea modificărilor"
```

Rezultă `CarRecords_v1.0.20.msix` în rădăcina proiectului.

Sau doar pachetul MSIX:
```bash
cd frontend/car_manager
flutter build windows --release --dart-define=STORE_BUILD=true
dart run msix:create
```

### 6. Încarcă și completează listarea

**Submissions → Packages** → încarcă fișierul `.msix`.

Mai ai de completat:

| Secțiune | Ce trebuie |
|---|---|
| **Pricing** | Gratuit |
| **Age ratings** | Chestionar — aplicație utilitară, fără conținut sensibil |
| **Store listing** | Descriere, minimum **1 captură de ecran** (1366×768 sau mai mare) |
| **Privacy policy URL** | `https://carrecords.ro/confidentialitate` |
| **Support contact** | `contact@carrecords.ro` |

### 7. Trimite spre certificare

Durează de obicei **24–48 de ore**. Dacă e respinsă, primești motivul exact
și poți retrimite după corectare.

---

## Ce verifică certificarea

- Aplicația pornește și nu se închide singură
- Nu descarcă și nu execută cod din exterior *(de aceea dezactivăm updater-ul)*
- Declară corect capabilitățile — noi cerem doar `internetClient`
- Are politică de confidențialitate accesibilă public

---

## Testarea locală a pachetului

Înainte de încărcare, poți instala pachetul pe calculatorul tău. Fiind
nesemnat, trebuie mai întâi activat modul dezvoltator:

**Settings → System → For developers → Developer Mode → On**

Apoi, în PowerShell ca administrator:

```powershell
Add-AppxPackage -Path "C:\Users\Alex\CarManager\CarRecords_v1.0.20.msix" -AllowUnsigned
```

Dezinstalare:
```powershell
Get-AppxPackage *CarRecords* | Remove-AppxPackage
```

---

## Reclamele nu apar în versiunea Windows

Pachetul AdMob nu are implementare pentru Windows, deci versiunea din
Microsoft Store nu conține reclame. Nu e nevoie de nicio setare — codul se
dezactivează singur pe această platformă.
