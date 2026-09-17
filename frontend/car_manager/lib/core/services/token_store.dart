import 'package:flutter/foundation.dart';
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

  /// Pe Android NU folosim EncryptedSharedPreferences.
  ///
  /// Acela sta pe androidx.security.crypto, depreciat de Google, care la randul
  /// lui sta pe Tink. Pe un Oppo cu ColorOS, prima creare a cheii nu se termina
  /// niciodata: ecranul de autentificare ramane cu butonul dezactivat, fiindca
  /// starea contului asteapta citirea tokenului.
  ///
  /// Varianta implicita cripteaza tot cu o cheie din Keystore si tine valorile
  /// in preferinte obisnuite - mai putine piese intre noi si disc, pentru un
  /// token care oricum expira in 15 minute.
  static const _storage = FlutterSecureStorage();

  /// Copie in memorie, ca sa nu trecem prin canalul de platforma la fiecare
  /// cerere HTTP. Se invalideaza la fiecare scriere sau stergere.
  static String? _access;
  static String? _refresh;
  static bool _loaded = false;

  /// Migrarea se face o singura data per pornire. Pastram Future-ul, nu un
  /// boolean: doua apeluri simultane trebuie sa astepte aceeasi migrare, nu
  /// sa porneasca fiecare cate una.
  static Future<void>? _migration;

  /// Cat asteptam stocarea sistemului inainte sa o consideram indisponibila.
  ///
  /// In mod normal raspunde in milisecunde. A existat insa un caz in care nu
  /// raspundea deloc - R8 taiase clasele de care depinde - iar aplicatia
  /// ramanea blocata cu butonul de autentificare invartindu-se la nesfarsit.
  /// Cauza aceea e reparata (android/app/proguard-rules.pro), dar o scriere
  /// pe disc n-are voie sa poata bloca aplicatia, indiferent de motiv.
  static const _timeout = Duration(seconds: 5);

  /// Odata ce stocarea a dat gres, nu mai insistam la fiecare cerere.
  /// Tokenurile raman in memorie: sesiunea merge pana la inchiderea
  /// aplicatiei, iar apoi se cere o reautentificare. Neplacut, dar folosibil -
  /// spre deosebire de un ecran blocat.
  static bool _storageDown = false;

  /// Stocarea securizata a esuat in aceasta sesiune?
  static bool get storageUnavailable => _storageDown;

  /// Ruleaza o operatie pe stocare fara sa poata bloca apelantul.
  static Future<T?> _guard<T>(Future<T> Function() op, String what) async {
    if (_storageDown) return null;
    try {
      return await op().timeout(_timeout);
    } catch (e) {
      _storageDown = true;
      debugPrint('TokenStore: stocarea securizata nu raspunde ($what): $e');
      return null;
    }
  }

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
    // Intai in memorie: sesiunea trebuie sa functioneze chiar daca scrierea pe
    // disc de mai jos esueaza.
    _access = access;
    _refresh = refresh;
    _loaded = true;
    await _guard(() => _storage.write(key: _accessKey, value: access), 'scriere');
    await _guard(() => _storage.write(key: _refreshKey, value: refresh), 'scriere');
  }

  static Future<void> clear() async {
    await _ensureMigrated();
    _access = null;
    _refresh = null;
    _loaded = true;
    await _guard(() => _storage.delete(key: _accessKey), 'stergere');
    await _guard(() => _storage.delete(key: _refreshKey), 'stergere');
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _ensureMigrated();
    _access = await _guard<String?>(() => _storage.read(key: _accessKey), 'citire');
    _refresh = await _guard<String?>(() => _storage.read(key: _refreshKey), 'citire');
    _loaded = true;
  }

  static Future<void> _ensureMigrated() => _migration ??= _migrate();

  /// Muta tokenurile ramase din versiunile vechi si sterge urma din
  /// SharedPreferences.
  static Future<void> _migrate() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      final oldAccess = prefs.getString(_accessKey);
      final oldRefresh = prefs.getString(_refreshKey);
      if (oldAccess != null) {
        await _guard(() => _storage.write(key: _accessKey, value: oldAccess),
            'migrare');
      }
      if (oldRefresh != null) {
        await _guard(() => _storage.write(key: _refreshKey, value: oldRefresh),
            'migrare');
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
    _storageDown = false;
  }
}
