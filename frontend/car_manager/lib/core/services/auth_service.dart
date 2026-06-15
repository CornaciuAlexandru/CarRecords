import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/api_client.dart';

class AuthService {
  final Dio _dio = createDio();

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'full_name': fullName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);
  }
}
