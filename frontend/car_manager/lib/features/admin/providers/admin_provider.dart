import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/user.dart';

// ── Service ────────────────────────────────────────────────────────────────

class AdminService {
  final Dio _dio = createDio();

  Future<List<AdminUserInfo>> getUsers() async {
    final resp = await _dio.get('/admin/users', queryParameters: {'limit': 200});
    return (resp.data as List).map((j) => AdminUserInfo.fromJson(j)).toList();
  }

  Future<AdminUserInfo> updateUser(String userId, Map<String, dynamic> data) async {
    final resp = await _dio.put('/admin/users/$userId', data: data);
    // Backend returneaza UserOut, nu AdminUserOut — enrichim local
    final updated = AdminUserInfo.fromJson({...resp.data, 'car_count': 0, 'records_count': 0});
    return updated;
  }

  Future<void> deleteUser(String userId) async {
    await _dio.delete('/admin/users/$userId');
  }

  Future<Map<String, dynamic>> getStats() async {
    final resp = await _dio.get('/admin/stats');
    return resp.data as Map<String, dynamic>;
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final adminServiceProvider = Provider((_) => AdminService());

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<AdminUserInfo>>(
        AdminUsersNotifier.new);

class AdminUsersNotifier extends AsyncNotifier<List<AdminUserInfo>> {
  @override
  Future<List<AdminUserInfo>> build() =>
      ref.read(adminServiceProvider).getUsers();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(adminServiceProvider).getUsers());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await ref.read(adminServiceProvider).updateUser(userId, data);
    // Re-fetch lista completa pentru a pastra car_count/records_count corecte
    state = await AsyncValue.guard(
        () => ref.read(adminServiceProvider).getUsers());
  }

  Future<void> deleteUser(String userId) async {
    await ref.read(adminServiceProvider).deleteUser(userId);
    state = AsyncData(
      (state.value ?? []).where((u) => u.id != userId).toList(),
    );
  }
}

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(adminServiceProvider).getStats();
});
