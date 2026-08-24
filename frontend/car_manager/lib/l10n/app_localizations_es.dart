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
}
