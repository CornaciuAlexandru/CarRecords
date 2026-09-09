import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/purchase_provider.dart';
import 'core/services/ads_service.dart';
import 'core/services/notification_scheduler.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'core/widgets/startup_wrapper.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Reclamele se initializeaza in fundal — pornirea aplicatiei nu asteapta
  // dupa ele, iar pe Windows apelul nu face nimic.
  AdsService.instance.initialize();
  // La fel si notificarile: initializarea citeste fusul orar si inregistreaza
  // canalul, dar nu programeaza nimic pana nu stim al cui e telefonul.
  NotificationScheduler.instance.initialize();
  runApp(const ProviderScope(child: CarRecordsApp()));
}

class CarRecordsApp extends ConsumerWidget {
  const CarRecordsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    // Tinut viu de la radacina: o plata lasata in asteptare se confirma mai
    // tarziu si e livrata la urmatoarea pornire, cand ecranul de cumparare nu
    // e deschis. Fara ascultarea asta, omul ar plati fara sa primeasca nimic.
    ref.watch(purchaseServiceProvider);

    return StartupWrapper(
      child: MaterialApp.router(
        title: 'CarRecords',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    );
  }
}
