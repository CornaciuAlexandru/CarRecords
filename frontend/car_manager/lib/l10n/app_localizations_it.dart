// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get add => 'Aggiungi';

  @override
  String get update => 'Aggiorna';

  @override
  String get retry => 'Riprova';

  @override
  String get error => 'Errore';

  @override
  String errorWith(String msg) {
    return 'Errore: $msg';
  }

  @override
  String get required => 'Obbligatorio';

  @override
  String get optional => 'facoltativo';

  @override
  String get notes => 'Note';

  @override
  String get notesHint => 'Osservazioni...';

  @override
  String get chooseDate => 'Scegli data';

  @override
  String get city => 'Città';

  @override
  String get cost => 'Costo (RON)';

  @override
  String get invoiceNr => 'N. fattura';

  @override
  String get loginTitle => 'Bentornato';

  @override
  String get loginSubtitle => 'Accedi per continuare';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Accedi';

  @override
  String get register => 'Crea account';

  @override
  String get noAccount => 'Non hai un account? ';

  @override
  String get haveAccount => 'Hai già un account? ';

  @override
  String get fullName => 'Nome completo';

  @override
  String get phone => 'Telefono';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get invalidEmail => 'Indirizzo email non valido';

  @override
  String get passwordTooShort => 'Almeno 8 caratteri';

  @override
  String get logout => 'Esci';

  @override
  String get newAccount => 'Nuovo account';

  @override
  String get fillDetails => 'Compila i dati qui sotto';

  @override
  String get minChars3 => 'Almeno 3 caratteri';

  @override
  String get phoneOptional => 'Telefono (facoltativo)';

  @override
  String get passwordRulesHint => 'Min. 8 caratteri, 1 maiuscola, 1 cifra';

  @override
  String get passwordNeedsUpper => 'Deve contenere almeno una maiuscola';

  @override
  String get passwordNeedsDigit => 'Deve contenere almeno una cifra';

  @override
  String get navHome => 'Home';

  @override
  String get navCars => 'Auto';

  @override
  String get navAlerts => 'Avvisi';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Avvio del servizio...';

  @override
  String get searchingServer => 'Ricerca del server...';

  @override
  String get connecting => 'Connessione...';

  @override
  String get checkingUpdates => 'Ricerca aggiornamenti...';

  @override
  String get connected => 'Connesso!';

  @override
  String get serverNotFound => 'Server non trovato';

  @override
  String get serverNotFoundHintMobile =>
      'Assicurati che il computer sia acceso e collegato alla stessa rete Wi-Fi.';

  @override
  String get serverNotFoundHintDesktop =>
      'Verifica che l\'app sia installata correttamente e riprova.';

  @override
  String get searchAgain => 'Cerca di nuovo';

  @override
  String greeting(String name) {
    return 'Ciao, $name! 👋';
  }

  @override
  String get myCars => 'Le mie auto';

  @override
  String get viewAll => 'Vedi tutti';

  @override
  String get statActiveAlerts => 'Avvisi attivi';

  @override
  String get statExpired => 'Scaduti';

  @override
  String get addFirstCar => 'Aggiungi la prima auto';

  @override
  String get noCarsYet => 'Nessuna auto aggiunta';

  @override
  String get noCarsHint =>
      'Aggiungi la prima auto per gestire tutti i suoi documenti';

  @override
  String get addCar => 'Aggiungi auto';

  @override
  String carsCount(int count, int max) {
    return '$count/$max auto';
  }

  @override
  String get deleteCar => 'Elimina auto';

  @override
  String deleteCarConfirm(String name) {
    return 'Eliminare \"$name\"? Tutti i dati associati verranno rimossi.';
  }

  @override
  String get language => 'Lingua';

  @override
  String get languageChoose => 'Scegli la lingua';
}
