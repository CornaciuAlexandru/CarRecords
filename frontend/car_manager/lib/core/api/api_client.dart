import 'package:dio/dio.dart';
import '../services/token_store.dart';

/// Adresa serverului din cloud. Se seteaza la compilare:
///     flutter build apk --release --dart-define=API_URL=https://api.exemplu.ro
///
/// Cand e definita, aplicatia se conecteaza direct la ea (functioneaza de
/// oriunde, nu doar din reteaua locala). Cand lipseste, se comporta ca pana
/// acum: cauta backend-ul in reteaua locala prin broadcast UDP.
const String kCloudApiUrl = String.fromEnvironment('API_URL', defaultValue: '');

bool get usesCloudBackend => kCloudApiUrl.isNotEmpty;

// Fara server in cloud: pe Windows backend-ul ruleaza pe loopback local.
// Folosim 127.0.0.1 explicit (nu "localhost") — pe unele sisteme localhost
// se rezolva la ::1 (IPv6), iar uvicorn asculta doar pe IPv4.
// Pe Android IP-ul e descoperit automat prin broadcast la fiecare pornire.
String _dynamicBaseUrl = usesCloudBackend
    ? '$kCloudApiUrl/api/v1'
    : 'http://127.0.0.1:8000/api/v1';

/// URL-ul curent al backend-ului.
String get backendBaseUrl => _dynamicBaseUrl;

/// Actualizeaza IP-ul serverului dupa descoperirea in reteaua locala.
/// Nu are efect daca aplicatia e configurata cu un server in cloud.
void setDiscoveredServerIp(String ip) {
  if (usesCloudBackend) return;
  _dynamicBaseUrl = 'http://$ip:8000/api/v1';
}

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: _dynamicBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',  // aplicat doar pentru requests JSON, nu multipart
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Actualizeaza baseUrl la fiecare request — suporta discovery dinamic
      options.baseUrl = _dynamicBaseUrl;
      final token = await TokenStore.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        final refreshed = await _tryRefreshToken(dio);
        if (refreshed) {
          final opts = error.requestOptions;
          opts.headers['Authorization'] = 'Bearer ${await TokenStore.accessToken}';
          try {
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          } catch (_) {}
        }
        await TokenStore.clear();
      }
      return handler.next(error);
    },
  ));

  return dio;
}

Future<bool> _tryRefreshToken(Dio dio) async {
  try {
    final refreshToken = await TokenStore.refreshToken;
    if (refreshToken == null) return false;
    final response = await dio.post('/auth/refresh',
        data: {'refresh_token': refreshToken});
    await TokenStore.save(
      access: response.data['access_token'],
      refresh: response.data['refresh_token'],
    );
    return true;
  } catch (_) {
    return false;
  }
}
