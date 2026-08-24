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
}
