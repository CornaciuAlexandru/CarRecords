import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'l10n.dart';

/// Mesaj de eroare prietenos, in limba aleasa de utilizator.
String parseError(BuildContext context, Object error) {
  if (error is DioException) {
    // Eroare de retea / timeout
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return tr(context).errNoConnection;
    }
    if (error.type == DioExceptionType.connectionError) {
      return tr(context).errServerDown;
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
        return tr(context).errAccountDisabled;
      }
      if (detail.toString().contains('Limita')) {
        return detail.toString();
      }
      return detail.toString();
    }

    // Fallback pe status code
    return switch (statusCode) {
      400 => tr(context).errInvalidData,
      401 => tr(context).errBadCredentials,
      403 => tr(context).errForbidden,
      404 => tr(context).errNotFound,
      422 => 'Date incomplete sau invalide.',
      500 => tr(context).errServer,
      _ => tr(context).errWithCode('\$statusCode'),
    };
  }

  // Alte erori
  final msg = error.toString();
  if (msg.contains('SocketException') || msg.contains('Connection refused')) {
    return 'Nu se poate conecta la server.';
  }
  return tr(context).errUnexpected;
}
