import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/ads_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'core/widgets/startup_wrapper.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Reclamele se initializeaza in fundal — pornirea aplicatiei nu asteapta
  // dupa ele, iar pe Windows apelul nu face nimic.
  AdsService.instance.initialize();
  runApp(const ProviderScope(child: CarRecordsApp()));
}

class CarRecordsApp extends ConsumerWidget {
  const CarRecordsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

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
