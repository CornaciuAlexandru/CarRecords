import 'package:dio/dio.dart';

String parseError(Object error) {
  if (error is DioException) {
    // Eroare de retea / timeout
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Nu se poate conecta la server. Verifică conexiunea.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Server indisponibil. Asigură-te că backend-ul rulează.';
    }

    // Erori HTTP cu mesaj de la backend
    final statusCode = error.response?.statusCode;
    final detail = error.response?.data?['detail'];

    if (detail != null) {
      // Mesaje cunoscute de la backend
      if (detail.toString().contains('Email sau parola') ||
          detail.toString().contains('Email deja')) {
        return detail.toString();
      }
      if (detail.toString().contains('dezactivat')) {
        return 'Contul tău a fost dezactivat. Contactează suportul.';
      }
      if (detail.toString().contains('Limita')) {
        return detail.toString();
      }
      return detail.toString();
    }

    // Fallback pe status code
    return switch (statusCode) {
      400 => 'Date invalide. Verifică câmpurile completate.',
      401 => 'Email sau parolă incorectă.',
      403 => 'Nu ai permisiunea pentru această acțiune.',
      404 => 'Resursa nu a fost găsită.',
      422 => 'Date incomplete sau invalide.',
      500 => 'Eroare server. Încearcă din nou.',
      _ => 'A apărut o eroare (cod $statusCode).',
    };
  }

  // Alte erori
  final msg = error.toString();
  if (msg.contains('SocketException') || msg.contains('Connection refused')) {
    return 'Nu se poate conecta la server.';
  }
  return 'A apărut o eroare neașteptată.';
}
