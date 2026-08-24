// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get update => 'Aktualisieren';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get error => 'Fehler';

  @override
  String errorWith(String msg) {
    return 'Fehler: $msg';
  }

  @override
  String get required => 'Erforderlich';

  @override
  String get optional => 'optional';

  @override
  String get notes => 'Notizen';

  @override
  String get notesHint => 'Anmerkungen...';

  @override
  String get chooseDate => 'Datum wählen';

  @override
  String get city => 'Stadt';

  @override
  String get cost => 'Kosten (RON)';

  @override
  String get invoiceNr => 'Rechnungsnr.';

  @override
  String get loginTitle => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Melde dich an, um fortzufahren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Anmelden';

  @override
  String get register => 'Konto erstellen';

  @override
  String get noAccount => 'Kein Konto? ';

  @override
  String get haveAccount => 'Schon ein Konto? ';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get phone => 'Telefon';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get invalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get passwordTooShort => 'Mindestens 8 Zeichen';

  @override
  String get logout => 'Abmelden';

  @override
  String get newAccount => 'Neues Konto';

  @override
  String get fillDetails => 'Fülle die folgenden Daten aus';

  @override
  String get minChars3 => 'Mindestens 3 Zeichen';

  @override
  String get phoneOptional => 'Telefon (optional)';

  @override
  String get passwordRulesHint => 'Mind. 8 Zeichen, 1 Großbuchstabe, 1 Ziffer';

  @override
  String get passwordNeedsUpper =>
      'Muss mindestens einen Großbuchstaben enthalten';

  @override
  String get passwordNeedsDigit => 'Muss mindestens eine Ziffer enthalten';

  @override
  String get navHome => 'Start';

  @override
  String get navCars => 'Fahrzeuge';

  @override
  String get navAlerts => 'Warnungen';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Dienst wird gestartet...';

  @override
  String get searchingServer => 'Server wird gesucht...';

  @override
  String get connecting => 'Verbindung wird hergestellt...';

  @override
  String get checkingUpdates => 'Suche nach Updates...';

  @override
  String get connected => 'Verbunden!';

  @override
  String get serverNotFound => 'Server nicht gefunden';

  @override
  String get serverNotFoundHintMobile =>
      'Stelle sicher, dass dein PC eingeschaltet und im selben WLAN ist.';

  @override
  String get serverNotFoundHintDesktop =>
      'Stelle sicher, dass die App korrekt installiert ist, und versuche es erneut.';

  @override
  String get searchAgain => 'Erneut suchen';

  @override
  String greeting(String name) {
    return 'Hallo, $name! 👋';
  }

  @override
  String get myCars => 'Meine Fahrzeuge';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get statActiveAlerts => 'Aktive Warnungen';

  @override
  String get statExpired => 'Abgelaufen';

  @override
  String get addFirstCar => 'Erstes Fahrzeug hinzufügen';

  @override
  String get noCarsYet => 'Noch keine Fahrzeuge';

  @override
  String get noCarsHint =>
      'Füge dein erstes Fahrzeug hinzu, um alle Dokumente zu verwalten';

  @override
  String get addCar => 'Fahrzeug hinzufügen';

  @override
  String carsCount(int count, int max) {
    return '$count/$max Fahrzeuge';
  }

  @override
  String get deleteCar => 'Fahrzeug löschen';

  @override
  String deleteCarConfirm(String name) {
    return '\"$name\" löschen? Alle zugehörigen Daten werden entfernt.';
  }

  @override
  String get language => 'Sprache';

  @override
  String get languageChoose => 'Sprache wählen';
}
