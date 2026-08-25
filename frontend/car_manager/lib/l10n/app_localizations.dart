import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hu'),
    Locale('it'),
    Locale('ro')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CarRecords'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorWith.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String errorWith(String msg);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Remarks...'**
  String get notesHint;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost (RON)'**
  String get cost;

  /// No description provided for @invoiceNr.
  ///
  /// In en, this message translates to:
  /// **'Invoice no.'**
  String get invoiceNr;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? '**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get newAccount;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below'**
  String get fillDetails;

  /// No description provided for @minChars3.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get minChars3;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @passwordRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters, 1 uppercase, 1 digit'**
  String get passwordRulesHint;

  /// No description provided for @passwordNeedsUpper.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least one uppercase letter'**
  String get passwordNeedsUpper;

  /// No description provided for @passwordNeedsDigit.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least one digit'**
  String get passwordNeedsDigit;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the address you signed up with. We will email you a link for setting a new password.'**
  String get resetPasswordHint;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, the link is on its way. Check your inbox.'**
  String resetLinkSent(String email);

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email address not confirmed'**
  String get emailNotVerified;

  /// No description provided for @emailNotVerifiedHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm it so you can recover the account if you forget the password.'**
  String get emailNotVerifiedHint;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email address confirmed'**
  String get emailVerified;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Send confirmation link'**
  String get resendVerification;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation link sent. Check your inbox.'**
  String get verificationSent;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Removes the account and all its data, permanently.'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'All your cars, documents and alerts will be deleted. This cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Type your password to confirm'**
  String get deleteAccountPassword;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountButton;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'The account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get navCars;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @startingService.
  ///
  /// In en, this message translates to:
  /// **'Starting service...'**
  String get startingService;

  /// No description provided for @searchingServer.
  ///
  /// In en, this message translates to:
  /// **'Searching for the server...'**
  String get searchingServer;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @checkingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingUpdates;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected!'**
  String get connected;

  /// No description provided for @serverNotFound.
  ///
  /// In en, this message translates to:
  /// **'Server not found'**
  String get serverNotFound;

  /// No description provided for @serverNotFoundHintMobile.
  ///
  /// In en, this message translates to:
  /// **'Make sure your computer is on and connected to the same Wi-Fi network.'**
  String get serverNotFoundHintMobile;

  /// No description provided for @serverNotFoundHintDesktop.
  ///
  /// In en, this message translates to:
  /// **'Make sure the app is installed correctly and try again.'**
  String get serverNotFoundHintDesktop;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get searchAgain;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}! 👋'**
  String greeting(String name);

  /// No description provided for @myCars.
  ///
  /// In en, this message translates to:
  /// **'My cars'**
  String get myCars;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @statActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active alerts'**
  String get statActiveAlerts;

  /// No description provided for @statExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statExpired;

  /// No description provided for @addFirstCar.
  ///
  /// In en, this message translates to:
  /// **'Add your first car'**
  String get addFirstCar;

  /// No description provided for @noCarsYet.
  ///
  /// In en, this message translates to:
  /// **'No cars added yet'**
  String get noCarsYet;

  /// No description provided for @noCarsHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first car to keep track of all its documents'**
  String get noCarsHint;

  /// No description provided for @addCar.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get addCar;

  /// No description provided for @carsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} cars'**
  String carsCount(int count, int max);

  /// No description provided for @deleteCar.
  ///
  /// In en, this message translates to:
  /// **'Delete car'**
  String get deleteCar;

  /// No description provided for @deleteCarConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? All related data will be removed.'**
  String deleteCarConfirm(String name);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageChoose;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get generalInfo;

  /// No description provided for @technicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Technical details'**
  String get technicalDetails;

  /// No description provided for @validFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid from'**
  String get validFrom;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get expiresOn;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get daysLeft;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceRon.
  ///
  /// In en, this message translates to:
  /// **'Price (RON)'**
  String get priceRon;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed: {msg}'**
  String scanFailed(String msg);

  /// No description provided for @extractedData.
  ///
  /// In en, this message translates to:
  /// **'Extracted data'**
  String get extractedData;

  /// No description provided for @noDataExtracted.
  ///
  /// In en, this message translates to:
  /// **'Could not read any data from the image automatically.'**
  String get noDataExtracted;

  /// No description provided for @detectedText.
  ///
  /// In en, this message translates to:
  /// **'Detected text:'**
  String get detectedText;

  /// No description provided for @checkFirst.
  ///
  /// In en, this message translates to:
  /// **'Review first'**
  String get checkFirst;

  /// No description provided for @saveDirectly.
  ///
  /// In en, this message translates to:
  /// **'Save directly'**
  String get saveDirectly;

  /// No description provided for @deleteConfirmGeneric.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteConfirmGeneric(String name);

  /// No description provided for @vignettes.
  ///
  /// In en, this message translates to:
  /// **'Vignettes'**
  String get vignettes;

  /// No description provided for @vignette.
  ///
  /// In en, this message translates to:
  /// **'Vignette'**
  String get vignette;

  /// No description provided for @addVignette.
  ///
  /// In en, this message translates to:
  /// **'Add vignette'**
  String get addVignette;

  /// No description provided for @editVignette.
  ///
  /// In en, this message translates to:
  /// **'Edit vignette'**
  String get editVignette;

  /// No description provided for @saveVignette.
  ///
  /// In en, this message translates to:
  /// **'Save vignette'**
  String get saveVignette;

  /// No description provided for @vignetteAdded.
  ///
  /// In en, this message translates to:
  /// **'Vignette added!'**
  String get vignetteAdded;

  /// No description provided for @vignetteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vignette updated!'**
  String get vignetteUpdated;

  /// No description provided for @noVignettes.
  ///
  /// In en, this message translates to:
  /// **'No vignettes added'**
  String get noVignettes;

  /// No description provided for @deleteVignette.
  ///
  /// In en, this message translates to:
  /// **'Delete vignette'**
  String get deleteVignette;

  /// No description provided for @deleteVignetteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vignette?'**
  String get deleteVignetteConfirm;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get purchaseDate;

  /// No description provided for @validityPeriod.
  ///
  /// In en, this message translates to:
  /// **'Validity period *'**
  String get validityPeriod;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// No description provided for @issuerCompany.
  ///
  /// In en, this message translates to:
  /// **'Issuing company'**
  String get issuerCompany;

  /// No description provided for @invoiceSeries.
  ///
  /// In en, this message translates to:
  /// **'Invoice series'**
  String get invoiceSeries;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @addInsurance.
  ///
  /// In en, this message translates to:
  /// **'Add insurance'**
  String get addInsurance;

  /// No description provided for @saveInsurance.
  ///
  /// In en, this message translates to:
  /// **'Save insurance'**
  String get saveInsurance;

  /// No description provided for @insuranceAdded.
  ///
  /// In en, this message translates to:
  /// **'Insurance added!'**
  String get insuranceAdded;

  /// No description provided for @insuranceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Insurance updated!'**
  String get insuranceUpdated;

  /// No description provided for @noInsurance.
  ///
  /// In en, this message translates to:
  /// **'No insurance added'**
  String get noInsurance;

  /// No description provided for @deleteInsurance.
  ///
  /// In en, this message translates to:
  /// **'Delete insurance'**
  String get deleteInsurance;

  /// No description provided for @insurerCompany.
  ///
  /// In en, this message translates to:
  /// **'Insurance company *'**
  String get insurerCompany;

  /// No description provided for @policyNumber.
  ///
  /// In en, this message translates to:
  /// **'Policy no.'**
  String get policyNumber;

  /// No description provided for @premiumRon.
  ///
  /// In en, this message translates to:
  /// **'Premium (RON)'**
  String get premiumRon;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @deductibleRon.
  ///
  /// In en, this message translates to:
  /// **'Deductible (RON)'**
  String get deductibleRon;

  /// No description provided for @paymentFrequency.
  ///
  /// In en, this message translates to:
  /// **'Payment frequency'**
  String get paymentFrequency;

  /// No description provided for @purchasedOn.
  ///
  /// In en, this message translates to:
  /// **'Purchased on'**
  String get purchasedOn;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Agent name'**
  String get agentName;

  /// No description provided for @agentPhone.
  ///
  /// In en, this message translates to:
  /// **'Agent phone'**
  String get agentPhone;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// No description provided for @roadsideAssistance.
  ///
  /// In en, this message translates to:
  /// **'Roadside assistance'**
  String get roadsideAssistance;

  /// No description provided for @roadsideIncluded.
  ///
  /// In en, this message translates to:
  /// **'Roadside assistance included'**
  String get roadsideIncluded;

  /// No description provided for @included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get included;

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqMonthly;

  /// No description provided for @freqQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get freqQuarterly;

  /// No description provided for @freqBiannual.
  ///
  /// In en, this message translates to:
  /// **'Every 6 months'**
  String get freqBiannual;

  /// No description provided for @freqAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annually'**
  String get freqAnnual;

  /// No description provided for @registrationDoc.
  ///
  /// In en, this message translates to:
  /// **'Registration & Inspection'**
  String get registrationDoc;

  /// No description provided for @registrationShort.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get registrationShort;

  /// No description provided for @addRegistration.
  ///
  /// In en, this message translates to:
  /// **'Add registration'**
  String get addRegistration;

  /// No description provided for @editRegistration.
  ///
  /// In en, this message translates to:
  /// **'Edit registration'**
  String get editRegistration;

  /// No description provided for @registrationAdded.
  ///
  /// In en, this message translates to:
  /// **'Registration added!'**
  String get registrationAdded;

  /// No description provided for @registrationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Registration updated!'**
  String get registrationUpdated;

  /// No description provided for @noRegistration.
  ///
  /// In en, this message translates to:
  /// **'No registration added'**
  String get noRegistration;

  /// No description provided for @deleteRegistration.
  ///
  /// In en, this message translates to:
  /// **'Delete registration'**
  String get deleteRegistration;

  /// No description provided for @deleteRegistrationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this registration?'**
  String get deleteRegistrationConfirm;

  /// No description provided for @vehicleData.
  ///
  /// In en, this message translates to:
  /// **'Vehicle data'**
  String get vehicleData;

  /// No description provided for @registrationAndItp.
  ///
  /// In en, this message translates to:
  /// **'Registration & Inspection'**
  String get registrationAndItp;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @manufacturingYear.
  ///
  /// In en, this message translates to:
  /// **'Year of manufacture'**
  String get manufacturingYear;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration no.'**
  String get plateNumber;

  /// No description provided for @vin.
  ///
  /// In en, this message translates to:
  /// **'Chassis number (VIN)'**
  String get vin;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner name'**
  String get ownerName;

  /// No description provided for @ownerAddress.
  ///
  /// In en, this message translates to:
  /// **'Owner address'**
  String get ownerAddress;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @registrationDate.
  ///
  /// In en, this message translates to:
  /// **'Registration date'**
  String get registrationDate;

  /// No description provided for @itpExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Inspection expiry date'**
  String get itpExpiryDate;

  /// No description provided for @itpExpires.
  ///
  /// In en, this message translates to:
  /// **'Inspection expires'**
  String get itpExpires;

  /// No description provided for @itpValid.
  ///
  /// In en, this message translates to:
  /// **'Inspection valid'**
  String get itpValid;

  /// No description provided for @itpExpired.
  ///
  /// In en, this message translates to:
  /// **'Inspection expired!'**
  String get itpExpired;

  /// No description provided for @ocrFieldsFilled.
  ///
  /// In en, this message translates to:
  /// **'{count} fields filled from the scan — check them before saving.'**
  String ocrFieldsFilled(int count);

  /// No description provided for @scanned.
  ///
  /// In en, this message translates to:
  /// **'scanned'**
  String get scanned;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Service & Maintenance'**
  String get maintenance;

  /// No description provided for @maintenanceShort.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get maintenanceShort;

  /// No description provided for @addMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get addMaintenance;

  /// No description provided for @editMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editMaintenance;

  /// No description provided for @maintenanceAdded.
  ///
  /// In en, this message translates to:
  /// **'Service recorded!'**
  String get maintenanceAdded;

  /// No description provided for @maintenanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Service updated!'**
  String get maintenanceUpdated;

  /// No description provided for @noMaintenance.
  ///
  /// In en, this message translates to:
  /// **'No service recorded'**
  String get noMaintenance;

  /// No description provided for @deleteMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteMaintenance;

  /// No description provided for @interventionType.
  ///
  /// In en, this message translates to:
  /// **'Service type *'**
  String get interventionType;

  /// No description provided for @performedDate.
  ///
  /// In en, this message translates to:
  /// **'Date performed *'**
  String get performedDate;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @mileageAtService.
  ///
  /// In en, this message translates to:
  /// **'Mileage at service'**
  String get mileageAtService;

  /// No description provided for @nextService.
  ///
  /// In en, this message translates to:
  /// **'Next service (optional)'**
  String get nextService;

  /// No description provided for @nextMileage.
  ///
  /// In en, this message translates to:
  /// **'Next mileage'**
  String get nextMileage;

  /// No description provided for @nextDate.
  ///
  /// In en, this message translates to:
  /// **'Next date'**
  String get nextDate;

  /// No description provided for @autoShop.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get autoShop;

  /// No description provided for @svcOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil change'**
  String get svcOilChange;

  /// No description provided for @svcFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get svcFilters;

  /// No description provided for @svcBrakePads.
  ///
  /// In en, this message translates to:
  /// **'Brake pads'**
  String get svcBrakePads;

  /// No description provided for @svcTyres.
  ///
  /// In en, this message translates to:
  /// **'Tyres'**
  String get svcTyres;

  /// No description provided for @svcTimingBelt.
  ///
  /// In en, this message translates to:
  /// **'Timing belt'**
  String get svcTimingBelt;

  /// No description provided for @svcAltBelt.
  ///
  /// In en, this message translates to:
  /// **'Alternator belt'**
  String get svcAltBelt;

  /// No description provided for @svcBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get svcBattery;

  /// No description provided for @svcShocks.
  ///
  /// In en, this message translates to:
  /// **'Shock absorbers'**
  String get svcShocks;

  /// No description provided for @svcSparkPlugs.
  ///
  /// In en, this message translates to:
  /// **'Spark plugs'**
  String get svcSparkPlugs;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @modifications.
  ///
  /// In en, this message translates to:
  /// **'Modifications'**
  String get modifications;

  /// No description provided for @addModification.
  ///
  /// In en, this message translates to:
  /// **'Add modification'**
  String get addModification;

  /// No description provided for @editModification.
  ///
  /// In en, this message translates to:
  /// **'Edit modification'**
  String get editModification;

  /// No description provided for @modificationAdded.
  ///
  /// In en, this message translates to:
  /// **'Modification added!'**
  String get modificationAdded;

  /// No description provided for @modificationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Modification updated!'**
  String get modificationUpdated;

  /// No description provided for @noModifications.
  ///
  /// In en, this message translates to:
  /// **'No modifications added'**
  String get noModifications;

  /// No description provided for @deleteModification.
  ///
  /// In en, this message translates to:
  /// **'Delete modification'**
  String get deleteModification;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get category;

  /// No description provided for @modDescription.
  ///
  /// In en, this message translates to:
  /// **'Modification description *'**
  String get modDescription;

  /// No description provided for @modificationDate.
  ///
  /// In en, this message translates to:
  /// **'Modification date (optional)'**
  String get modificationDate;

  /// No description provided for @performedBy.
  ///
  /// In en, this message translates to:
  /// **'Performed by'**
  String get performedBy;

  /// No description provided for @homologated.
  ///
  /// In en, this message translates to:
  /// **'Officially approved'**
  String get homologated;

  /// No description provided for @homologatedShort.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get homologatedShort;

  /// No description provided for @homologationNumber.
  ///
  /// In en, this message translates to:
  /// **'Approval no.'**
  String get homologationNumber;

  /// No description provided for @catEngine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get catEngine;

  /// No description provided for @catExterior.
  ///
  /// In en, this message translates to:
  /// **'Exterior'**
  String get catExterior;

  /// No description provided for @catInterior.
  ///
  /// In en, this message translates to:
  /// **'Interior'**
  String get catInterior;

  /// No description provided for @catSuspension.
  ///
  /// In en, this message translates to:
  /// **'Suspension'**
  String get catSuspension;

  /// No description provided for @catAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get catAudio;

  /// No description provided for @catElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get catElectronic;

  /// No description provided for @catBrakes.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get catBrakes;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos'**
  String get noPhotos;

  /// No description provided for @photoCounter.
  ///
  /// In en, this message translates to:
  /// **'Photo {count} of {max}'**
  String photoCounter(int count, int max);

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error: {msg}'**
  String uploadError(String msg);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Alerts'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @allInOrder.
  ///
  /// In en, this message translates to:
  /// **'Everything is in order!'**
  String get allInOrder;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @checkDocuments.
  ///
  /// In en, this message translates to:
  /// **'Check documents'**
  String get checkDocuments;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread notifications'**
  String unreadCount(int count);

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @accountsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts'**
  String accountsCount(int count);

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @accountActive.
  ///
  /// In en, this message translates to:
  /// **'Account active'**
  String get accountActive;

  /// No description provided for @accountActiveHint.
  ///
  /// In en, this message translates to:
  /// **'The user can sign in'**
  String get accountActiveHint;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @carLimit.
  ///
  /// In en, this message translates to:
  /// **'Car limit'**
  String get carLimit;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created: {name}'**
  String createdOn(String name);

  /// No description provided for @docsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} docs'**
  String docsShort(int count);

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get deleteUser;

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the account of \"{name}\"?\n\nAll their cars and documents will be permanently removed.'**
  String deleteUserConfirm(String name);

  /// No description provided for @userDeleted.
  ///
  /// In en, this message translates to:
  /// **'The account \"{name}\" has been deleted.'**
  String userDeleted(String name);

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully!'**
  String get userUpdated;

  /// No description provided for @carDetails.
  ///
  /// In en, this message translates to:
  /// **'Car details'**
  String get carDetails;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetails;

  /// No description provided for @engineCapacity.
  ///
  /// In en, this message translates to:
  /// **'Engine size'**
  String get engineCapacity;

  /// No description provided for @enginePower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get enginePower;

  /// No description provided for @fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get fuelType;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get color;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get mileage;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname (optional)'**
  String get nickname;

  /// No description provided for @saveCar.
  ///
  /// In en, this message translates to:
  /// **'Save car'**
  String get saveCar;

  /// No description provided for @carAdded.
  ///
  /// In en, this message translates to:
  /// **'Car added!'**
  String get carAdded;

  /// No description provided for @invalidYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid year'**
  String get invalidYear;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Error while saving'**
  String get saveError;

  /// No description provided for @fuelPetrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get fuelPetrol;

  /// No description provided for @fuelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get fuelDiesel;

  /// No description provided for @fuelHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get fuelHybrid;

  /// No description provided for @fuelElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get fuelElectric;

  /// No description provided for @fuelLpg.
  ///
  /// In en, this message translates to:
  /// **'LPG'**
  String get fuelLpg;

  /// No description provided for @addOf.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addOf(String name);

  /// No description provided for @editOf.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editOf(String name);

  /// No description provided for @expiresOnDate.
  ///
  /// In en, this message translates to:
  /// **'Expires: {name}'**
  String expiresOnDate(String name);

  /// No description provided for @nextAtKm.
  ///
  /// In en, this message translates to:
  /// **'Next: {name} km'**
  String nextAtKm(String name);

  /// No description provided for @nextServiceOn.
  ///
  /// In en, this message translates to:
  /// **'Next service: {name}'**
  String nextServiceOn(String name);

  /// No description provided for @atKm.
  ///
  /// In en, this message translates to:
  /// **'At: {name} km'**
  String atKm(String name);

  /// No description provided for @scanComplete.
  ///
  /// In en, this message translates to:
  /// **'Scan complete! Please check the data.'**
  String get scanComplete;

  /// No description provided for @hintNickname.
  ///
  /// In en, this message translates to:
  /// **'e.g. My little Dacia'**
  String get hintNickname;

  /// No description provided for @hintCity.
  ///
  /// In en, this message translates to:
  /// **'Bucharest'**
  String get hintCity;

  /// No description provided for @hintAddress.
  ///
  /// In en, this message translates to:
  /// **'1 Example St., Bucharest'**
  String get hintAddress;

  /// No description provided for @hintPerformedBy.
  ///
  /// In en, this message translates to:
  /// **'Garage / person'**
  String get hintPerformedBy;

  /// No description provided for @errNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your connection.'**
  String get errNoConnection;

  /// No description provided for @errServerDown.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable. Make sure the backend is running.'**
  String get errServerDown;

  /// No description provided for @errAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Please contact support.'**
  String get errAccountDisabled;

  /// No description provided for @errBadCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get errBadCredentials;

  /// No description provided for @errInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Invalid data. Please check the fields.'**
  String get errInvalidData;

  /// No description provided for @errForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errForbidden;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errNotFound;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in a few minutes.'**
  String get errTooManyAttempts;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get errServer;

  /// No description provided for @errWithCode.
  ///
  /// In en, this message translates to:
  /// **'An error occurred (code {name}).'**
  String errWithCode(String name);

  /// No description provided for @errUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errUnexpected;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequired;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New version: '**
  String get newVersion;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get whatsNew;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading the update'**
  String get downloadingUpdate;

  /// No description provided for @updateMandatory.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Updating is required.'**
  String get updateMandatory;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection and try again.'**
  String get downloadFailed;

  /// No description provided for @integrityFailed.
  ///
  /// In en, this message translates to:
  /// **'Integrity check failed — the downloaded file is corrupt or modified. Installation cancelled.'**
  String get integrityFailed;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error'**
  String get updateError;

  /// No description provided for @fieldsAutoFilled.
  ///
  /// In en, this message translates to:
  /// **'The fields were filled automatically. Save now or review first?'**
  String get fieldsAutoFilled;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysSuffix(int count);

  /// No description provided for @hintInterventionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details of the work...'**
  String get hintInterventionDetails;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocument;

  /// No description provided for @photographDocument.
  ///
  /// In en, this message translates to:
  /// **'Photograph the document'**
  String get photographDocument;

  /// No description provided for @cameraOrGallery.
  ///
  /// In en, this message translates to:
  /// **'Camera / Gallery'**
  String get cameraOrGallery;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get selectImage;

  /// No description provided for @selectExistingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing photo'**
  String get selectExistingPhoto;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get selectImageSource;

  /// No description provided for @scanHintCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or pick one to fill the fields automatically.'**
  String get scanHintCamera;

  /// No description provided for @scanHintGallery.
  ///
  /// In en, this message translates to:
  /// **'Select an image of the document to fill the fields automatically.'**
  String get scanHintGallery;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @checkingKnownServer.
  ///
  /// In en, this message translates to:
  /// **'Checking the known server...'**
  String get checkingKnownServer;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get privacyOptions;

  /// No description provided for @privacyOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Manage your choice about personalised ads'**
  String get privacyOptionsHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hu',
        'it',
        'ro'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hu':
      return AppLocalizationsHu();
    case 'it':
      return AppLocalizationsIt();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
