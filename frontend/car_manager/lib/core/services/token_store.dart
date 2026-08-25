import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locul unde stau tokenurile de autentificare.
///
/// Pana la versiunea 1.0.20 erau in SharedPreferences, adica in clar: pe
/// Windows un fisier XML in AppData, pe Android un fisier XML in sandbox-ul
/// aplicatiei. Acum stau in stocarea securizata a sistemului — DPAPI pe
/// Windows, EncryptedSharedPreferences (Keystore) pe Android.
///
/// Cine actualizeaza aplicatia nu e deconectat: tokenurile vechi sunt mutate
/// la prima citire si sterse din locul nesigur.
class TokenStore {
  TokenStore._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Copie in memorie, ca sa nu trecem prin canalul de platforma la fiecare
  /// cerere HTTP. Se invalideaza la fiecare scriere sau stergere.
  static String? _access;
  static String? _refresh;
  static bool _loaded = false;

  /// Migrarea se face o singura data per pornire. Pastram Future-ul, nu un
  /// boolean: doua apeluri simultane trebuie sa astepte aceeasi migrare, nu
  /// sa porneasca fiecare cate una.
  static Future<void>? _migration;

  static Future<String?> get accessToken async {
    await _ensureLoaded();
    return _access;
  }

  static Future<String?> get refreshToken async {
    await _ensureLoaded();
    return _refresh;
  }

  static Future<bool> get hasSession async => (await accessToken) != null;

  static Future<void> save({required String access, required String refresh}) async {
    await _ensureMigrated();
    _access = access;
    _refresh = refresh;
    _loaded = true;
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<void> clear() async {
    await _ensureMigrated();
    _access = null;
    _refresh = null;
    _loaded = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _ensureMigrated();
    _access = await _storage.read(key: _accessKey);
    _refresh = await _storage.read(key: _refreshKey);
    _loaded = true;
  }

  static Future<void> _ensureMigrated() => _migration ??= _migrate();

  /// Muta tokenurile ramase din versiunile vechi si sterge urma din
  /// SharedPreferences.
  static Future<void> _migrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldAccess = prefs.getString(_accessKey);
      final oldRefresh = prefs.getString(_refreshKey);
      if (oldAccess != null) {
        await _storage.write(key: _accessKey, value: oldAccess);
      }
      if (oldRefresh != null) {
        await _storage.write(key: _refreshKey, value: oldRefresh);
      }
      await prefs.remove(_accessKey);
      await prefs.remove(_refreshKey);
    } catch (_) {
      // O migrare esuata inseamna, in cel mai rau caz, o reautentificare.
      // Nu trebuie sa impiedice pornirea aplicatiei.
    }
  }

  /// Doar pentru teste: uita ce s-a incarcat in memorie.
  static void resetCacheForTesting() {
    _access = null;
    _refresh = null;
    _loaded = false;
    _migration = null;
  }
}
