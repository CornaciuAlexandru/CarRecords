// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'CarRecords';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Añadir';

  @override
  String get update => 'Actualizar';

  @override
  String get retry => 'Reintentar';

  @override
  String get error => 'Error';

  @override
  String errorWith(String msg) {
    return 'Error: $msg';
  }

  @override
  String get required => 'Obligatorio';

  @override
  String get optional => 'opcional';

  @override
  String get notes => 'Notas';

  @override
  String get notesHint => 'Observaciones...';

  @override
  String get chooseDate => 'Elegir fecha';

  @override
  String get city => 'Ciudad';

  @override
  String get cost => 'Coste (RON)';

  @override
  String get invoiceNr => 'N.º factura';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión para continuar';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Crear cuenta';

  @override
  String get noAccount => '¿No tienes cuenta? ';

  @override
  String get haveAccount => '¿Ya tienes cuenta? ';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phone => 'Teléfono';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get invalidEmail => 'Dirección de correo no válida';

  @override
  String get passwordTooShort => 'Mínimo 8 caracteres';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get newAccount => 'Cuenta nueva';

  @override
  String get fillDetails => 'Completa los datos siguientes';

  @override
  String get minChars3 => 'Mínimo 3 caracteres';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get passwordRulesHint => 'Mín. 8 caracteres, 1 mayúscula, 1 dígito';

  @override
  String get passwordNeedsUpper => 'Debe contener al menos una mayúscula';

  @override
  String get passwordNeedsDigit => 'Debe contener al menos un dígito';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCars => 'Coches';

  @override
  String get navAlerts => 'Alertas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navAdmin => 'Admin';

  @override
  String get startingService => 'Iniciando servicio...';

  @override
  String get searchingServer => 'Buscando el servidor...';

  @override
  String get connecting => 'Conectando...';

  @override
  String get checkingUpdates => 'Buscando actualizaciones...';

  @override
  String get connected => '¡Conectado!';

  @override
  String get serverNotFound => 'Servidor no encontrado';

  @override
  String get serverNotFoundHintMobile =>
      'Asegúrate de que tu ordenador está encendido y conectado a la misma red Wi-Fi.';

  @override
  String get serverNotFoundHintDesktop =>
      'Comprueba que la aplicación está instalada correctamente e inténtalo de nuevo.';

  @override
  String get searchAgain => 'Buscar de nuevo';

  @override
  String greeting(String name) {
    return '¡Hola, $name! 👋';
  }

  @override
  String get myCars => 'Mis coches';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get statActiveAlerts => 'Alertas activas';

  @override
  String get statExpired => 'Caducados';

  @override
  String get addFirstCar => 'Añade tu primer coche';

  @override
  String get noCarsYet => 'Aún no hay coches';

  @override
  String get noCarsHint =>
      'Añade tu primer coche para gestionar todos sus documentos';

  @override
  String get addCar => 'Añadir coche';

  @override
  String carsCount(int count, int max) {
    return '$count/$max coches';
  }

  @override
  String get deleteCar => 'Eliminar coche';

  @override
  String deleteCarConfirm(String name) {
    return '¿Eliminar \"$name\"? Se borrarán todos los datos asociados.';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageChoose => 'Elegir idioma';

  @override
  String get generalInfo => 'Información general';

  @override
  String get technicalDetails => 'Detalles técnicos';

  @override
  String get validFrom => 'Válida desde';

  @override
  String get expires => 'Caduca';

  @override
  String get expiresOn => 'Caduca el';

  @override
  String get daysLeft => 'Días restantes';

  @override
  String get price => 'Precio';

  @override
  String get priceRon => 'Precio (RON)';

  @override
  String scanFailed(String msg) {
    return 'Error al escanear: $msg';
  }

  @override
  String get extractedData => 'Datos extraídos';

  @override
  String get noDataExtracted =>
      'No se pudieron extraer datos automáticamente de la imagen.';

  @override
  String get detectedText => 'Texto detectado:';

  @override
  String get checkFirst => 'Revisar primero';

  @override
  String get saveDirectly => 'Guardar directamente';

  @override
  String deleteConfirmGeneric(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get vignettes => 'Viñetas';

  @override
  String get vignette => 'Viñeta';

  @override
  String get addVignette => 'Añadir viñeta';

  @override
  String get editVignette => 'Editar viñeta';

  @override
  String get saveVignette => 'Guardar viñeta';

  @override
  String get vignetteAdded => '¡Viñeta añadida!';

  @override
  String get vignetteUpdated => '¡Viñeta actualizada!';

  @override
  String get noVignettes => 'No hay viñetas añadidas';

  @override
  String get deleteVignette => 'Eliminar viñeta';

  @override
  String get deleteVignetteConfirm =>
      '¿Seguro que quieres eliminar esta viñeta?';

  @override
  String get purchaseDate => 'Fecha de compra';

  @override
  String get validityPeriod => 'Periodo de validez *';

  @override
  String get period => 'Periodo';

  @override
  String get issuer => 'Emisor';

  @override
  String get issuerCompany => 'Empresa emisora';

  @override
  String get invoiceSeries => 'Serie de factura';

  @override
  String get insurance => 'Seguros';

  @override
  String get addInsurance => 'Añadir seguro';

  @override
  String get saveInsurance => 'Guardar seguro';

  @override
  String get insuranceAdded => '¡Seguro añadido!';

  @override
  String get insuranceUpdated => '¡Seguro actualizado!';

  @override
  String get noInsurance => 'No hay seguros añadidos';

  @override
  String get deleteInsurance => 'Eliminar seguro';

  @override
  String get insurerCompany => 'Aseguradora *';

  @override
  String get policyNumber => 'N.º de póliza';

  @override
  String get premiumRon => 'Prima (RON)';

  @override
  String get premium => 'Prima';

  @override
  String get deductibleRon => 'Franquicia (RON)';

  @override
  String get paymentFrequency => 'Frecuencia de pago';

  @override
  String get purchasedOn => 'Comprada el';

  @override
  String get agentName => 'Nombre del agente';

  @override
  String get agentPhone => 'Teléfono del agente';

  @override
  String get agent => 'Agente';

  @override
  String get roadsideAssistance => 'Asistencia en carretera';

  @override
  String get roadsideIncluded => 'Asistencia en carretera incluida';

  @override
  String get included => 'Incluida';

  @override
  String get freqMonthly => 'Mensual';

  @override
  String get freqQuarterly => 'Trimestral';

  @override
  String get freqBiannual => 'Semestral';

  @override
  String get freqAnnual => 'Anual';

  @override
  String get registrationDoc => 'Permiso & ITV';

  @override
  String get registrationShort => 'Permiso';

  @override
  String get addRegistration => 'Añadir permiso';

  @override
  String get editRegistration => 'Editar permiso';

  @override
  String get registrationAdded => '¡Permiso añadido!';

  @override
  String get registrationUpdated => '¡Permiso actualizado!';

  @override
  String get noRegistration => 'No hay permisos añadidos';

  @override
  String get deleteRegistration => 'Eliminar permiso';

  @override
  String get deleteRegistrationConfirm =>
      '¿Seguro que quieres eliminar este permiso?';

  @override
  String get vehicleData => 'Datos del vehículo';

  @override
  String get registrationAndItp => 'Matriculación & ITV';

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get manufacturingYear => 'Año de fabricación';

  @override
  String get plateNumber => 'Matrícula';

  @override
  String get vin => 'Número de bastidor (VIN)';

  @override
  String get ownerName => 'Nombre del propietario';

  @override
  String get ownerAddress => 'Dirección del propietario';

  @override
  String get owner => 'Propietario';

  @override
  String get address => 'Dirección';

  @override
  String get registrationDate => 'Fecha de matriculación';

  @override
  String get itpExpiryDate => 'Caducidad de la ITV';

  @override
  String get itpExpires => 'ITV caduca';

  @override
  String get itpValid => 'ITV válida';

  @override
  String get itpExpired => '¡ITV caducada!';

  @override
  String ocrFieldsFilled(int count) {
    return '$count campos rellenados con el escaneo: revísalos antes de guardar.';
  }

  @override
  String get scanned => 'escaneado';

  @override
  String get maintenance => 'Servicio y mantenimiento';

  @override
  String get maintenanceShort => 'Servicio';

  @override
  String get addMaintenance => 'Añadir servicio';

  @override
  String get editMaintenance => 'Editar servicio';

  @override
  String get maintenanceAdded => '¡Servicio registrado!';

  @override
  String get maintenanceUpdated => '¡Servicio actualizado!';

  @override
  String get noMaintenance => 'No hay servicios registrados';

  @override
  String get deleteMaintenance => 'Eliminar registro';

  @override
  String get interventionType => 'Tipo de intervención *';

  @override
  String get performedDate => 'Fecha de realización *';

  @override
  String get description => 'Descripción';

  @override
  String get mileageAtService => 'Kilometraje';

  @override
  String get nextService => 'Próximo servicio (opcional)';

  @override
  String get nextMileage => 'Próximo kilometraje';

  @override
  String get nextDate => 'Próxima fecha';

  @override
  String get autoShop => 'Taller';

  @override
  String get svcOilChange => 'Cambio de aceite';

  @override
  String get svcFilters => 'Filtros';

  @override
  String get svcBrakePads => 'Pastillas de freno';

  @override
  String get svcTyres => 'Neumáticos';

  @override
  String get svcTimingBelt => 'Distribución';

  @override
  String get svcAltBelt => 'Correa del alternador';

  @override
  String get svcBattery => 'Batería';

  @override
  String get svcShocks => 'Amortiguadores';

  @override
  String get svcSparkPlugs => 'Bujías';

  @override
  String get other => 'Otro';

  @override
  String get modifications => 'Modificaciones';

  @override
  String get addModification => 'Añadir modificación';

  @override
  String get editModification => 'Editar modificación';

  @override
  String get modificationAdded => '¡Modificación añadida!';

  @override
  String get modificationUpdated => '¡Modificación actualizada!';

  @override
  String get noModifications => 'No hay modificaciones añadidas';

  @override
  String get deleteModification => 'Eliminar modificación';

  @override
  String get category => 'Categoría *';

  @override
  String get modDescription => 'Descripción de la modificación *';

  @override
  String get modificationDate => 'Fecha de modificación (opcional)';

  @override
  String get performedBy => 'Realizada por';

  @override
  String get homologated => 'Homologada';

  @override
  String get homologatedShort => 'Homologado';

  @override
  String get homologationNumber => 'N.º de homologación';

  @override
  String get catEngine => 'Motor';

  @override
  String get catExterior => 'Exterior';

  @override
  String get catInterior => 'Interior';

  @override
  String get catSuspension => 'Suspensión';

  @override
  String get catAudio => 'Audio';

  @override
  String get catElectronic => 'Electrónica';

  @override
  String get catBrakes => 'Frenos';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get noPhotos => 'Sin fotos';

  @override
  String photoCounter(int count, int max) {
    return 'Foto $count de $max';
  }

  @override
  String uploadError(String msg) {
    return 'Error de subida: $msg';
  }

  @override
  String get notificationsTitle => 'Notificaciones y alertas';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get allInOrder => '¡Todo está en orden!';

  @override
  String get checkNow => 'Comprobar ahora';

  @override
  String get checkDocuments => 'Comprobar documentos';

  @override
  String get markRead => 'Marcar como leído';

  @override
  String get markAllRead => 'Marcar todo como leído';

  @override
  String unreadCount(int count) {
    return '$count notificaciones sin leer';
  }

  @override
  String get administration => 'Administración';

  @override
  String get users => 'Usuarios';

  @override
  String accountsCount(int count) {
    return '$count cuentas';
  }

  @override
  String get reload => 'Recargar';

  @override
  String get accountActive => 'Cuenta activa';

  @override
  String get accountActiveHint => 'El usuario puede iniciar sesión';

  @override
  String get inactive => 'Inactivo';

  @override
  String get role => 'Rol';

  @override
  String get subscription => 'Suscripción';

  @override
  String get carLimit => 'Límite de coches';

  @override
  String createdOn(String name) {
    return 'Creado: $name';
  }

  @override
  String docsShort(int count) {
    return '$count doc.';
  }

  @override
  String get deleteUser => 'Eliminar usuario';

  @override
  String deleteUserConfirm(String name) {
    return '¿Eliminar la cuenta de \"$name\"?\n\nSe borrarán permanentemente todos sus coches y documentos.';
  }

  @override
  String userDeleted(String name) {
    return 'La cuenta \"$name\" ha sido eliminada.';
  }

  @override
  String get userUpdated => '¡Usuario actualizado correctamente!';

  @override
  String get carDetails => 'Detalles del coche';

  @override
  String get documents => 'Documentos';

  @override
  String get info => 'Info';

  @override
  String get tapForDetails => 'Toca para ver detalles';

  @override
  String get engineCapacity => 'Cilindrada';

  @override
  String get enginePower => 'Potencia';

  @override
  String get fuelType => 'Combustible';

  @override
  String get color => 'Color';

  @override
  String get mileage => 'Kilometraje';

  @override
  String get nickname => 'Apodo (opcional)';

  @override
  String get saveCar => 'Guardar coche';

  @override
  String get carAdded => '¡Coche añadido!';

  @override
  String get invalidYear => 'Año no válido';

  @override
  String get saveError => 'Error al guardar';

  @override
  String get fuelPetrol => 'Gasolina';

  @override
  String get fuelDiesel => 'Diésel';

  @override
  String get fuelHybrid => 'Híbrido';

  @override
  String get fuelElectric => 'Eléctrico';

  @override
  String get fuelLpg => 'GLP';

  @override
  String addOf(String name) {
    return 'Añadir $name';
  }

  @override
  String editOf(String name) {
    return 'Editar $name';
  }

  @override
  String expiresOnDate(String name) {
    return 'Caduca: $name';
  }

  @override
  String nextAtKm(String name) {
    return 'Próximo: $name km';
  }

  @override
  String nextServiceOn(String name) {
    return 'Próximo servicio: $name';
  }

  @override
  String atKm(String name) {
    return 'A: $name km';
  }

  @override
  String get scanComplete => '¡Escaneo completo! Revisa los datos.';

  @override
  String get hintNickname => 'p. ej. Mi Dacia';

  @override
  String get hintCity => 'Bucarest';

  @override
  String get hintAddress => 'C/ Ejemplo 1, Bucarest';

  @override
  String get hintPerformedBy => 'Taller / persona';

  @override
  String get hintInterventionDetails => 'Detalles de la intervención...';
}
