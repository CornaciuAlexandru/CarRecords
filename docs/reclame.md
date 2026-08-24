# Reclame (Google AdMob)

Aplicația afișează reclame **doar pe Android și iOS**. Pe Windows pachetul
AdMob nu are implementare, iar codul se dezactivează singur — bannerul
randează un widget gol, deci nu ocupă spațiu.

## Ce este implementat

| Element | Unde apare |
|---|---|
| **Banner** | Jos, pe ecranele de listare (mașini, roviniete, asigurări, talon, service, modificări, notificări) |
| **Reclamă pe tot ecranul** | După salvarea unui document — dar **doar la fiecare a 4-a salvare**, nu de fiecare dată |
| **Consimțământ GDPR** | La prima pornire, prin formularul oficial Google (UMP) |
| **Opțiuni de confidențialitate** | Profil → *Opțiuni de confidențialitate*, ca utilizatorul să-și poată schimba alegerea |

Bannerul nu apare pe ecranele de formular sau în timpul scanării — acolo ar
distrage exact când utilizatorul completează date.

---

## ⚠️ Acum se folosesc ID-uri de TEST

Implicit sunt ID-urile de test oficiale Google. Sunt sigure în dezvoltare,
dar **nu generează venit**.

> **Nu publica aplicația cu ID-uri de test și nu apăsa niciodată pe reclame
> reale de pe propriul dispozitiv.** Google suspendă conturile pentru
> clicuri invalide, iar suspendarea e greu de contestat.

---

## Pașii pentru reclame reale

### 1. Cont AdMob
[admob.google.com](https://admob.google.com) → înregistrare (gratuit, ai
nevoie de un cont Google și de date de plată pentru încasări).

### 2. Adaugă aplicația
**Apps → Add app → Android →** „Aplicația mea nu e încă în magazin"
(o poți lega de Play Store mai târziu).

Primești un **App ID**, de forma `ca-app-pub-XXXXXXXX~YYYYYYYY`.

### 3. Creează unitățile de reclamă
**Ad units → Add ad unit**, de două ori:
- una de tip **Banner** → numește-o `CarRecords Banner`
- una de tip **Interstitial** → `CarRecords Interstitial`

Fiecare îți dă un ID de forma `ca-app-pub-XXXXXXXX/ZZZZZZZZ`.

### 4. Pune App ID în manifest
În `frontend/car_manager/android/app/src/main/AndroidManifest.xml`,
înlocuiește valoarea de test:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXX~YYYYYYYY" />
```

> Dacă pui un App ID greșit, aplicația **se închide la pornire**. E cea mai
> frecventă greșeală la prima integrare.

### 5. Compilează cu ID-urile reale

```bash
flutter build apk --release \
  --dart-define=ADMOB_BANNER=ca-app-pub-XXXXXXXX/1111111111 \
  --dart-define=ADMOB_INTERSTITIAL=ca-app-pub-XXXXXXXX/2222222222
```

### 6. Completează „Data safety" în Play Console
Reclamele colectează identificatorul de publicitate. În Play Console →
**App content → Data safety**, declară:
- *Device or other IDs* → colectat, partajat cu terți, pentru publicitate

Politica de confidențialitate de pe site descrie deja acest lucru.

---

## Dezactivarea completă a reclamelor

```bash
flutter build apk --release --dart-define=ADS_ENABLED=false
```

Util pentru o eventuală versiune plătită sau pentru testare.

---

## Reglarea frecvenței

În `lib/core/services/ads_service.dart`:

```dart
static const _actionsBetweenInterstitials = 4;
```

Cu cât numărul e mai mic, cu atât reclamele apar mai des — și cu atât mai
mulți utilizatori dezinstalează aplicația. 4 este un compromis rezonabil;
sub 3 devine agresiv.
