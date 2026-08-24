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
}
