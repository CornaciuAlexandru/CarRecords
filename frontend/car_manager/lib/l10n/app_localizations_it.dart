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

  @override
  String get generalInfo => 'Informazioni generali';

  @override
  String get technicalDetails => 'Dettagli tecnici';

  @override
  String get validFrom => 'Valida dal';

  @override
  String get expires => 'Scade';

  @override
  String get expiresOn => 'Scade il';

  @override
  String get daysLeft => 'Giorni rimasti';

  @override
  String get price => 'Prezzo';

  @override
  String get priceRon => 'Prezzo (RON)';

  @override
  String scanFailed(String msg) {
    return 'Scansione non riuscita: $msg';
  }

  @override
  String get extractedData => 'Dati estratti';

  @override
  String get noDataExtracted =>
      'Non è stato possibile estrarre dati dall\'immagine.';

  @override
  String get detectedText => 'Testo rilevato:';

  @override
  String get checkFirst => 'Controlla prima';

  @override
  String get saveDirectly => 'Salva direttamente';

  @override
  String deleteConfirmGeneric(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get vignettes => 'Bollini';

  @override
  String get vignette => 'Bollino';

  @override
  String get addVignette => 'Aggiungi bollino';

  @override
  String get editVignette => 'Modifica bollino';

  @override
  String get saveVignette => 'Salva bollino';

  @override
  String get vignetteAdded => 'Bollino aggiunto!';

  @override
  String get vignetteUpdated => 'Bollino aggiornato!';

  @override
  String get noVignettes => 'Nessun bollino aggiunto';

  @override
  String get deleteVignette => 'Elimina bollino';

  @override
  String get deleteVignetteConfirm => 'Vuoi davvero eliminare questo bollino?';

  @override
  String get purchaseDate => 'Data acquisto';

  @override
  String get validityPeriod => 'Periodo di validità *';

  @override
  String get period => 'Periodo';

  @override
  String get issuer => 'Emittente';

  @override
  String get issuerCompany => 'Società emittente';

  @override
  String get invoiceSeries => 'Serie fattura';

  @override
  String get insurance => 'Assicurazioni';

  @override
  String get addInsurance => 'Aggiungi assicurazione';

  @override
  String get saveInsurance => 'Salva assicurazione';

  @override
  String get insuranceAdded => 'Assicurazione aggiunta!';

  @override
  String get insuranceUpdated => 'Assicurazione aggiornata!';

  @override
  String get noInsurance => 'Nessuna assicurazione aggiunta';

  @override
  String get deleteInsurance => 'Elimina assicurazione';

  @override
  String get insurerCompany => 'Compagnia assicurativa *';

  @override
  String get policyNumber => 'N. polizza';

  @override
  String get premiumRon => 'Premio (RON)';

  @override
  String get premium => 'Premio';

  @override
  String get deductibleRon => 'Franchigia (RON)';

  @override
  String get paymentFrequency => 'Frequenza di pagamento';

  @override
  String get purchasedOn => 'Acquistata il';

  @override
  String get agentName => 'Nome dell\'agente';

  @override
  String get agentPhone => 'Telefono dell\'agente';

  @override
  String get agent => 'Agente';

  @override
  String get roadsideAssistance => 'Assistenza stradale';

  @override
  String get roadsideIncluded => 'Assistenza stradale inclusa';

  @override
  String get included => 'Inclusa';

  @override
  String get freqMonthly => 'Mensile';

  @override
  String get freqQuarterly => 'Trimestrale';

  @override
  String get freqBiannual => 'Semestrale';

  @override
  String get freqAnnual => 'Annuale';

  @override
  String get registrationDoc => 'Libretto & Revisione';

  @override
  String get registrationShort => 'Libretto';

  @override
  String get addRegistration => 'Aggiungi libretto';

  @override
  String get editRegistration => 'Modifica libretto';

  @override
  String get registrationAdded => 'Libretto aggiunto!';

  @override
  String get registrationUpdated => 'Libretto aggiornato!';

  @override
  String get noRegistration => 'Nessun libretto aggiunto';

  @override
  String get deleteRegistration => 'Elimina libretto';

  @override
  String get deleteRegistrationConfirm =>
      'Vuoi davvero eliminare questo libretto?';

  @override
  String get vehicleData => 'Dati del veicolo';

  @override
  String get registrationAndItp => 'Immatricolazione & Revisione';

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modello';

  @override
  String get manufacturingYear => 'Anno di fabbricazione';

  @override
  String get plateNumber => 'Targa';

  @override
  String get vin => 'Numero di telaio (VIN)';

  @override
  String get ownerName => 'Nome del proprietario';

  @override
  String get ownerAddress => 'Indirizzo del proprietario';

  @override
  String get owner => 'Proprietario';

  @override
  String get address => 'Indirizzo';

  @override
  String get registrationDate => 'Data di immatricolazione';

  @override
  String get itpExpiryDate => 'Scadenza revisione';

  @override
  String get itpExpires => 'Revisione scade';

  @override
  String get itpValid => 'Revisione valida';

  @override
  String get itpExpired => 'Revisione scaduta!';

  @override
  String ocrFieldsFilled(int count) {
    return '$count campi compilati dalla scansione — controllali prima di salvare.';
  }

  @override
  String get scanned => 'scansionato';

  @override
  String get maintenance => 'Assistenza e manutenzione';

  @override
  String get maintenanceShort => 'Assistenza';

  @override
  String get addMaintenance => 'Aggiungi intervento';

  @override
  String get editMaintenance => 'Modifica intervento';

  @override
  String get maintenanceAdded => 'Intervento registrato!';

  @override
  String get maintenanceUpdated => 'Intervento aggiornato!';

  @override
  String get noMaintenance => 'Nessun intervento registrato';

  @override
  String get deleteMaintenance => 'Elimina registrazione';

  @override
  String get interventionType => 'Tipo di intervento *';

  @override
  String get performedDate => 'Data di esecuzione *';

  @override
  String get description => 'Descrizione';

  @override
  String get mileageAtService => 'Chilometraggio';

  @override
  String get nextService => 'Prossimo intervento (facoltativo)';

  @override
  String get nextMileage => 'Prossimo chilometraggio';

  @override
  String get nextDate => 'Prossima data';

  @override
  String get autoShop => 'Officina';

  @override
  String get svcOilChange => 'Cambio olio';

  @override
  String get svcFilters => 'Filtri';

  @override
  String get svcBrakePads => 'Pastiglie freni';

  @override
  String get svcTyres => 'Pneumatici';

  @override
  String get svcTimingBelt => 'Distribuzione';

  @override
  String get svcAltBelt => 'Cinghia alternatore';

  @override
  String get svcBattery => 'Batteria';

  @override
  String get svcShocks => 'Ammortizzatori';

  @override
  String get svcSparkPlugs => 'Candele';

  @override
  String get other => 'Altro';

  @override
  String get modifications => 'Modifiche';

  @override
  String get addModification => 'Aggiungi modifica';

  @override
  String get editModification => 'Modifica intervento';

  @override
  String get modificationAdded => 'Modifica aggiunta!';

  @override
  String get modificationUpdated => 'Modifica aggiornata!';

  @override
  String get noModifications => 'Nessuna modifica aggiunta';

  @override
  String get deleteModification => 'Elimina modifica';

  @override
  String get category => 'Categoria *';

  @override
  String get modDescription => 'Descrizione della modifica *';

  @override
  String get modificationDate => 'Data della modifica (facoltativa)';

  @override
  String get performedBy => 'Eseguita da';

  @override
  String get homologated => 'Omologata';

  @override
  String get homologatedShort => 'Omologato';

  @override
  String get homologationNumber => 'N. omologazione';

  @override
  String get catEngine => 'Motore';

  @override
  String get catExterior => 'Esterno';

  @override
  String get catInterior => 'Interni';

  @override
  String get catSuspension => 'Sospensioni';

  @override
  String get catAudio => 'Audio';

  @override
  String get catElectronic => 'Elettronica';

  @override
  String get catBrakes => 'Freni';

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get noPhotos => 'Nessuna foto';

  @override
  String photoCounter(int count, int max) {
    return 'Foto $count di $max';
  }

  @override
  String uploadError(String msg) {
    return 'Errore di caricamento: $msg';
  }

  @override
  String get notificationsTitle => 'Notifiche e avvisi';

  @override
  String get noNotifications => 'Nessuna notifica';

  @override
  String get allInOrder => 'Va tutto bene!';

  @override
  String get checkNow => 'Controlla ora';

  @override
  String get checkDocuments => 'Controlla documenti';

  @override
  String get markRead => 'Segna come letto';

  @override
  String get markAllRead => 'Segna tutto come letto';

  @override
  String unreadCount(int count) {
    return '$count notifiche non lette';
  }

  @override
  String get administration => 'Amministrazione';

  @override
  String get users => 'Utenti';

  @override
  String accountsCount(int count) {
    return '$count account';
  }

  @override
  String get reload => 'Ricarica';

  @override
  String get accountActive => 'Account attivo';

  @override
  String get accountActiveHint => 'L\'utente può accedere';

  @override
  String get inactive => 'Inattivo';

  @override
  String get role => 'Ruolo';

  @override
  String get subscription => 'Abbonamento';

  @override
  String get carLimit => 'Limite auto';

  @override
  String createdOn(String name) {
    return 'Creato: $name';
  }

  @override
  String docsShort(int count) {
    return '$count doc.';
  }

  @override
  String get deleteUser => 'Elimina utente';

  @override
  String deleteUserConfirm(String name) {
    return 'Eliminare l\'account di \"$name\"?\n\nTutte le sue auto e i documenti verranno rimossi definitivamente.';
  }

  @override
  String userDeleted(String name) {
    return 'L\'account \"$name\" è stato eliminato.';
  }

  @override
  String get userUpdated => 'Utente aggiornato con successo!';

  @override
  String get carDetails => 'Dettagli auto';

  @override
  String get documents => 'Documenti';

  @override
  String get info => 'Info';

  @override
  String get tapForDetails => 'Tocca per i dettagli';

  @override
  String get engineCapacity => 'Cilindrata';

  @override
  String get enginePower => 'Potenza';

  @override
  String get fuelType => 'Carburante';

  @override
  String get color => 'Colore';

  @override
  String get mileage => 'Chilometraggio';

  @override
  String get nickname => 'Soprannome (facoltativo)';

  @override
  String get saveCar => 'Salva auto';

  @override
  String get carAdded => 'Auto aggiunta!';

  @override
  String get invalidYear => 'Anno non valido';

  @override
  String get saveError => 'Errore durante il salvataggio';

  @override
  String get fuelPetrol => 'Benzina';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Ibrido';

  @override
  String get fuelElectric => 'Elettrico';

  @override
  String get fuelLpg => 'GPL';

  @override
  String addOf(String name) {
    return 'Aggiungi $name';
  }

  @override
  String editOf(String name) {
    return 'Modifica $name';
  }

  @override
  String expiresOnDate(String name) {
    return 'Scade: $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Prossimo: $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Prossimo intervento: $name';
  }

  @override
  String atKm(String name) {
    return 'A: $name km';
  }

  @override
  String get scanComplete => 'Scansione completata! Controlla i dati.';

  @override
  String get hintNickname => 'es. La mia Dacia';

  @override
  String get hintCity => 'Bucarest';

  @override
  String get hintAddress => 'Via Esempio 1, Bucarest';

  @override
  String get hintPerformedBy => 'Officina / persona';

  @override
  String get errNoConnection =>
      'Impossibile raggiungere il server. Controlla la connessione.';

  @override
  String get errServerDown =>
      'Server non disponibile. Verifica che il backend sia attivo.';

  @override
  String get errAccountDisabled =>
      'Il tuo account è stato disattivato. Contatta l\'assistenza.';

  @override
  String get errBadCredentials => 'Email o password errati.';

  @override
  String get errInvalidData => 'Dati non validi. Controlla i campi.';

  @override
  String get errForbidden => 'Non hai i permessi per questa azione.';

  @override
  String get errNotFound => 'Risorsa non trovata.';

  @override
  String get errServer => 'Errore del server. Riprova.';

  @override
  String errWithCode(String name) {
    return 'Si è verificato un errore (codice $name).';
  }

  @override
  String get errUnexpected => 'Si è verificato un errore imprevisto.';

  @override
  String get updateAvailable => 'Aggiornamento disponibile';

  @override
  String get updateRequired => 'Aggiornamento obbligatorio';

  @override
  String get newVersion => 'Nuova versione: ';

  @override
  String get whatsNew => 'Novità:';

  @override
  String get updateNow => 'Aggiorna ora';

  @override
  String get later => 'Più tardi';

  @override
  String get downloadingUpdate => 'Download dell\'aggiornamento';

  @override
  String get updateMandatory =>
      'Questa versione non è più supportata. L\'aggiornamento è obbligatorio.';

  @override
  String get downloadFailed =>
      'Download non riuscito. Controlla la connessione e riprova.';

  @override
  String get integrityFailed =>
      'Verifica di integrità non riuscita — il file è danneggiato o modificato. Installazione annullata.';

  @override
  String get updateError => 'Errore di aggiornamento';

  @override
  String get fieldsAutoFilled =>
      'I campi sono stati compilati automaticamente. Salvare o controllare prima?';

  @override
  String daysSuffix(int count) {
    return '$count giorni';
  }

  @override
  String get hintInterventionDetails => 'Dettagli dell\'intervento...';

  @override
  String get scanDocument => 'Scansiona documento';

  @override
  String get photographDocument => 'Fotografa il documento';

  @override
  String get cameraOrGallery => 'Fotocamera / Galleria';

  @override
  String get selectImage => 'Seleziona immagine';

  @override
  String get selectExistingPhoto => 'Scegli una foto esistente';

  @override
  String get selectImageSource => 'Scegli la sorgente';

  @override
  String get scanHintCamera =>
      'Fotografa o scegli il documento per la compilazione automatica.';

  @override
  String get scanHintGallery =>
      'Seleziona un\'immagine del documento per compilare i campi.';

  @override
  String get processing => 'Elaborazione...';

  @override
  String get checkingKnownServer => 'Verifica del server noto...';

  @override
  String get privacyOptions => 'Opzioni sulla privacy';

  @override
  String get privacyOptionsHint =>
      'Gestisci la scelta sugli annunci personalizzati';
}
