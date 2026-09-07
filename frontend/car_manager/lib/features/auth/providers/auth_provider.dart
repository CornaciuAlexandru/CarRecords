import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_scheduler.dart';

final authServiceProvider = Provider((_) => AuthService());

final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final service = ref.read(authServiceProvider);
    if (await service.isLoggedIn()) {
      final user = await service.getMe();
      // Sesiune reluata: realiniem alarmele cu ce e pe server. Datele se pot
      // fi schimbat de pe alt dispozitiv, iar telefonul n-ar afla altfel.
      if (user != null) unawaited(service.syncReminders());
      return user;
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).login(email: email, password: password),
    );
    if (state.hasValue && state.value != null) _armReminders();
  }

  Future<void> register(String email, String password, String fullName, String? phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).register(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
            lang: _lang,
          ),
    );
    if (state.hasValue && state.value != null) _armReminders();
  }

  /// Cere permisiunea si programeaza mementourile, fara sa tina ecranul in
  /// loc: autentificarea nu trebuie sa astepte dupa notificari.
  void _armReminders() {
    unawaited(ref.read(authServiceProvider).syncReminders(askPermission: true));
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    // Alarmele vorbesc despre masinile contului. Daca ies din cont, n-au ce
    // sa mai sune pe telefonul asta.
    await NotificationScheduler.instance.cancelAll();
    state = const AsyncData(null);
  }

  /// Reciteste contul de pe server (ex. dupa confirmarea adresei din email).
  ///
  /// Daca serverul nu raspunde pastram utilizatorul curent: un getMe esuat
  /// nu trebuie sa arate ca o deconectare.
  Future<void> refreshUser() async {
    final user = await ref.read(authServiceProvider).getMe();
    if (user != null) state = AsyncData(user);
  }

  Future<void> forgotPassword(String email) =>
      ref.read(authServiceProvider).forgotPassword(email: email, lang: _lang);

  Future<void> resendVerification() =>
      ref.read(authServiceProvider).resendVerification(lang: _lang);

  Future<void> deleteAccount(String password) async {
    await ref.read(authServiceProvider).deleteAccount(password: password);
    await NotificationScheduler.instance.cancelAll();
    state = const AsyncData(null);
  }

  /// Limba aplicatiei, trimisa serverului pentru emailuri.
  String get _lang => ref.read(localeProvider).languageCode;
}
