import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';

final authServiceProvider = Provider((_) => AuthService());

final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final service = ref.read(authServiceProvider);
    if (await service.isLoggedIn()) {
      return service.getMe();
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).login(email: email, password: password),
    );
  }

  Future<void> register(String email, String password, String fullName, String? phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).register(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
          ),
    );
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}
