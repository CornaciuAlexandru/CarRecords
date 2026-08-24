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

  @override
  String get generalInfo => 'Informații generale';

  @override
  String get technicalDetails => 'Detalii tehnice';

  @override
  String get validFrom => 'Valabilă de la';

  @override
  String get expires => 'Expiră';

  @override
  String get expiresOn => 'Expiră la';

  @override
  String get daysLeft => 'Zile rămase';

  @override
  String get price => 'Preț';

  @override
  String get priceRon => 'Preț (RON)';

  @override
  String scanFailed(String msg) {
    return 'Scanare eșuată: $msg';
  }

  @override
  String get extractedData => 'Date extrase';

  @override
  String get noDataExtracted =>
      'Nu s-au putut extrage date automat din imagine.';

  @override
  String get detectedText => 'Text detectat:';

  @override
  String get checkFirst => 'Verifică mai întâi';

  @override
  String get saveDirectly => 'Salvează direct';

  @override
  String deleteConfirmGeneric(String name) {
    return 'Ștergi \"$name\"?';
  }

  @override
  String get vignettes => 'Roviniete';

  @override
  String get vignette => 'Rovinietă';

  @override
  String get addVignette => 'Adaugă rovinietă';

  @override
  String get editVignette => 'Editează rovinietă';

  @override
  String get saveVignette => 'Salvează rovinieta';

  @override
  String get vignetteAdded => 'Rovinietă adăugată!';

  @override
  String get vignetteUpdated => 'Rovinietă actualizată!';

  @override
  String get noVignettes => 'Nicio rovinietă adăugată';

  @override
  String get deleteVignette => 'Șterge rovinieta';

  @override
  String get deleteVignetteConfirm =>
      'Ești sigur că vrei să ștergi această rovinietă?';

  @override
  String get purchaseDate => 'Dată cumpărare';

  @override
  String get validityPeriod => 'Perioadă valabilitate *';

  @override
  String get period => 'Perioadă';

  @override
  String get issuer => 'Emitent';

  @override
  String get issuerCompany => 'Firma emitentă';

  @override
  String get invoiceSeries => 'Serie factură';

  @override
  String get insurance => 'Asigurări';

  @override
  String get addInsurance => 'Adaugă asigurare';

  @override
  String get saveInsurance => 'Salvează asigurarea';

  @override
  String get insuranceAdded => 'Asigurare adăugată!';

  @override
  String get insuranceUpdated => 'Asigurare actualizată!';

  @override
  String get noInsurance => 'Nicio asigurare adăugată';

  @override
  String get deleteInsurance => 'Șterge asigurarea';

  @override
  String get insurerCompany => 'Firma asigurătoare *';

  @override
  String get policyNumber => 'Nr. poliță';

  @override
  String get premiumRon => 'Primă (RON)';

  @override
  String get premium => 'Primă';

  @override
  String get deductibleRon => 'Franciză (RON)';

  @override
  String get paymentFrequency => 'Frecvență plată';

  @override
  String get purchasedOn => 'Cumpărată la';

  @override
  String get agentName => 'Numele agentului';

  @override
  String get agentPhone => 'Telefon agent';

  @override
  String get agent => 'Agent';

  @override
  String get roadsideAssistance => 'Asistență rutieră';

  @override
  String get roadsideIncluded => 'Asistență rutieră inclusă';

  @override
  String get included => 'Inclusă';

  @override
  String get freqMonthly => 'Lunar';

  @override
  String get freqQuarterly => 'Trimestrial';

  @override
  String get freqBiannual => 'Semestrial';

  @override
  String get freqAnnual => 'Anual';

  @override
  String get registrationDoc => 'Talon & ITP';

  @override
  String get registrationShort => 'Talon';

  @override
  String get addRegistration => 'Adaugă Talon / ITP';

  @override
  String get editRegistration => 'Editează talon';

  @override
  String get registrationAdded => 'Talon adăugat!';

  @override
  String get registrationUpdated => 'Talon actualizat!';

  @override
  String get noRegistration => 'Niciun talon adăugat';

  @override
  String get deleteRegistration => 'Șterge talonul';

  @override
  String get deleteRegistrationConfirm =>
      'Ești sigur că vrei să ștergi acest talon?';

  @override
  String get vehicleData => 'Date vehicul';

  @override
  String get registrationAndItp => 'Înmatriculare & ITP';

  @override
  String get brand => 'Marcă';

  @override
  String get model => 'Model';

  @override
  String get manufacturingYear => 'An fabricație';

  @override
  String get plateNumber => 'Nr. înmatriculare';

  @override
  String get vin => 'Serie șasiu (VIN)';

  @override
  String get ownerName => 'Nume proprietar';

  @override
  String get ownerAddress => 'Adresă proprietar';

  @override
  String get owner => 'Proprietar';

  @override
  String get address => 'Adresă';

  @override
  String get registrationDate => 'Data înmatriculării';

  @override
  String get itpExpiryDate => 'Data expirare ITP';

  @override
  String get itpExpires => 'ITP expiră';

  @override
  String get itpValid => 'ITP valabil';

  @override
  String get itpExpired => 'ITP expirat!';

  @override
  String ocrFieldsFilled(int count) {
    return '$count câmpuri completate din scanare — verifică-le înainte de salvare.';
  }

  @override
  String get scanned => 'scanat';

  @override
  String get maintenance => 'Service & Mentenanță';

  @override
  String get maintenanceShort => 'Service';

  @override
  String get addMaintenance => 'Adaugă service';

  @override
  String get editMaintenance => 'Editează service';

  @override
  String get maintenanceAdded => 'Service înregistrat!';

  @override
  String get maintenanceUpdated => 'Service actualizat!';

  @override
  String get noMaintenance => 'Niciun serviciu înregistrat';

  @override
  String get deleteMaintenance => 'Șterge înregistrarea';

  @override
  String get interventionType => 'Tip intervenție *';

  @override
  String get performedDate => 'Data efectuării *';

  @override
  String get description => 'Descriere';

  @override
  String get mileageAtService => 'Km la service';

  @override
  String get nextService => 'Următor service (opțional)';

  @override
  String get nextMileage => 'Km următor';

  @override
  String get nextDate => 'Data următor';

  @override
  String get autoShop => 'Service auto';

  @override
  String get svcOilChange => 'Schimb ulei';

  @override
  String get svcFilters => 'Filtre';

  @override
  String get svcBrakePads => 'Plăcuțe frână';

  @override
  String get svcTyres => 'Anvelope';

  @override
  String get svcTimingBelt => 'Distribuție';

  @override
  String get svcAltBelt => 'Curea alternator';

  @override
  String get svcBattery => 'Baterie';

  @override
  String get svcShocks => 'Amortizoare';

  @override
  String get svcSparkPlugs => 'Bujii';

  @override
  String get other => 'Altul';

  @override
  String get modifications => 'Modificări';

  @override
  String get addModification => 'Adaugă modificare';

  @override
  String get editModification => 'Editează modificare';

  @override
  String get modificationAdded => 'Modificare adăugată!';

  @override
  String get modificationUpdated => 'Modificare actualizată!';

  @override
  String get noModifications => 'Nicio modificare adăugată';

  @override
  String get deleteModification => 'Șterge modificarea';

  @override
  String get category => 'Categorie *';

  @override
  String get modDescription => 'Descriere modificare *';

  @override
  String get modificationDate => 'Data modificării (opțional)';

  @override
  String get performedBy => 'Realizată de';

  @override
  String get homologated => 'Modificare omologată RAR';

  @override
  String get homologatedShort => 'Omologat';

  @override
  String get homologationNumber => 'Nr. omologare';

  @override
  String get catEngine => 'Motor';

  @override
  String get catExterior => 'Exterior';

  @override
  String get catInterior => 'Interior';

  @override
  String get catSuspension => 'Suspensie';

  @override
  String get catAudio => 'Audio';

  @override
  String get catElectronic => 'Electronic';

  @override
  String get catBrakes => 'Frâne';

  @override
  String get addPhoto => 'Adaugă poză';

  @override
  String get noPhotos => 'Fără poze';

  @override
  String photoCounter(int count, int max) {
    return 'Poza $count din $max';
  }

  @override
  String uploadError(String msg) {
    return 'Eroare upload: $msg';
  }

  @override
  String get notificationsTitle => 'Notificări & Alerte';

  @override
  String get noNotifications => 'Nicio notificare';

  @override
  String get allInOrder => 'Totul este în ordine!';

  @override
  String get checkNow => 'Verifică acum';

  @override
  String get checkDocuments => 'Verifică documente';

  @override
  String get markRead => 'Marchează citit';

  @override
  String get markAllRead => 'Marchează toate';

  @override
  String unreadCount(int count) {
    return '$count notificări necitite';
  }

  @override
  String get administration => 'Administrare';

  @override
  String get users => 'Utilizatori';

  @override
  String accountsCount(int count) {
    return '$count conturi';
  }

  @override
  String get reload => 'Reîncarcă';

  @override
  String get accountActive => 'Cont activ';

  @override
  String get accountActiveHint => 'Utilizatorul se poate conecta';

  @override
  String get inactive => 'Inactiv';

  @override
  String get role => 'Rol';

  @override
  String get subscription => 'Abonament';

  @override
  String get carLimit => 'Limită mașini';

  @override
  String createdOn(String name) {
    return 'Creat: $name';
  }

  @override
  String docsShort(int count) {
    return '$count doc.';
  }

  @override
  String get deleteUser => 'Șterge utilizatorul';

  @override
  String deleteUserConfirm(String name) {
    return 'Ești sigur că vrei să ștergi contul lui \"$name\"?\n\nToate mașinile și documentele asociate vor fi șterse permanent.';
  }

  @override
  String userDeleted(String name) {
    return 'Contul \"$name\" a fost șters.';
  }

  @override
  String get userUpdated => 'Utilizator actualizat cu succes!';

  @override
  String get carDetails => 'Detalii mașină';

  @override
  String get documents => 'Documente';

  @override
  String get info => 'Info';

  @override
  String get tapForDetails => 'Apasă pentru detalii';

  @override
  String get engineCapacity => 'Cilindree';

  @override
  String get enginePower => 'Putere';

  @override
  String get fuelType => 'Combustibil';

  @override
  String get color => 'Culoare';

  @override
  String get mileage => 'Kilometraj';

  @override
  String get nickname => 'Poreclă (opțional)';

  @override
  String get saveCar => 'Salvează mașina';

  @override
  String get carAdded => 'Mașina a fost adăugată!';

  @override
  String get invalidYear => 'An invalid';

  @override
  String get saveError => 'Eroare la salvare';

  @override
  String get fuelPetrol => 'Benzină';

  @override
  String get fuelDiesel => 'Motorină';

  @override
  String get fuelHybrid => 'Hibrid';

  @override
  String get fuelElectric => 'Electric';

  @override
  String get fuelLpg => 'GPL';

  @override
  String addOf(String name) {
    return 'Adaugă $name';
  }

  @override
  String editOf(String name) {
    return 'Editează $name';
  }

  @override
  String expiresOnDate(String name) {
    return 'Expiră: $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Următor: $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Următoarea revizie: $name';
  }

  @override
  String atKm(String name) {
    return 'La: $name km';
  }

  @override
  String get scanComplete => 'Scanare completă! Verificați datele.';

  @override
  String get hintNickname => 'Ex: Daciuța mea';

  @override
  String get hintCity => 'București';

  @override
  String get hintAddress => 'Str. Exemplu, nr. 1, București';

  @override
  String get hintPerformedBy => 'Service / Persoană';

  @override
  String get hintInterventionDetails => 'Detalii intervenție...';
}
