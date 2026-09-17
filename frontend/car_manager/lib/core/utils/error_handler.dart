import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'l10n.dart';

/// Mesajul trimis de server, daca exista si daca se poate citi.
///
/// Corpul unui raspuns de eroare nu e intotdeauna JSON gata parsat. O cerere
/// facuta cu `responseType: bytes` - descarcarea unui PDF, de pilda - primeste
/// si eroarea tot ca octeti. Indexarea acelor octeti cu 'detail' arunca, iar
/// exceptia aia cade tocmai in blocul care trata eroarea si inghite tot ce
/// urma: butonul parea ca nu face absolut nimic.
String? serverDetail(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is Map) return data['detail']?.toString();
  if (data is List<int>) return _detailFromJson(utf8.decode(data, allowMalformed: true));
  if (data is String) return _detailFromJson(data);
  return null;
}

String? _detailFromJson(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map) return decoded['detail']?.toString();
  } catch (_) {
    // Nu era JSON. Nu avem ce mesaj sa aratam, si nu e motiv de exceptie.
  }
  return null;
}

/// Serverul a refuzat pentru ca depaseste planul contului.
///
/// Se deosebeste de restul erorilor pentru ca cere alt raspuns din partea
/// aplicatiei: se arata oferta, nu un mesaj rosu. De asta backend-ul intoarce
/// 402 si nu 400 sau 403.
bool isPaymentRequired(Object error) =>
    error is DioException && error.response?.statusCode == 402;

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
    final detail = serverDetail(error);

    // Limitarea de rata are mesaj propriu, tradus: cel de la server e
    // intr-o singura limba.
    if (statusCode == 429) return tr(context).errTooManyAttempts;

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
