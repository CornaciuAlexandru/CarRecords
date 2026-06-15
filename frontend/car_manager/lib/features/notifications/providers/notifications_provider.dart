import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/documents.dart';
import '../../../core/services/car_service.dart';
import '../../auth/providers/auth_provider.dart';

final _svc = CarService();

/// Lista completa de notificari — se rebuilduieste la schimbarea userului.
final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
        NotificationsNotifier.new);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    // Se rebuilduieste automat la login/logout
    final auth = ref.watch(authStateProvider);
    if (auth.value == null) return [];

    // Triggeram verificarea la fiecare login/rebuild
    try {
      await _svc.checkNotifications();
    } catch (_) {
      // Ignoram erorile de check — afisam ce avem deja
    }
    return _svc.getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      await _svc.checkNotifications();
    } catch (_) {}
    state = await AsyncValue.guard(() => _svc.getNotifications());
  }

  Future<void> markRead(String id) async {
    await _svc.markNotificationRead(id);
    state = AsyncData(
      (state.value ?? []).map((n) => n.id == id ? n.copyWithRead() : n).toList(),
    );
  }

  Future<void> markAllRead() async {
    await _svc.markAllRead();
    state = AsyncData(
      (state.value ?? []).map((n) => n.copyWithRead()).toList(),
    );
  }
}

/// Numarul de notificari necitite — folosit pentru badge-ul din nav bar.
final unreadCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider).value ?? [];
  return notifs.where((n) => !n.isRead).length;
});
