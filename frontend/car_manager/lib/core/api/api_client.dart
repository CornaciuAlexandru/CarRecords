import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pe Windows backend-ul ruleaza intotdeauna pe localhost.
// Pe Android IP-ul este descoperit automat prin UDP broadcast la fiecare pornire.
String _dynamicBaseUrl = Platform.isAndroid
    ? 'http://127.0.0.1:8000/api/v1'   // placeholder — suprascris de discovery
    : 'http://localhost:8000/api/v1';

/// URL-ul curent al backend-ului.
String get backendBaseUrl => _dynamicBaseUrl;

/// Actualizeaza IP-ul serverului dupa descoperire.
void setDiscoveredServerIp(String ip) {
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
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
          final prefs = await SharedPreferences.getInstance();
          opts.headers['Authorization'] = 'Bearer ${prefs.getString('access_token')}';
          try {
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          } catch (_) {}
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      }
      return handler.next(error);
    },
  ));

  return dio;
}

Future<bool> _tryRefreshToken(Dio dio) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;
    final response = await dio.post('/auth/refresh',
        data: {'refresh_token': refreshToken});
    await prefs.setString('access_token', response.data['access_token']);
    await prefs.setString('refresh_token', response.data['refresh_token']);
    return true;
  } catch (_) {
    return false;
  }
}
