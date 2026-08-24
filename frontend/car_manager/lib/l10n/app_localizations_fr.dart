// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get update => 'Mettre à jour';

  @override
  String get retry => 'Réessayer';

  @override
  String get error => 'Erreur';

  @override
  String errorWith(String msg) {
    return 'Erreur : $msg';
  }

  @override
  String get required => 'Obligatoire';

  @override
  String get optional => 'facultatif';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Remarques...';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get city => 'Ville';

  @override
  String get cost => 'Coût (RON)';

  @override
  String get invoiceNr => 'N° facture';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connecte-toi pour continuer';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get register => 'Créer un compte';

  @override
  String get noAccount => 'Pas de compte ? ';

  @override
  String get haveAccount => 'Déjà un compte ? ';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phone => 'Téléphone';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get invalidEmail => 'Adresse e-mail invalide';

  @override
  String get passwordTooShort => 'Au moins 8 caractères';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get newAccount => 'Nouveau compte';

  @override
  String get fillDetails => 'Remplis les informations ci-dessous';

  @override
  String get minChars3 => 'Au moins 3 caractères';

  @override
  String get phoneOptional => 'Téléphone (facultatif)';

  @override
  String get passwordRulesHint => 'Min. 8 caractères, 1 majuscule, 1 chiffre';

  @override
  String get passwordNeedsUpper => 'Doit contenir au moins une majuscule';

  @override
  String get passwordNeedsDigit => 'Doit contenir au moins un chiffre';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCars => 'Voitures';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Démarrage du service...';

  @override
  String get searchingServer => 'Recherche du serveur...';

  @override
  String get connecting => 'Connexion...';

  @override
  String get checkingUpdates => 'Recherche de mises à jour...';

  @override
  String get connected => 'Connecté !';

  @override
  String get serverNotFound => 'Serveur introuvable';

  @override
  String get serverNotFoundHintMobile =>
      'Vérifie que ton ordinateur est allumé et connecté au même réseau Wi-Fi.';

  @override
  String get serverNotFoundHintDesktop =>
      'Vérifie que l\'application est correctement installée et réessaie.';

  @override
  String get searchAgain => 'Rechercher à nouveau';

  @override
  String greeting(String name) {
    return 'Salut, $name ! 👋';
  }

  @override
  String get myCars => 'Mes voitures';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get statActiveAlerts => 'Alertes actives';

  @override
  String get statExpired => 'Expirés';

  @override
  String get addFirstCar => 'Ajoute ta première voiture';

  @override
  String get noCarsYet => 'Aucune voiture ajoutée';

  @override
  String get noCarsHint =>
      'Ajoute ta première voiture pour gérer tous ses documents';

  @override
  String get addCar => 'Ajouter une voiture';

  @override
  String carsCount(int count, int max) {
    return '$count/$max voitures';
  }

  @override
  String get deleteCar => 'Supprimer la voiture';

  @override
  String deleteCarConfirm(String name) {
    return 'Supprimer « $name » ? Toutes les données associées seront effacées.';
  }

  @override
  String get language => 'Langue';

  @override
  String get languageChoose => 'Choisir la langue';
}
