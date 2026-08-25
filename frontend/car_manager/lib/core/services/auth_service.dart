import 'package:dio/dio.dart';
import '../models/user.dart';
import '../api/api_client.dart';
import 'token_store.dart';

class AuthService {
  final Dio _dio = createDio();

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? lang,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'full_name': fullName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      // Limba aplicatiei decide limba emailului de confirmare
      if (lang != null) 'lang': lang,
    });
    await _saveTokens(resp.data);
    return User.fromJson(resp.data['user']);
  }

  Future<User> login({required String email, required String password}) async {
    final resp = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _saveTokens(resp.data);
    return User.fromJson(resp.data['user']);
  }

  Future<User?> getMe() async {
    try {
      final resp = await _dio.get('/auth/me');
      return User.fromJson(resp.data);
    } catch (_) {
      return null;
    }
  }

  /// Cere pe email un link de resetare a parolei.
  ///
  /// Serverul raspunde la fel si daca adresa nu are cont, ca sa nu spuna
  /// nimanui cine e inregistrat. Deci lipsa unei erori nu inseamna ca
  /// exista un cont.
  Future<void> forgotPassword({required String email, String? lang}) async {
    await _dio.post('/auth/forgot-password', data: {
      'email': email,
      if (lang != null) 'lang': lang,
    });
  }

  /// Retrimite linkul de confirmare a adresei.
  Future<void> resendVerification({String? lang}) async {
    await _dio.post('/auth/resend-verification',
        data: {if (lang != null) 'lang': lang});
  }

  /// Sterge definitiv contul si curata tokenurile locale.
  Future<void> deleteAccount({required String password}) async {
    await _dio.delete('/auth/me', data: {'password': password});
    await logout();
  }

  Future<void> logout() => TokenStore.clear();

  Future<bool> isLoggedIn() => TokenStore.hasSession;

  Future<void> _saveTokens(Map<String, dynamic> data) => TokenStore.save(
        access: data['access_token'],
        refresh: data['refresh_token'],
      );
}
