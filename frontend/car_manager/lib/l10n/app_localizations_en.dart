// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get retry => 'Try again';

  @override
  String get error => 'Error';

  @override
  String errorWith(String msg) {
    return 'Error: $msg';
  }

  @override
  String get required => 'Required';

  @override
  String get optional => 'optional';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Remarks...';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get city => 'City';

  @override
  String get cost => 'Cost (RON)';

  @override
  String get invoiceNr => 'Invoice no.';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign in';

  @override
  String get register => 'Create account';

  @override
  String get noAccount => 'No account? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get logout => 'Sign out';

  @override
  String get newAccount => 'New account';

  @override
  String get fillDetails => 'Fill in the details below';

  @override
  String get minChars3 => 'At least 3 characters';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get passwordRulesHint => 'Min. 8 characters, 1 uppercase, 1 digit';

  @override
  String get passwordNeedsUpper => 'Must contain at least one uppercase letter';

  @override
  String get passwordNeedsDigit => 'Must contain at least one digit';

  @override
  String get navHome => 'Home';

  @override
  String get navCars => 'Cars';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Starting service...';

  @override
  String get searchingServer => 'Searching for the server...';

  @override
  String get connecting => 'Connecting...';

  @override
  String get checkingUpdates => 'Checking for updates...';

  @override
  String get connected => 'Connected!';

  @override
  String get serverNotFound => 'Server not found';

  @override
  String get serverNotFoundHintMobile =>
      'Make sure your computer is on and connected to the same Wi-Fi network.';

  @override
  String get serverNotFoundHintDesktop =>
      'Make sure the app is installed correctly and try again.';

  @override
  String get searchAgain => 'Search again';

  @override
  String greeting(String name) {
    return 'Hi, $name! 👋';
  }

  @override
  String get myCars => 'My cars';

  @override
  String get viewAll => 'View all';

  @override
  String get statActiveAlerts => 'Active alerts';

  @override
  String get statExpired => 'Expired';

  @override
  String get addFirstCar => 'Add your first car';

  @override
  String get noCarsYet => 'No cars added yet';

  @override
  String get noCarsHint =>
      'Add your first car to keep track of all its documents';

  @override
  String get addCar => 'Add car';

  @override
  String carsCount(int count, int max) {
    return '$count/$max cars';
  }

  @override
  String get deleteCar => 'Delete car';

  @override
  String deleteCarConfirm(String name) {
    return 'Delete \"$name\"? All related data will be removed.';
  }

  @override
  String get language => 'Language';

  @override
  String get languageChoose => 'Choose language';

  @override
  String get generalInfo => 'General information';

  @override
  String get technicalDetails => 'Technical details';

  @override
  String get validFrom => 'Valid from';

  @override
  String get expires => 'Expires';

  @override
  String get expiresOn => 'Expires on';

  @override
  String get daysLeft => 'Days left';

  @override
  String get price => 'Price';

  @override
  String get priceRon => 'Price (RON)';

  @override
  String scanFailed(String msg) {
    return 'Scan failed: $msg';
  }

  @override
  String get extractedData => 'Extracted data';

  @override
  String get noDataExtracted =>
      'Could not read any data from the image automatically.';

  @override
  String get detectedText => 'Detected text:';

  @override
  String get checkFirst => 'Review first';

  @override
  String get saveDirectly => 'Save directly';

  @override
  String deleteConfirmGeneric(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get vignettes => 'Vignettes';

  @override
  String get vignette => 'Vignette';

  @override
  String get addVignette => 'Add vignette';

  @override
  String get editVignette => 'Edit vignette';

  @override
  String get saveVignette => 'Save vignette';

  @override
  String get vignetteAdded => 'Vignette added!';

  @override
  String get vignetteUpdated => 'Vignette updated!';

  @override
  String get noVignettes => 'No vignettes added';

  @override
  String get deleteVignette => 'Delete vignette';

  @override
  String get deleteVignetteConfirm =>
      'Are you sure you want to delete this vignette?';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get validityPeriod => 'Validity period *';

  @override
  String get period => 'Period';

  @override
  String get issuer => 'Issuer';

  @override
  String get issuerCompany => 'Issuing company';

  @override
  String get invoiceSeries => 'Invoice series';

  @override
  String get insurance => 'Insurance';

  @override
  String get addInsurance => 'Add insurance';

  @override
  String get saveInsurance => 'Save insurance';

  @override
  String get insuranceAdded => 'Insurance added!';

  @override
  String get insuranceUpdated => 'Insurance updated!';

  @override
  String get noInsurance => 'No insurance added';

  @override
  String get deleteInsurance => 'Delete insurance';

  @override
  String get insurerCompany => 'Insurance company *';

  @override
  String get policyNumber => 'Policy no.';

  @override
  String get premiumRon => 'Premium (RON)';

  @override
  String get premium => 'Premium';

  @override
  String get deductibleRon => 'Deductible (RON)';

  @override
  String get paymentFrequency => 'Payment frequency';

  @override
  String get purchasedOn => 'Purchased on';

  @override
  String get agentName => 'Agent name';

  @override
  String get agentPhone => 'Agent phone';

  @override
  String get agent => 'Agent';

  @override
  String get roadsideAssistance => 'Roadside assistance';

  @override
  String get roadsideIncluded => 'Roadside assistance included';

  @override
  String get included => 'Included';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqQuarterly => 'Quarterly';

  @override
  String get freqBiannual => 'Every 6 months';

  @override
  String get freqAnnual => 'Annually';

  @override
  String get registrationDoc => 'Registration & Inspection';

  @override
  String get registrationShort => 'Registration';

  @override
  String get addRegistration => 'Add registration';

  @override
  String get editRegistration => 'Edit registration';

  @override
  String get registrationAdded => 'Registration added!';

  @override
  String get registrationUpdated => 'Registration updated!';

  @override
  String get noRegistration => 'No registration added';

  @override
  String get deleteRegistration => 'Delete registration';

  @override
  String get deleteRegistrationConfirm =>
      'Are you sure you want to delete this registration?';

  @override
  String get vehicleData => 'Vehicle data';

  @override
  String get registrationAndItp => 'Registration & Inspection';

  @override
  String get brand => 'Make';

  @override
  String get model => 'Model';

  @override
  String get manufacturingYear => 'Year of manufacture';

  @override
  String get plateNumber => 'Registration no.';

  @override
  String get vin => 'Chassis number (VIN)';

  @override
  String get ownerName => 'Owner name';

  @override
  String get ownerAddress => 'Owner address';

  @override
  String get owner => 'Owner';

  @override
  String get address => 'Address';

  @override
  String get registrationDate => 'Registration date';

  @override
  String get itpExpiryDate => 'Inspection expiry date';

  @override
  String get itpExpires => 'Inspection expires';

  @override
  String get itpValid => 'Inspection valid';

  @override
  String get itpExpired => 'Inspection expired!';

  @override
  String ocrFieldsFilled(int count) {
    return '$count fields filled from the scan — check them before saving.';
  }

  @override
  String get scanned => 'scanned';

  @override
  String get maintenance => 'Service & Maintenance';

  @override
  String get maintenanceShort => 'Service';

  @override
  String get addMaintenance => 'Add service';

  @override
  String get editMaintenance => 'Edit service';

  @override
  String get maintenanceAdded => 'Service recorded!';

  @override
  String get maintenanceUpdated => 'Service updated!';

  @override
  String get noMaintenance => 'No service recorded';

  @override
  String get deleteMaintenance => 'Delete record';

  @override
  String get interventionType => 'Service type *';

  @override
  String get performedDate => 'Date performed *';

  @override
  String get description => 'Description';

  @override
  String get mileageAtService => 'Mileage at service';

  @override
  String get nextService => 'Next service (optional)';

  @override
  String get nextMileage => 'Next mileage';

  @override
  String get nextDate => 'Next date';

  @override
  String get autoShop => 'Garage';

  @override
  String get svcOilChange => 'Oil change';

  @override
  String get svcFilters => 'Filters';

  @override
  String get svcBrakePads => 'Brake pads';

  @override
  String get svcTyres => 'Tyres';

  @override
  String get svcTimingBelt => 'Timing belt';

  @override
  String get svcAltBelt => 'Alternator belt';

  @override
  String get svcBattery => 'Battery';

  @override
  String get svcShocks => 'Shock absorbers';

  @override
  String get svcSparkPlugs => 'Spark plugs';

  @override
  String get other => 'Other';

  @override
  String get modifications => 'Modifications';

  @override
  String get addModification => 'Add modification';

  @override
  String get editModification => 'Edit modification';

  @override
  String get modificationAdded => 'Modification added!';

  @override
  String get modificationUpdated => 'Modification updated!';

  @override
  String get noModifications => 'No modifications added';

  @override
  String get deleteModification => 'Delete modification';

  @override
  String get category => 'Category *';

  @override
  String get modDescription => 'Modification description *';

  @override
  String get modificationDate => 'Modification date (optional)';

  @override
  String get performedBy => 'Performed by';

  @override
  String get homologated => 'Officially approved';

  @override
  String get homologatedShort => 'Approved';

  @override
  String get homologationNumber => 'Approval no.';

  @override
  String get catEngine => 'Engine';

  @override
  String get catExterior => 'Exterior';

  @override
  String get catInterior => 'Interior';

  @override
  String get catSuspension => 'Suspension';

  @override
  String get catAudio => 'Audio';

  @override
  String get catElectronic => 'Electronics';

  @override
  String get catBrakes => 'Brakes';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get noPhotos => 'No photos';

  @override
  String photoCounter(int count, int max) {
    return 'Photo $count of $max';
  }

  @override
  String uploadError(String msg) {
    return 'Upload error: $msg';
  }

  @override
  String get notificationsTitle => 'Notifications & Alerts';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get allInOrder => 'Everything is in order!';

  @override
  String get checkNow => 'Check now';

  @override
  String get checkDocuments => 'Check documents';

  @override
  String get markRead => 'Mark as read';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String unreadCount(int count) {
    return '$count unread notifications';
  }

  @override
  String get administration => 'Administration';

  @override
  String get users => 'Users';

  @override
  String accountsCount(int count) {
    return '$count accounts';
  }

  @override
  String get reload => 'Reload';

  @override
  String get accountActive => 'Account active';

  @override
  String get accountActiveHint => 'The user can sign in';

  @override
  String get inactive => 'Inactive';

  @override
  String get role => 'Role';

  @override
  String get subscription => 'Subscription';

  @override
  String get carLimit => 'Car limit';

  @override
  String createdOn(String name) {
    return 'Created: $name';
  }

  @override
  String docsShort(int count) {
    return '$count docs';
  }

  @override
  String get deleteUser => 'Delete user';

  @override
  String deleteUserConfirm(String name) {
    return 'Delete the account of \"$name\"?\n\nAll their cars and documents will be permanently removed.';
  }

  @override
  String userDeleted(String name) {
    return 'The account \"$name\" has been deleted.';
  }

  @override
  String get userUpdated => 'User updated successfully!';

  @override
  String get carDetails => 'Car details';

  @override
  String get documents => 'Documents';

  @override
  String get info => 'Info';

  @override
  String get tapForDetails => 'Tap for details';

  @override
  String get engineCapacity => 'Engine size';

  @override
  String get enginePower => 'Power';

  @override
  String get fuelType => 'Fuel';

  @override
  String get color => 'Colour';

  @override
  String get mileage => 'Mileage';

  @override
  String get nickname => 'Nickname (optional)';

  @override
  String get saveCar => 'Save car';

  @override
  String get carAdded => 'Car added!';

  @override
  String get invalidYear => 'Invalid year';

  @override
  String get saveError => 'Error while saving';

  @override
  String get fuelPetrol => 'Petrol';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybrid';

  @override
  String get fuelElectric => 'Electric';

  @override
  String get fuelLpg => 'LPG';

  @override
  String addOf(String name) {
    return 'Add $name';
  }

  @override
  String editOf(String name) {
    return 'Edit $name';
  }

  @override
  String expiresOnDate(String name) {
    return 'Expires: $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Next: $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Next service: $name';
  }

  @override
  String atKm(String name) {
    return 'At: $name km';
  }

  @override
  String get scanComplete => 'Scan complete! Please check the data.';

  @override
  String get hintNickname => 'e.g. My little Dacia';

  @override
  String get hintCity => 'Bucharest';

  @override
  String get hintAddress => '1 Example St., Bucharest';

  @override
  String get hintPerformedBy => 'Garage / person';

  @override
  String get hintInterventionDetails => 'Details of the work...';
}
