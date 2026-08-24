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

  @override
  String get generalInfo => 'Informations générales';

  @override
  String get technicalDetails => 'Détails techniques';

  @override
  String get validFrom => 'Valable à partir du';

  @override
  String get expires => 'Expire';

  @override
  String get expiresOn => 'Expire le';

  @override
  String get daysLeft => 'Jours restants';

  @override
  String get price => 'Prix';

  @override
  String get priceRon => 'Prix (RON)';

  @override
  String scanFailed(String msg) {
    return 'Échec du scan : $msg';
  }

  @override
  String get extractedData => 'Données extraites';

  @override
  String get noDataExtracted =>
      'Impossible d\'extraire automatiquement des données de l\'image.';

  @override
  String get detectedText => 'Texte détecté :';

  @override
  String get checkFirst => 'Vérifier d\'abord';

  @override
  String get saveDirectly => 'Enregistrer directement';

  @override
  String deleteConfirmGeneric(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get vignettes => 'Vignettes';

  @override
  String get vignette => 'Vignette';

  @override
  String get addVignette => 'Ajouter une vignette';

  @override
  String get editVignette => 'Modifier la vignette';

  @override
  String get saveVignette => 'Enregistrer la vignette';

  @override
  String get vignetteAdded => 'Vignette ajoutée !';

  @override
  String get vignetteUpdated => 'Vignette mise à jour !';

  @override
  String get noVignettes => 'Aucune vignette ajoutée';

  @override
  String get deleteVignette => 'Supprimer la vignette';

  @override
  String get deleteVignetteConfirm =>
      'Veux-tu vraiment supprimer cette vignette ?';

  @override
  String get purchaseDate => 'Date d\'achat';

  @override
  String get validityPeriod => 'Période de validité *';

  @override
  String get period => 'Période';

  @override
  String get issuer => 'Émetteur';

  @override
  String get issuerCompany => 'Société émettrice';

  @override
  String get invoiceSeries => 'Série de facture';

  @override
  String get insurance => 'Assurances';

  @override
  String get addInsurance => 'Ajouter une assurance';

  @override
  String get saveInsurance => 'Enregistrer l\'assurance';

  @override
  String get insuranceAdded => 'Assurance ajoutée !';

  @override
  String get insuranceUpdated => 'Assurance mise à jour !';

  @override
  String get noInsurance => 'Aucune assurance ajoutée';

  @override
  String get deleteInsurance => 'Supprimer l\'assurance';

  @override
  String get insurerCompany => 'Compagnie d\'assurance *';

  @override
  String get policyNumber => 'N° de police';

  @override
  String get premiumRon => 'Prime (RON)';

  @override
  String get premium => 'Prime';

  @override
  String get deductibleRon => 'Franchise (RON)';

  @override
  String get paymentFrequency => 'Fréquence de paiement';

  @override
  String get purchasedOn => 'Achetée le';

  @override
  String get agentName => 'Nom de l\'agent';

  @override
  String get agentPhone => 'Téléphone de l\'agent';

  @override
  String get agent => 'Agent';

  @override
  String get roadsideAssistance => 'Assistance routière';

  @override
  String get roadsideIncluded => 'Assistance routière incluse';

  @override
  String get included => 'Incluse';

  @override
  String get freqMonthly => 'Mensuel';

  @override
  String get freqQuarterly => 'Trimestriel';

  @override
  String get freqBiannual => 'Semestriel';

  @override
  String get freqAnnual => 'Annuel';

  @override
  String get registrationDoc => 'Carte grise & Contrôle technique';

  @override
  String get registrationShort => 'Carte grise';

  @override
  String get addRegistration => 'Ajouter la carte grise';

  @override
  String get editRegistration => 'Modifier la carte grise';

  @override
  String get registrationAdded => 'Carte grise ajoutée !';

  @override
  String get registrationUpdated => 'Carte grise mise à jour !';

  @override
  String get noRegistration => 'Aucune carte grise ajoutée';

  @override
  String get deleteRegistration => 'Supprimer la carte grise';

  @override
  String get deleteRegistrationConfirm =>
      'Veux-tu vraiment supprimer cette carte grise ?';

  @override
  String get vehicleData => 'Données du véhicule';

  @override
  String get registrationAndItp => 'Immatriculation & Contrôle';

  @override
  String get brand => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get manufacturingYear => 'Année de fabrication';

  @override
  String get plateNumber => 'Immatriculation';

  @override
  String get vin => 'Numéro de châssis (VIN)';

  @override
  String get ownerName => 'Nom du propriétaire';

  @override
  String get ownerAddress => 'Adresse du propriétaire';

  @override
  String get owner => 'Propriétaire';

  @override
  String get address => 'Adresse';

  @override
  String get registrationDate => 'Date d\'immatriculation';

  @override
  String get itpExpiryDate => 'Expiration du contrôle technique';

  @override
  String get itpExpires => 'Contrôle technique expire';

  @override
  String get itpValid => 'Contrôle technique valide';

  @override
  String get itpExpired => 'Contrôle technique expiré !';

  @override
  String ocrFieldsFilled(int count) {
    return '$count champs remplis depuis le scan — vérifie-les avant d\'enregistrer.';
  }

  @override
  String get scanned => 'scanné';

  @override
  String get maintenance => 'Entretien & Maintenance';

  @override
  String get maintenanceShort => 'Entretien';

  @override
  String get addMaintenance => 'Ajouter un entretien';

  @override
  String get editMaintenance => 'Modifier l\'entretien';

  @override
  String get maintenanceAdded => 'Entretien enregistré !';

  @override
  String get maintenanceUpdated => 'Entretien mis à jour !';

  @override
  String get noMaintenance => 'Aucun entretien enregistré';

  @override
  String get deleteMaintenance => 'Supprimer l\'entrée';

  @override
  String get interventionType => 'Type d\'intervention *';

  @override
  String get performedDate => 'Date de réalisation *';

  @override
  String get description => 'Description';

  @override
  String get mileageAtService => 'Kilométrage';

  @override
  String get nextService => 'Prochain entretien (facultatif)';

  @override
  String get nextMileage => 'Prochain kilométrage';

  @override
  String get nextDate => 'Prochaine date';

  @override
  String get autoShop => 'Garage';

  @override
  String get svcOilChange => 'Vidange';

  @override
  String get svcFilters => 'Filtres';

  @override
  String get svcBrakePads => 'Plaquettes de frein';

  @override
  String get svcTyres => 'Pneus';

  @override
  String get svcTimingBelt => 'Distribution';

  @override
  String get svcAltBelt => 'Courroie d\'alternateur';

  @override
  String get svcBattery => 'Batterie';

  @override
  String get svcShocks => 'Amortisseurs';

  @override
  String get svcSparkPlugs => 'Bougies';

  @override
  String get other => 'Autre';

  @override
  String get modifications => 'Modifications';

  @override
  String get addModification => 'Ajouter une modification';

  @override
  String get editModification => 'Modifier la modification';

  @override
  String get modificationAdded => 'Modification ajoutée !';

  @override
  String get modificationUpdated => 'Modification mise à jour !';

  @override
  String get noModifications => 'Aucune modification ajoutée';

  @override
  String get deleteModification => 'Supprimer la modification';

  @override
  String get category => 'Catégorie *';

  @override
  String get modDescription => 'Description de la modification *';

  @override
  String get modificationDate => 'Date de modification (facultatif)';

  @override
  String get performedBy => 'Réalisée par';

  @override
  String get homologated => 'Homologuée';

  @override
  String get homologatedShort => 'Homologué';

  @override
  String get homologationNumber => 'N° d\'homologation';

  @override
  String get catEngine => 'Moteur';

  @override
  String get catExterior => 'Extérieur';

  @override
  String get catInterior => 'Intérieur';

  @override
  String get catSuspension => 'Suspension';

  @override
  String get catAudio => 'Audio';

  @override
  String get catElectronic => 'Électronique';

  @override
  String get catBrakes => 'Freins';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get noPhotos => 'Aucune photo';

  @override
  String photoCounter(int count, int max) {
    return 'Photo $count sur $max';
  }

  @override
  String uploadError(String msg) {
    return 'Erreur d\'envoi : $msg';
  }

  @override
  String get notificationsTitle => 'Notifications et alertes';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get allInOrder => 'Tout est en ordre !';

  @override
  String get checkNow => 'Vérifier maintenant';

  @override
  String get checkDocuments => 'Vérifier les documents';

  @override
  String get markRead => 'Marquer comme lu';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String unreadCount(int count) {
    return '$count notifications non lues';
  }

  @override
  String get administration => 'Administration';

  @override
  String get users => 'Utilisateurs';

  @override
  String accountsCount(int count) {
    return '$count comptes';
  }

  @override
  String get reload => 'Recharger';

  @override
  String get accountActive => 'Compte actif';

  @override
  String get accountActiveHint => 'L\'utilisateur peut se connecter';

  @override
  String get inactive => 'Inactif';

  @override
  String get role => 'Rôle';

  @override
  String get subscription => 'Abonnement';

  @override
  String get carLimit => 'Limite de voitures';

  @override
  String createdOn(String name) {
    return 'Créé : $name';
  }

  @override
  String docsShort(int count) {
    return '$count doc.';
  }

  @override
  String get deleteUser => 'Supprimer l\'utilisateur';

  @override
  String deleteUserConfirm(String name) {
    return 'Supprimer le compte de « $name » ?\n\nToutes ses voitures et documents seront définitivement effacés.';
  }

  @override
  String userDeleted(String name) {
    return 'Le compte « $name » a été supprimé.';
  }

  @override
  String get userUpdated => 'Utilisateur mis à jour !';

  @override
  String get carDetails => 'Détails de la voiture';

  @override
  String get documents => 'Documents';

  @override
  String get info => 'Infos';

  @override
  String get tapForDetails => 'Appuie pour les détails';

  @override
  String get engineCapacity => 'Cylindrée';

  @override
  String get enginePower => 'Puissance';

  @override
  String get fuelType => 'Carburant';

  @override
  String get color => 'Couleur';

  @override
  String get mileage => 'Kilométrage';

  @override
  String get nickname => 'Surnom (facultatif)';

  @override
  String get saveCar => 'Enregistrer la voiture';

  @override
  String get carAdded => 'Voiture ajoutée !';

  @override
  String get invalidYear => 'Année invalide';

  @override
  String get saveError => 'Erreur lors de l\'enregistrement';

  @override
  String get fuelPetrol => 'Essence';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybride';

  @override
  String get fuelElectric => 'Électrique';

  @override
  String get fuelLpg => 'GPL';

  @override
  String addOf(String name) {
    return 'Ajouter $name';
  }

  @override
  String editOf(String name) {
    return 'Modifier $name';
  }

  @override
  String expiresOnDate(String name) {
    return 'Expire : $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Prochain : $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Prochain entretien : $name';
  }

  @override
  String atKm(String name) {
    return 'À : $name km';
  }

  @override
  String get scanComplete => 'Scan terminé ! Vérifie les données.';

  @override
  String get hintNickname => 'ex. Ma petite Dacia';

  @override
  String get hintCity => 'Bucarest';

  @override
  String get hintAddress => '1 rue Exemple, Bucarest';

  @override
  String get hintPerformedBy => 'Garage / personne';

  @override
  String get hintInterventionDetails => 'Détails de l\'intervention...';
}
