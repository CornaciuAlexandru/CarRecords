import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../services/purchase_service.dart';

/// Serviciul de cumparari, viu cat traieste aplicatia.
///
/// Ascultarea magazinului nu poate fi legata de ecranul de cumparare: o plata
/// lasata in asteptare se confirma mai tarziu, iar magazinul o livreaza la
/// urmatoarea pornire, cand ecranul ala nu e deschis. De asta providerul se
/// urmareste din radacina aplicatiei.
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService(
    // Dupa ce serverul a acordat, contul se reciteste: planul si scanarile
    // din interfata trebuie sa se schimbe imediat, nu la urmatoarea pornire.
    onGranted: () => ref.read(authStateProvider.notifier).refreshUser(),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});
