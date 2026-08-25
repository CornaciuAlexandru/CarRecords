// Teste pentru mutarea tokenurilor in stocarea securizata.
//
// Partea riscanta a schimbarii nu e scrierea in sine, ci migrarea: daca
// tokenurile vechi nu ajung in noul loc, toata lumea e deconectata la
// actualizare, fara sa inteleaga de ce.
//
// Pluginul nativ nu exista in `flutter test`, asa ca ii tinem locul cu un
// dictionar in memorie, peste canalul lui de platforma.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:car_manager/core/services/token_store.dart';

const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> secure;

  setUp(() {
    secure = {};
    TokenStore.resetCacheForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final key = args['key'] as String?;
      switch (call.method) {
        case 'write':
          secure[key!] = args['value'] as String;
          return null;
        case 'read':
          return secure[key];
        case 'delete':
          secure.remove(key);
          return null;
        case 'containsKey':
          return secure.containsKey(key);
        default:
          return null;
      }
    });
  });

  test('tokenurile din SharedPreferences sunt mutate si sterse de acolo', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'acces_vechi',
      'refresh_token': 'refresh_vechi',
      'app_language': 'ro',
    });

    expect(await TokenStore.accessToken, 'acces_vechi');
    expect(await TokenStore.refreshToken, 'refresh_vechi');
    expect(secure['access_token'], 'acces_vechi');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), isNull,
        reason: 'tokenul nu trebuie sa ramana in clar');
    expect(prefs.getString('refresh_token'), isNull);
    expect(prefs.getString('app_language'), 'ro',
        reason: 'restul preferintelor nu se ating');
  });

  test('fara tokenuri vechi, sesiunea porneste goala', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await TokenStore.hasSession, isFalse);
    expect(await TokenStore.accessToken, isNull);
  });

  test('salvarea si stergerea trec prin stocarea securizata', () async {
    SharedPreferences.setMockInitialValues({});

    await TokenStore.save(access: 'a1', refresh: 'r1');
    expect(secure, {'access_token': 'a1', 'refresh_token': 'r1'});
    expect(await TokenStore.accessToken, 'a1');
    expect(await TokenStore.hasSession, isTrue);

    await TokenStore.clear();
    expect(secure, isEmpty);
    expect(await TokenStore.accessToken, isNull);
    expect(await TokenStore.hasSession, isFalse);
  });

  test('citirile paralele fac o singura migrare', () async {
    SharedPreferences.setMockInitialValues({'access_token': 'acces_vechi'});

    final results = await Future.wait([
      TokenStore.accessToken,
      TokenStore.accessToken,
      TokenStore.accessToken,
    ]);

    expect(results, ['acces_vechi', 'acces_vechi', 'acces_vechi']);
  });
}
