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

  @override
  String get generalInfo => 'Allgemeine Angaben';

  @override
  String get technicalDetails => 'Technische Daten';

  @override
  String get validFrom => 'Gültig ab';

  @override
  String get expires => 'Läuft ab';

  @override
  String get expiresOn => 'Läuft ab am';

  @override
  String get daysLeft => 'Verbleibende Tage';

  @override
  String get price => 'Preis';

  @override
  String get priceRon => 'Preis (RON)';

  @override
  String scanFailed(String msg) {
    return 'Scan fehlgeschlagen: $msg';
  }

  @override
  String get extractedData => 'Erkannte Daten';

  @override
  String get noDataExtracted =>
      'Aus dem Bild konnten keine Daten automatisch gelesen werden.';

  @override
  String get detectedText => 'Erkannter Text:';

  @override
  String get checkFirst => 'Zuerst prüfen';

  @override
  String get saveDirectly => 'Direkt speichern';

  @override
  String deleteConfirmGeneric(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get vignettes => 'Vignetten';

  @override
  String get vignette => 'Vignette';

  @override
  String get addVignette => 'Vignette hinzufügen';

  @override
  String get editVignette => 'Vignette bearbeiten';

  @override
  String get saveVignette => 'Vignette speichern';

  @override
  String get vignetteAdded => 'Vignette hinzugefügt!';

  @override
  String get vignetteUpdated => 'Vignette aktualisiert!';

  @override
  String get noVignettes => 'Keine Vignetten vorhanden';

  @override
  String get deleteVignette => 'Vignette löschen';

  @override
  String get deleteVignetteConfirm =>
      'Möchtest du diese Vignette wirklich löschen?';

  @override
  String get purchaseDate => 'Kaufdatum';

  @override
  String get validityPeriod => 'Gültigkeitsdauer *';

  @override
  String get period => 'Zeitraum';

  @override
  String get issuer => 'Aussteller';

  @override
  String get issuerCompany => 'Ausstellendes Unternehmen';

  @override
  String get invoiceSeries => 'Rechnungsserie';

  @override
  String get insurance => 'Versicherungen';

  @override
  String get addInsurance => 'Versicherung hinzufügen';

  @override
  String get saveInsurance => 'Versicherung speichern';

  @override
  String get insuranceAdded => 'Versicherung hinzugefügt!';

  @override
  String get insuranceUpdated => 'Versicherung aktualisiert!';

  @override
  String get noInsurance => 'Keine Versicherung vorhanden';

  @override
  String get deleteInsurance => 'Versicherung löschen';

  @override
  String get insurerCompany => 'Versicherungsgesellschaft *';

  @override
  String get policyNumber => 'Policennr.';

  @override
  String get premiumRon => 'Prämie (RON)';

  @override
  String get premium => 'Prämie';

  @override
  String get deductibleRon => 'Selbstbeteiligung (RON)';

  @override
  String get paymentFrequency => 'Zahlungsintervall';

  @override
  String get purchasedOn => 'Gekauft am';

  @override
  String get agentName => 'Name des Vertreters';

  @override
  String get agentPhone => 'Telefon des Vertreters';

  @override
  String get agent => 'Vertreter';

  @override
  String get roadsideAssistance => 'Pannenhilfe';

  @override
  String get roadsideIncluded => 'Pannenhilfe inbegriffen';

  @override
  String get included => 'Inbegriffen';

  @override
  String get freqMonthly => 'Monatlich';

  @override
  String get freqQuarterly => 'Vierteljährlich';

  @override
  String get freqBiannual => 'Halbjährlich';

  @override
  String get freqAnnual => 'Jährlich';

  @override
  String get registrationDoc => 'Fahrzeugschein & TÜV';

  @override
  String get registrationShort => 'Fahrzeugschein';

  @override
  String get addRegistration => 'Fahrzeugschein hinzufügen';

  @override
  String get editRegistration => 'Fahrzeugschein bearbeiten';

  @override
  String get registrationAdded => 'Fahrzeugschein hinzugefügt!';

  @override
  String get registrationUpdated => 'Fahrzeugschein aktualisiert!';

  @override
  String get noRegistration => 'Kein Fahrzeugschein vorhanden';

  @override
  String get deleteRegistration => 'Fahrzeugschein löschen';

  @override
  String get deleteRegistrationConfirm =>
      'Möchtest du diesen Fahrzeugschein wirklich löschen?';

  @override
  String get vehicleData => 'Fahrzeugdaten';

  @override
  String get registrationAndItp => 'Zulassung & TÜV';

  @override
  String get brand => 'Marke';

  @override
  String get model => 'Modell';

  @override
  String get manufacturingYear => 'Baujahr';

  @override
  String get plateNumber => 'Kennzeichen';

  @override
  String get vin => 'Fahrgestellnummer (VIN)';

  @override
  String get ownerName => 'Name des Halters';

  @override
  String get ownerAddress => 'Adresse des Halters';

  @override
  String get owner => 'Halter';

  @override
  String get address => 'Adresse';

  @override
  String get registrationDate => 'Zulassungsdatum';

  @override
  String get itpExpiryDate => 'TÜV gültig bis';

  @override
  String get itpExpires => 'TÜV läuft ab';

  @override
  String get itpValid => 'TÜV gültig';

  @override
  String get itpExpired => 'TÜV abgelaufen!';

  @override
  String ocrFieldsFilled(int count) {
    return '$count Felder aus dem Scan übernommen — bitte vor dem Speichern prüfen.';
  }

  @override
  String get scanned => 'gescannt';

  @override
  String get maintenance => 'Service & Wartung';

  @override
  String get maintenanceShort => 'Service';

  @override
  String get addMaintenance => 'Service hinzufügen';

  @override
  String get editMaintenance => 'Service bearbeiten';

  @override
  String get maintenanceAdded => 'Service erfasst!';

  @override
  String get maintenanceUpdated => 'Service aktualisiert!';

  @override
  String get noMaintenance => 'Kein Service erfasst';

  @override
  String get deleteMaintenance => 'Eintrag löschen';

  @override
  String get interventionType => 'Serviceart *';

  @override
  String get performedDate => 'Durchführungsdatum *';

  @override
  String get description => 'Beschreibung';

  @override
  String get mileageAtService => 'Kilometerstand';

  @override
  String get nextService => 'Nächster Service (optional)';

  @override
  String get nextMileage => 'Nächster Kilometerstand';

  @override
  String get nextDate => 'Nächstes Datum';

  @override
  String get autoShop => 'Werkstatt';

  @override
  String get svcOilChange => 'Ölwechsel';

  @override
  String get svcFilters => 'Filter';

  @override
  String get svcBrakePads => 'Bremsbeläge';

  @override
  String get svcTyres => 'Reifen';

  @override
  String get svcTimingBelt => 'Zahnriemen';

  @override
  String get svcAltBelt => 'Keilriemen';

  @override
  String get svcBattery => 'Batterie';

  @override
  String get svcShocks => 'Stoßdämpfer';

  @override
  String get svcSparkPlugs => 'Zündkerzen';

  @override
  String get other => 'Sonstiges';

  @override
  String get modifications => 'Umbauten';

  @override
  String get addModification => 'Umbau hinzufügen';

  @override
  String get editModification => 'Umbau bearbeiten';

  @override
  String get modificationAdded => 'Umbau hinzugefügt!';

  @override
  String get modificationUpdated => 'Umbau aktualisiert!';

  @override
  String get noModifications => 'Keine Umbauten vorhanden';

  @override
  String get deleteModification => 'Umbau löschen';

  @override
  String get category => 'Kategorie *';

  @override
  String get modDescription => 'Beschreibung des Umbaus *';

  @override
  String get modificationDate => 'Datum des Umbaus (optional)';

  @override
  String get performedBy => 'Durchgeführt von';

  @override
  String get homologated => 'Amtlich eingetragen';

  @override
  String get homologatedShort => 'Eingetragen';

  @override
  String get homologationNumber => 'Zulassungsnr.';

  @override
  String get catEngine => 'Motor';

  @override
  String get catExterior => 'Außen';

  @override
  String get catInterior => 'Innen';

  @override
  String get catSuspension => 'Fahrwerk';

  @override
  String get catAudio => 'Audio';

  @override
  String get catElectronic => 'Elektronik';

  @override
  String get catBrakes => 'Bremsen';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get noPhotos => 'Keine Fotos';

  @override
  String photoCounter(int count, int max) {
    return 'Foto $count von $max';
  }

  @override
  String uploadError(String msg) {
    return 'Upload-Fehler: $msg';
  }

  @override
  String get notificationsTitle => 'Benachrichtigungen & Warnungen';

  @override
  String get noNotifications => 'Keine Benachrichtigungen';

  @override
  String get allInOrder => 'Alles in Ordnung!';

  @override
  String get checkNow => 'Jetzt prüfen';

  @override
  String get checkDocuments => 'Dokumente prüfen';

  @override
  String get markRead => 'Als gelesen markieren';

  @override
  String get markAllRead => 'Alle als gelesen';

  @override
  String unreadCount(int count) {
    return '$count ungelesene Benachrichtigungen';
  }

  @override
  String get administration => 'Verwaltung';

  @override
  String get users => 'Benutzer';

  @override
  String accountsCount(int count) {
    return '$count Konten';
  }

  @override
  String get reload => 'Neu laden';

  @override
  String get accountActive => 'Konto aktiv';

  @override
  String get accountActiveHint => 'Der Benutzer kann sich anmelden';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get role => 'Rolle';

  @override
  String get subscription => 'Abonnement';

  @override
  String get carLimit => 'Fahrzeuglimit';

  @override
  String createdOn(String name) {
    return 'Erstellt: $name';
  }

  @override
  String docsShort(int count) {
    return '$count Dok.';
  }

  @override
  String get deleteUser => 'Benutzer löschen';

  @override
  String deleteUserConfirm(String name) {
    return 'Konto von \"$name\" löschen?\n\nAlle Fahrzeuge und Dokumente werden dauerhaft entfernt.';
  }

  @override
  String userDeleted(String name) {
    return 'Das Konto \"$name\" wurde gelöscht.';
  }

  @override
  String get userUpdated => 'Benutzer erfolgreich aktualisiert!';

  @override
  String get carDetails => 'Fahrzeugdetails';

  @override
  String get documents => 'Dokumente';

  @override
  String get info => 'Info';

  @override
  String get tapForDetails => 'Für Details tippen';

  @override
  String get engineCapacity => 'Hubraum';

  @override
  String get enginePower => 'Leistung';

  @override
  String get fuelType => 'Kraftstoff';

  @override
  String get color => 'Farbe';

  @override
  String get mileage => 'Kilometerstand';

  @override
  String get nickname => 'Spitzname (optional)';

  @override
  String get saveCar => 'Fahrzeug speichern';

  @override
  String get carAdded => 'Fahrzeug hinzugefügt!';

  @override
  String get invalidYear => 'Ungültiges Jahr';

  @override
  String get saveError => 'Fehler beim Speichern';

  @override
  String get fuelPetrol => 'Benzin';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybrid';

  @override
  String get fuelElectric => 'Elektro';

  @override
  String get fuelLpg => 'Autogas';

  @override
  String addOf(String name) {
    return '$name hinzufügen';
  }

  @override
  String editOf(String name) {
    return '$name bearbeiten';
  }

  @override
  String expiresOnDate(String name) {
    return 'Läuft ab: $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Nächster: $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Nächster Service: $name';
  }

  @override
  String atKm(String name) {
    return 'Bei: $name km';
  }

  @override
  String get scanComplete => 'Scan abgeschlossen! Bitte Daten prüfen.';

  @override
  String get hintNickname => 'z. B. Mein kleiner Dacia';

  @override
  String get hintCity => 'Bukarest';

  @override
  String get hintAddress => 'Beispielstr. 1, Bukarest';

  @override
  String get hintPerformedBy => 'Werkstatt / Person';

  @override
  String get errNoConnection =>
      'Server nicht erreichbar. Prüfe deine Verbindung.';

  @override
  String get errServerDown => 'Server nicht verfügbar. Läuft das Backend?';

  @override
  String get errAccountDisabled =>
      'Dein Konto wurde deaktiviert. Bitte den Support kontaktieren.';

  @override
  String get errBadCredentials => 'E-Mail oder Passwort falsch.';

  @override
  String get errInvalidData => 'Ungültige Daten. Bitte Felder prüfen.';

  @override
  String get errForbidden => 'Du hast keine Berechtigung für diese Aktion.';

  @override
  String get errNotFound => 'Ressource nicht gefunden.';

  @override
  String get errServer => 'Serverfehler. Bitte erneut versuchen.';

  @override
  String errWithCode(String name) {
    return 'Ein Fehler ist aufgetreten (Code $name).';
  }

  @override
  String get errUnexpected => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String get updateRequired => 'Update erforderlich';

  @override
  String get newVersion => 'Neue Version: ';

  @override
  String get whatsNew => 'Neuerungen:';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get later => 'Später';

  @override
  String get downloadingUpdate => 'Update wird heruntergeladen';

  @override
  String get updateMandatory =>
      'Diese Version wird nicht mehr unterstützt. Ein Update ist erforderlich.';

  @override
  String get downloadFailed =>
      'Download fehlgeschlagen. Prüfe die Verbindung und versuche es erneut.';

  @override
  String get integrityFailed =>
      'Integritätsprüfung fehlgeschlagen — die Datei ist beschädigt oder verändert. Installation abgebrochen.';

  @override
  String get updateError => 'Fehler beim Update';

  @override
  String get fieldsAutoFilled =>
      'Die Felder wurden automatisch ausgefüllt. Jetzt speichern oder zuerst prüfen?';

  @override
  String daysSuffix(int count) {
    return '$count Tage';
  }

  @override
  String get hintInterventionDetails => 'Details der Arbeiten...';

  @override
  String get scanDocument => 'Dokument scannen';

  @override
  String get photographDocument => 'Dokument fotografieren';

  @override
  String get cameraOrGallery => 'Kamera / Galerie';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get selectExistingPhoto => 'Vorhandenes Foto wählen';

  @override
  String get selectImageSource => 'Bildquelle wählen';

  @override
  String get scanHintCamera =>
      'Fotografiere oder wähle das Dokument für automatisches Ausfüllen.';

  @override
  String get scanHintGallery =>
      'Wähle ein Bild des Dokuments für automatisches Ausfüllen.';

  @override
  String get processing => 'Wird verarbeitet...';

  @override
  String get checkingKnownServer => 'Bekannter Server wird geprüft...';

  @override
  String get privacyOptions => 'Datenschutz-Optionen';

  @override
  String get privacyOptionsHint =>
      'Auswahl zu personalisierter Werbung verwalten';
}
