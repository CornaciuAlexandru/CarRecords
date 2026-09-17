import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_manager/core/utils/error_handler.dart';

DioException _withBody(dynamic body, {int status = 402}) {
  final options = RequestOptions(path: '/oarecare');
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: body,
    ),
  );
}

void main() {
  group('serverDetail', () {
    test('citeste mesajul dintr-un raspuns JSON obisnuit', () {
      final e = _withBody({'detail': 'Ai atins limita de 2 masini.'});
      expect(serverDetail(e), 'Ai atins limita de 2 masini.');
    });

    test('citeste mesajul si cand raspunsul vine ca octeti', () {
      // Cazul care a rupt butonul de PDF: cererea cere `responseType: bytes`
      // pentru fisier, deci si eroarea vine tot ca octeti. Indexarea lor cu
      // 'detail' arunca, iar exceptia cade in blocul care trata eroarea si
      // inghite tot - butonul parea ca nu face nimic.
      final json = utf8.encode('{"detail":"Raportul PDF e in planurile PRO."}');
      expect(serverDetail(_withBody(json)),
          'Raportul PDF e in planurile PRO.');
    });

    test('citeste mesajul si cand raspunsul vine ca text', () {
      expect(serverDetail(_withBody('{"detail":"gata"}')), 'gata');
    });

    test('octeti care nu sunt JSON nu arunca', () {
      expect(serverDetail(_withBody(utf8.encode('%PDF-1.4 ...'))), isNull);
    });

    test('raspuns fara camp detail', () {
      expect(serverDetail(_withBody({'altceva': 1})), isNull);
    });

    test('eroare fara raspuns', () {
      expect(
        serverDetail(DioException(requestOptions: RequestOptions(path: '/x'))),
        isNull,
      );
    });

    test('ce nu e eroare Dio nu e citit', () {
      expect(serverDetail(Exception('retea')), isNull);
    });
  });

  group('isPaymentRequired', () {
    test('402 inseamna "cumpara", nu "eroare"', () {
      expect(isPaymentRequired(_withBody({'detail': 'x'}, status: 402)), isTrue);
    });

    test('restul codurilor nu deschid ofertele', () {
      for (final status in [400, 401, 403, 404, 500]) {
        expect(isPaymentRequired(_withBody({'detail': 'x'}, status: status)),
            isFalse, reason: 'status $status');
      }
    });
  });
}
