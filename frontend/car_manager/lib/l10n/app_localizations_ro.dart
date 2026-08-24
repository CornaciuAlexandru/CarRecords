// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Salvează';

  @override
  String get cancel => 'Anulează';

  @override
  String get delete => 'Șterge';

  @override
  String get edit => 'Editează';

  @override
  String get add => 'Adaugă';

  @override
  String get update => 'Actualizează';

  @override
  String get retry => 'Încearcă din nou';

  @override
  String get error => 'Eroare';

  @override
  String errorWith(String msg) {
    return 'Eroare: $msg';
  }

  @override
  String get required => 'Obligatoriu';

  @override
  String get optional => 'opțional';

  @override
  String get notes => 'Note';

  @override
  String get notesHint => 'Observații...';

  @override
  String get chooseDate => 'Alege dată';

  @override
  String get city => 'Oraș';

  @override
  String get cost => 'Cost (RON)';

  @override
  String get invoiceNr => 'Nr. factură';

  @override
  String get loginTitle => 'Bine ai revenit';

  @override
  String get loginSubtitle => 'Autentifică-te pentru a continua';

  @override
  String get email => 'Email';

  @override
  String get password => 'Parolă';

  @override
  String get login => 'Autentificare';

  @override
  String get register => 'Creează cont';

  @override
  String get noAccount => 'Nu ai cont? ';

  @override
  String get haveAccount => 'Ai deja cont? ';

  @override
  String get fullName => 'Nume complet';

  @override
  String get phone => 'Telefon';

  @override
  String get confirmPassword => 'Confirmă parola';

  @override
  String get passwordsDoNotMatch => 'Parolele nu coincid';

  @override
  String get invalidEmail => 'Adresă de email invalidă';

  @override
  String get passwordTooShort => 'Minim 8 caractere';

  @override
  String get logout => 'Deconectare';

  @override
  String get newAccount => 'Cont nou';

  @override
  String get fillDetails => 'Completează datele de mai jos';

  @override
  String get minChars3 => 'Minim 3 caractere';

  @override
  String get phoneOptional => 'Telefon (opțional)';

  @override
  String get passwordRulesHint => 'Min. 8 caractere, 1 majusculă, 1 cifră';

  @override
  String get passwordNeedsUpper => 'Trebuie cel puțin o literă mare';

  @override
  String get passwordNeedsDigit => 'Trebuie cel puțin o cifră';

  @override
  String get navHome => 'Acasă';

  @override
  String get navCars => 'Mașini';

  @override
  String get navAlerts => 'Alerte';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Se pornește serviciul...';

  @override
  String get searchingServer => 'Se caută serverul în rețea...';

  @override
  String get connecting => 'Se conectează...';

  @override
  String get checkingUpdates => 'Se verifică actualizări...';

  @override
  String get connected => 'Conectat!';

  @override
  String get serverNotFound => 'Server negăsit';

  @override
  String get serverNotFoundHintMobile =>
      'Asigură-te că PC-ul este pornit și conectat la aceeași rețea Wi-Fi.';

  @override
  String get serverNotFoundHintDesktop =>
      'Asigură-te că aplicația este instalată corect și încearcă din nou.';

  @override
  String get searchAgain => 'Caută din nou';

  @override
  String greeting(String name) {
    return 'Bună, $name! 👋';
  }

  @override
  String get myCars => 'Mașinile mele';

  @override
  String get viewAll => 'Vezi toate';

  @override
  String get statActiveAlerts => 'Alerte active';

  @override
  String get statExpired => 'Expirate';

  @override
  String get addFirstCar => 'Adaugă prima mașină';

  @override
  String get noCarsYet => 'Nu ai mașini adăugate';

  @override
  String get noCarsHint =>
      'Adaugă prima ta mașină pentru a gestiona toate documentele';

  @override
  String get addCar => 'Adaugă mașină';

  @override
  String carsCount(int count, int max) {
    return '$count/$max mașini';
  }

  @override
  String get deleteCar => 'Șterge mașina';

  @override
  String deleteCarConfirm(String name) {
    return 'Ștergi \"$name\"? Toate datele asociate vor fi șterse.';
  }

  @override
  String get language => 'Limbă';

  @override
  String get languageChoose => 'Alege limba';
}
