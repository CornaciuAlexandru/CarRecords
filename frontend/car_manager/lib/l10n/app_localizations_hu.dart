// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Mentés';

  @override
  String get cancel => 'Mégse';

  @override
  String get delete => 'Törlés';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get add => 'Hozzáadás';

  @override
  String get update => 'Frissítés';

  @override
  String get retry => 'Újra';

  @override
  String get error => 'Hiba';

  @override
  String errorWith(String msg) {
    return 'Hiba: $msg';
  }

  @override
  String get required => 'Kötelező';

  @override
  String get optional => 'opcionális';

  @override
  String get notes => 'Jegyzetek';

  @override
  String get notesHint => 'Megjegyzések...';

  @override
  String get chooseDate => 'Válassz dátumot';

  @override
  String get city => 'Város';

  @override
  String get cost => 'Költség (RON)';

  @override
  String get invoiceNr => 'Számlaszám';

  @override
  String get loginTitle => 'Üdv újra';

  @override
  String get loginSubtitle => 'Jelentkezz be a folytatáshoz';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Jelszó';

  @override
  String get login => 'Bejelentkezés';

  @override
  String get register => 'Fiók létrehozása';

  @override
  String get noAccount => 'Nincs fiókod? ';

  @override
  String get haveAccount => 'Van már fiókod? ';

  @override
  String get fullName => 'Teljes név';

  @override
  String get phone => 'Telefon';

  @override
  String get confirmPassword => 'Jelszó megerősítése';

  @override
  String get passwordsDoNotMatch => 'A jelszavak nem egyeznek';

  @override
  String get invalidEmail => 'Érvénytelen e-mail cím';

  @override
  String get passwordTooShort => 'Legalább 8 karakter';

  @override
  String get logout => 'Kijelentkezés';

  @override
  String get newAccount => 'Új fiók';

  @override
  String get fillDetails => 'Töltsd ki az alábbi adatokat';

  @override
  String get minChars3 => 'Legalább 3 karakter';

  @override
  String get phoneOptional => 'Telefon (opcionális)';

  @override
  String get passwordRulesHint => 'Min. 8 karakter, 1 nagybetű, 1 számjegy';

  @override
  String get passwordNeedsUpper => 'Legalább egy nagybetűt kell tartalmaznia';

  @override
  String get passwordNeedsDigit => 'Legalább egy számjegyet kell tartalmaznia';

  @override
  String get navHome => 'Kezdőlap';

  @override
  String get navCars => 'Autók';

  @override
  String get navAlerts => 'Riasztások';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Szolgáltatás indítása...';

  @override
  String get searchingServer => 'Szerver keresése...';

  @override
  String get connecting => 'Csatlakozás...';

  @override
  String get checkingUpdates => 'Frissítések keresése...';

  @override
  String get connected => 'Csatlakozva!';

  @override
  String get serverNotFound => 'A szerver nem található';

  @override
  String get serverNotFoundHintMobile =>
      'Győződj meg róla, hogy a számítógép be van kapcsolva és ugyanazon a Wi-Fi hálózaton van.';

  @override
  String get serverNotFoundHintDesktop =>
      'Ellenőrizd, hogy az alkalmazás helyesen van telepítve, majd próbáld újra.';

  @override
  String get searchAgain => 'Keresés újra';

  @override
  String greeting(String name) {
    return 'Szia, $name! 👋';
  }

  @override
  String get myCars => 'Autóim';

  @override
  String get viewAll => 'Összes';

  @override
  String get statActiveAlerts => 'Aktív riasztások';

  @override
  String get statExpired => 'Lejárt';

  @override
  String get addFirstCar => 'Add hozzá az első autót';

  @override
  String get noCarsYet => 'Még nincs autó hozzáadva';

  @override
  String get noCarsHint =>
      'Add hozzá az első autót az összes dokumentum kezeléséhez';

  @override
  String get addCar => 'Autó hozzáadása';

  @override
  String carsCount(int count, int max) {
    return '$count/$max autó';
  }

  @override
  String get deleteCar => 'Autó törlése';

  @override
  String deleteCarConfirm(String name) {
    return 'Törlöd: \"$name\"? Minden kapcsolódó adat törlődik.';
  }

  @override
  String get language => 'Nyelv';

  @override
  String get languageChoose => 'Válassz nyelvet';

  @override
  String get generalInfo => 'Általános adatok';

  @override
  String get technicalDetails => 'Műszaki adatok';

  @override
  String get validFrom => 'Érvényes ettől';

  @override
  String get expires => 'Lejár';

  @override
  String get expiresOn => 'Lejárat';

  @override
  String get daysLeft => 'Hátralévő napok';

  @override
  String get price => 'Ár';

  @override
  String get priceRon => 'Ár (RON)';

  @override
  String scanFailed(String msg) {
    return 'A beolvasás sikertelen: $msg';
  }

  @override
  String get extractedData => 'Kinyert adatok';

  @override
  String get noDataExtracted =>
      'Nem sikerült automatikusan adatot kinyerni a képből.';

  @override
  String get detectedText => 'Felismert szöveg:';

  @override
  String get checkFirst => 'Előbb ellenőrizd';

  @override
  String get saveDirectly => 'Mentés azonnal';

  @override
  String deleteConfirmGeneric(String name) {
    return 'Törlöd: \"$name\"?';
  }

  @override
  String get vignettes => 'Matricák';

  @override
  String get vignette => 'Matrica';

  @override
  String get addVignette => 'Matrica hozzáadása';

  @override
  String get editVignette => 'Matrica szerkesztése';

  @override
  String get saveVignette => 'Matrica mentése';

  @override
  String get vignetteAdded => 'Matrica hozzáadva!';

  @override
  String get vignetteUpdated => 'Matrica frissítve!';

  @override
  String get noVignettes => 'Nincs matrica hozzáadva';

  @override
  String get deleteVignette => 'Matrica törlése';

  @override
  String get deleteVignetteConfirm => 'Biztosan törlöd ezt a matricát?';

  @override
  String get purchaseDate => 'Vásárlás dátuma';

  @override
  String get validityPeriod => 'Érvényességi idő *';

  @override
  String get period => 'Időszak';

  @override
  String get issuer => 'Kibocsátó';

  @override
  String get issuerCompany => 'Kibocsátó cég';

  @override
  String get invoiceSeries => 'Számlasorozat';

  @override
  String get insurance => 'Biztosítások';

  @override
  String get addInsurance => 'Biztosítás hozzáadása';

  @override
  String get saveInsurance => 'Biztosítás mentése';

  @override
  String get insuranceAdded => 'Biztosítás hozzáadva!';

  @override
  String get insuranceUpdated => 'Biztosítás frissítve!';

  @override
  String get noInsurance => 'Nincs biztosítás hozzáadva';

  @override
  String get deleteInsurance => 'Biztosítás törlése';

  @override
  String get insurerCompany => 'Biztosítótársaság *';

  @override
  String get policyNumber => 'Kötvényszám';

  @override
  String get premiumRon => 'Díj (RON)';

  @override
  String get premium => 'Díj';

  @override
  String get deductibleRon => 'Önrész (RON)';

  @override
  String get paymentFrequency => 'Fizetési gyakoriság';

  @override
  String get purchasedOn => 'Vásárolva';

  @override
  String get agentName => 'Ügynök neve';

  @override
  String get agentPhone => 'Ügynök telefonszáma';

  @override
  String get agent => 'Ügynök';

  @override
  String get roadsideAssistance => 'Útmenti segítségnyújtás';

  @override
  String get roadsideIncluded => 'Útmenti segítségnyújtás beleértve';

  @override
  String get included => 'Tartalmazza';

  @override
  String get freqMonthly => 'Havonta';

  @override
  String get freqQuarterly => 'Negyedévente';

  @override
  String get freqBiannual => 'Félévente';

  @override
  String get freqAnnual => 'Évente';

  @override
  String get registrationDoc => 'Forgalmi & Műszaki';

  @override
  String get registrationShort => 'Forgalmi';

  @override
  String get addRegistration => 'Forgalmi hozzáadása';

  @override
  String get editRegistration => 'Forgalmi szerkesztése';

  @override
  String get registrationAdded => 'Forgalmi hozzáadva!';

  @override
  String get registrationUpdated => 'Forgalmi frissítve!';

  @override
  String get noRegistration => 'Nincs forgalmi hozzáadva';

  @override
  String get deleteRegistration => 'Forgalmi törlése';

  @override
  String get deleteRegistrationConfirm => 'Biztosan törlöd ezt a forgalmit?';

  @override
  String get vehicleData => 'Jármű adatai';

  @override
  String get registrationAndItp => 'Forgalomba helyezés & Műszaki';

  @override
  String get brand => 'Márka';

  @override
  String get model => 'Modell';

  @override
  String get manufacturingYear => 'Gyártási év';

  @override
  String get plateNumber => 'Rendszám';

  @override
  String get vin => 'Alvázszám (VIN)';

  @override
  String get ownerName => 'Tulajdonos neve';

  @override
  String get ownerAddress => 'Tulajdonos címe';

  @override
  String get owner => 'Tulajdonos';

  @override
  String get address => 'Cím';

  @override
  String get registrationDate => 'Forgalomba helyezés dátuma';

  @override
  String get itpExpiryDate => 'Műszaki lejárata';

  @override
  String get itpExpires => 'Műszaki lejár';

  @override
  String get itpValid => 'Műszaki érvényes';

  @override
  String get itpExpired => 'Műszaki lejárt!';

  @override
  String ocrFieldsFilled(int count) {
    return '$count mező kitöltve a beolvasásból — mentés előtt ellenőrizd.';
  }

  @override
  String get scanned => 'beolvasva';

  @override
  String get maintenance => 'Szerviz & Karbantartás';

  @override
  String get maintenanceShort => 'Szerviz';

  @override
  String get addMaintenance => 'Szerviz hozzáadása';

  @override
  String get editMaintenance => 'Szerviz szerkesztése';

  @override
  String get maintenanceAdded => 'Szerviz rögzítve!';

  @override
  String get maintenanceUpdated => 'Szerviz frissítve!';

  @override
  String get noMaintenance => 'Nincs rögzített szerviz';

  @override
  String get deleteMaintenance => 'Bejegyzés törlése';

  @override
  String get interventionType => 'Beavatkozás típusa *';

  @override
  String get performedDate => 'Elvégzés dátuma *';

  @override
  String get description => 'Leírás';

  @override
  String get mileageAtService => 'Km a szervizkor';

  @override
  String get nextService => 'Következő szerviz (opcionális)';

  @override
  String get nextMileage => 'Következő km';

  @override
  String get nextDate => 'Következő dátum';

  @override
  String get autoShop => 'Autószerviz';

  @override
  String get svcOilChange => 'Olajcsere';

  @override
  String get svcFilters => 'Szűrők';

  @override
  String get svcBrakePads => 'Fékbetétek';

  @override
  String get svcTyres => 'Gumiabroncsok';

  @override
  String get svcTimingBelt => 'Vezérműszíj';

  @override
  String get svcAltBelt => 'Generátorszíj';

  @override
  String get svcBattery => 'Akkumulátor';

  @override
  String get svcShocks => 'Lengéscsillapítók';

  @override
  String get svcSparkPlugs => 'Gyertyák';

  @override
  String get other => 'Egyéb';

  @override
  String get modifications => 'Módosítások';

  @override
  String get addModification => 'Módosítás hozzáadása';

  @override
  String get editModification => 'Módosítás szerkesztése';

  @override
  String get modificationAdded => 'Módosítás hozzáadva!';

  @override
  String get modificationUpdated => 'Módosítás frissítve!';

  @override
  String get noModifications => 'Nincs módosítás hozzáadva';

  @override
  String get deleteModification => 'Módosítás törlése';

  @override
  String get category => 'Kategória *';

  @override
  String get modDescription => 'Módosítás leírása *';

  @override
  String get modificationDate => 'Módosítás dátuma (opcionális)';

  @override
  String get performedBy => 'Elvégezte';

  @override
  String get homologated => 'Hatóságilag jóváhagyva';

  @override
  String get homologatedShort => 'Jóváhagyva';

  @override
  String get homologationNumber => 'Jóváhagyási szám';

  @override
  String get catEngine => 'Motor';

  @override
  String get catExterior => 'Külső';

  @override
  String get catInterior => 'Belső';

  @override
  String get catSuspension => 'Futómű';

  @override
  String get catAudio => 'Hangrendszer';

  @override
  String get catElectronic => 'Elektronika';

  @override
  String get catBrakes => 'Fékek';

  @override
  String get addPhoto => 'Fotó hozzáadása';

  @override
  String get noPhotos => 'Nincs fotó';

  @override
  String photoCounter(int count, int max) {
    return '$count. fotó / $max';
  }

  @override
  String uploadError(String msg) {
    return 'Feltöltési hiba: $msg';
  }

  @override
  String get notificationsTitle => 'Értesítések és riasztások';

  @override
  String get noNotifications => 'Nincs értesítés';

  @override
  String get allInOrder => 'Minden rendben!';

  @override
  String get checkNow => 'Ellenőrzés most';

  @override
  String get checkDocuments => 'Dokumentumok ellenőrzése';

  @override
  String get markRead => 'Megjelölés olvasottként';

  @override
  String get markAllRead => 'Összes olvasottként';

  @override
  String unreadCount(int count) {
    return '$count olvasatlan értesítés';
  }

  @override
  String get administration => 'Adminisztráció';

  @override
  String get users => 'Felhasználók';

  @override
  String accountsCount(int count) {
    return '$count fiók';
  }

  @override
  String get reload => 'Újratöltés';

  @override
  String get accountActive => 'Fiók aktív';

  @override
  String get accountActiveHint => 'A felhasználó be tud jelentkezni';

  @override
  String get inactive => 'Inaktív';

  @override
  String get role => 'Szerepkör';

  @override
  String get subscription => 'Előfizetés';

  @override
  String get carLimit => 'Autók korlátja';

  @override
  String createdOn(String name) {
    return 'Létrehozva: $name';
  }

  @override
  String docsShort(int count) {
    return '$count dok.';
  }

  @override
  String get deleteUser => 'Felhasználó törlése';

  @override
  String deleteUserConfirm(String name) {
    return 'Törlöd \"$name\" fiókját?\n\nMinden autója és dokumentuma véglegesen törlődik.';
  }

  @override
  String userDeleted(String name) {
    return 'A(z) \"$name\" fiók törölve.';
  }

  @override
  String get userUpdated => 'Felhasználó sikeresen frissítve!';

  @override
  String get carDetails => 'Autó részletei';

  @override
  String get documents => 'Dokumentumok';

  @override
  String get info => 'Info';

  @override
  String get tapForDetails => 'Koppints a részletekért';

  @override
  String get engineCapacity => 'Hengerűrtartalom';

  @override
  String get enginePower => 'Teljesítmény';

  @override
  String get fuelType => 'Üzemanyag';

  @override
  String get color => 'Szín';

  @override
  String get mileage => 'Kilométeróra';

  @override
  String get nickname => 'Becenév (opcionális)';

  @override
  String get saveCar => 'Autó mentése';

  @override
  String get carAdded => 'Autó hozzáadva!';

  @override
  String get invalidYear => 'Érvénytelen év';

  @override
  String get saveError => 'Hiba a mentés során';

  @override
  String get fuelPetrol => 'Benzin';

  @override
  String get fuelDiesel => 'Dízel';

  @override
  String get fuelHybrid => 'Hibrid';

  @override
  String get fuelElectric => 'Elektromos';

  @override
  String get fuelLpg => 'LPG';

  @override
  String addOf(String name) {
    return '$name hozzáadása';
  }

  @override
  String editOf(String name) {
    return '$name szerkesztése';
  }

  @override
  String expiresOnDate(String name) {
    return 'Lejár: $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Következő: $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Következő szerviz: $name';
  }

  @override
  String atKm(String name) {
    return 'Ekkor: $name km';
  }

  @override
  String get scanComplete => 'Beolvasás kész! Ellenőrizd az adatokat.';

  @override
  String get hintNickname => 'Pl.: A kis Daciám';

  @override
  String get hintCity => 'Bukarest';

  @override
  String get hintAddress => 'Példa utca 1., Bukarest';

  @override
  String get hintPerformedBy => 'Szerviz / személy';

  @override
  String get errNoConnection =>
      'A szerver nem érhető el. Ellenőrizd a kapcsolatot.';

  @override
  String get errServerDown =>
      'A szerver nem elérhető. Fut a háttérszolgáltatás?';

  @override
  String get errAccountDisabled =>
      'A fiókod le lett tiltva. Vedd fel a kapcsolatot a támogatással.';

  @override
  String get errBadCredentials => 'Hibás e-mail vagy jelszó.';

  @override
  String get errInvalidData => 'Érvénytelen adatok. Ellenőrizd a mezőket.';

  @override
  String get errForbidden => 'Nincs jogosultságod ehhez a művelethez.';

  @override
  String get errNotFound => 'Az erőforrás nem található.';

  @override
  String get errServer => 'Szerverhiba. Próbáld újra.';

  @override
  String errWithCode(String name) {
    return 'Hiba történt ($name kód).';
  }

  @override
  String get errUnexpected => 'Váratlan hiba történt.';

  @override
  String get updateAvailable => 'Frissítés elérhető';

  @override
  String get updateRequired => 'Kötelező frissítés';

  @override
  String get newVersion => 'Új verzió: ';

  @override
  String get whatsNew => 'Újdonságok:';

  @override
  String get updateNow => 'Frissítés most';

  @override
  String get later => 'Később';

  @override
  String get downloadingUpdate => 'Frissítés letöltése';

  @override
  String get updateMandatory =>
      'Ez a verzió már nem támogatott. A frissítés kötelező.';

  @override
  String get downloadFailed =>
      'A letöltés sikertelen. Ellenőrizd a kapcsolatot és próbáld újra.';

  @override
  String get integrityFailed =>
      'Az integritás-ellenőrzés sikertelen — a fájl sérült vagy módosított. A telepítés megszakadt.';

  @override
  String get updateError => 'Frissítési hiba';

  @override
  String get fieldsAutoFilled =>
      'A mezők automatikusan kitöltve. Mented most, vagy előbb ellenőrzöd?';

  @override
  String daysSuffix(int count) {
    return '$count nap';
  }

  @override
  String get hintInterventionDetails => 'A beavatkozás részletei...';

  @override
  String get scanDocument => 'Dokumentum beolvasása';

  @override
  String get photographDocument => 'Fényképezd le a dokumentumot';

  @override
  String get cameraOrGallery => 'Kamera / Galéria';

  @override
  String get selectImage => 'Kép kiválasztása';

  @override
  String get selectExistingPhoto => 'Válassz meglévő fotót';

  @override
  String get selectImageSource => 'Válassz képforrást';

  @override
  String get scanHintCamera =>
      'Fényképezd le vagy válaszd ki a dokumentumot az automatikus kitöltéshez.';

  @override
  String get scanHintGallery =>
      'Válassz egy képet a dokumentumról a mezők automatikus kitöltéséhez.';

  @override
  String get processing => 'Feldolgozás...';

  @override
  String get checkingKnownServer => 'Ismert szerver ellenőrzése...';

  @override
  String get privacyOptions => 'Adatvédelmi beállítások';

  @override
  String get privacyOptionsHint => 'Személyre szabott hirdetések beállítása';
}
