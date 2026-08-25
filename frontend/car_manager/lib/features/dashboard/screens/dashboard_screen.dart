import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cars/providers/cars_provider.dart';
import '../../cars/screens/cars_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../admin/screens/admin_screen.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/utils/l10n.dart';
import '../../../core/utils/error_handler.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final isAdmin = user?.isAdmin ?? false;

    final unread = ref.watch(unreadCountProvider);

    final pages = [
      const _HomeTab(),
      const CarsScreen(),
      const NotificationsScreen(),
      const ProfilePage(),
      if (isAdmin) const AdminScreen(),
    ];

    // Clampam indexul in caz ca s-a schimbat rolul in timp ce ecranul era deschis
    final safeIndex = _selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: tr(context).navHome),
          NavigationDestination(
              icon: const Icon(Icons.directions_car_outlined),
              selectedIcon: const Icon(Icons.directions_car),
              label: tr(context).navCars),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread', style: const TextStyle(fontSize: 10)),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread', style: const TextStyle(fontSize: 10)),
              child: const Icon(Icons.notifications),
            ),
            label: tr(context).navAlerts,
          ),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: tr(context).navProfile),
          if (isAdmin)
            NavigationDestination(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: const Icon(Icons.admin_panel_settings),
                label: tr(context).navAdmin),
        ],
      ),
    );
  }
}

// ── Home Tab ───────────────────────────────────────────────────────────────
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final authAsync = ref.watch(authStateProvider);
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: authAsync.whenOrNull(
          data: (user) => Text(tr(context).greeting(user?.fullName.split(' ').first ?? '')),
        ) ?? const Text('CarRecords'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(carsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            carsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
              data: (cars) => _SummarySection(cars: cars, t: t),
            ),
            const SizedBox(height: 20),
            // Recent cars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr(context).myCars, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text(tr(context).viewAll)),
              ],
            ),
            const SizedBox(height: 8),
            carsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
              data: (cars) => cars.isEmpty
                  ? _QuickAddCard(onTap: () => context.push('/cars/add'))
                  : Column(
                      children: cars.take(3).map((c) => _QuickCarTile(car: c)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final List<Car> cars;
  final AppLocalizations t;
  const _SummarySection({required this.cars, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: tr(context).navCars, value: '${cars.length}',
            icon: Icons.directions_car, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: tr(context).statActiveAlerts, value: '0',
            icon: Icons.warning_amber_rounded, color: AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: tr(context).statExpired, value: '0',
            icon: Icons.error_outline, color: AppColors.danger)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuickCarTile extends StatelessWidget {
  final Car car;
  const _QuickCarTile({required this.car});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.directions_car, color: Colors.white, size: 20),
        ),
        title: Text(car.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(car.licensePlate),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => context.push('/cars/${car.id}'),
      ),
    );
  }
}

class _QuickAddCard extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickAddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).addFirstCar, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Adresa se confirma din browser, in afara aplicatiei. La deschiderea
    // profilului recitim contul, ca avertismentul sa dispara imediat ce
    // utilizatorul a apasat linkul din email.
    final user = ref.read(authStateProvider).value;
    if (user != null && !user.emailVerified) {
      Future.microtask(() => ref.read(authStateProvider.notifier).refreshUser());
    }
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.danger : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).value;
    final lang = ref.watch(localeProvider).languageCode;
    final current = kSupportedLanguages.firstWhere((l) => l.code == lang,
        orElse: () => kSupportedLanguages.first);
    return Scaffold(
      appBar: AppBar(title: Text(tr(context).navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(radius: 40, backgroundColor: AppColors.primary,
              child: Text(user?.fullName.substring(0, 1) ?? '?',
                  style: const TextStyle(fontSize: 32, color: Colors.white))),
          const SizedBox(height: 12),
          Center(child: Text(user?.fullName ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 32),
          // Starea adresei de email: neconfirmata inseamna cont nerecuperabil
          // daca se uita parola, deci merita scos in fata.
          if (user != null && !user.emailVerified)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined, color: AppColors.warning),
                title: Text(tr(context).emailNotVerified),
                subtitle: Text(tr(context).emailNotVerifiedHint,
                    style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.send_outlined, size: 18),
                onTap: _resendVerification,
              ),
            )
          else if (user != null)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.verified_outlined, color: AppColors.success),
                title: Text(tr(context).emailVerified),
              ),
            ),
          // Selector de limba
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: Text(tr(context).language),
              subtitle: Text('${current.flag}  ${current.label}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              onTap: () => _showLanguagePicker(context, ref, t),
            ),
          ),
          // Optiuni de confidentialitate pentru reclame (cerinta GDPR).
          // Apare doar pe platformele cu reclame si doar daca Google
          // considera ca utilizatorul trebuie sa poata reveni asupra alegerii.
          FutureBuilder<bool>(
            future: AdsService.instance.privacyOptionsRequired,
            builder: (context, snap) {
              if (snap.data != true) return const SizedBox.shrink();
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppColors.primary),
                  title: Text(tr(context).privacyOptions),
                  subtitle: Text(tr(context).privacyOptionsHint,
                      style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                  onTap: () => AdsService.instance.showPrivacyOptions(),
                ),
              );
            },
          ),
          ListTile(leading: const Icon(Icons.logout, color: AppColors.danger),
              title: Text(tr(context).logout, style: const TextStyle(color: AppColors.danger)),
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }),
          const Divider(height: 32),
          // Stergerea contului: cerinta obligatorie Google Play.
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: AppColors.danger),
            title: Text(tr(context).deleteAccount,
                style: const TextStyle(color: AppColors.danger)),
            subtitle: Text(tr(context).deleteAccountHint,
                style: const TextStyle(fontSize: 12)),
            onTap: _confirmDeleteAccount,
          ),
        ],
      ),
    );
  }

  /// Retrimite linkul de confirmare a adresei de email.
  Future<void> _resendVerification() async {
    try {
      await ref.read(authStateProvider.notifier).resendVerification();
      if (!mounted) return;
      _toast(tr(context).verificationSent);
    } catch (e) {
      if (!mounted) return;
      _toast(parseError(context, e), error: true);
    }
  }

  /// Stergerea contului, confirmata cu parola.
  ///
  /// Parola nu e formalitate: un telefon lasat deblocat nu trebuie sa fie
  /// de ajuns ca sa dispara toate datele.
  Future<void> _confirmDeleteAccount() async {
    final passCtrl = TextEditingController();
    final deleted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String? error;
        bool busy = false;
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            title: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              const SizedBox(width: 10),
              Expanded(child: Text(tr(ctx).deleteAccount)),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(ctx).deleteAccountConfirm),
                const SizedBox(height: 16),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: tr(ctx).deleteAccountPassword,
                    errorText: error,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(ctx, false),
                child: Text(tr(ctx).cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: busy
                    ? null
                    : () async {
                        setLocal(() { busy = true; error = null; });
                        try {
                          await ref
                              .read(authStateProvider.notifier)
                              .deleteAccount(passCtrl.text);
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } catch (e) {
                          setLocal(() {
                            busy = false;
                            error = parseError(ctx, e);
                          });
                        }
                      },
                child: Text(tr(ctx).deleteAccountButton),
              ),
            ],
          ),
        );
      },
    );

    passCtrl.dispose();
    if (deleted == true && mounted) {
      _toast(tr(context).accountDeleted);
      context.go('/login');
    }
  }

  /// Dialog de alegere a limbii aplicatiei.
  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppLocalizations t) {
    final currentCode = ref.read(localeProvider).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.language, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(tr(context).languageChoose),
        ]),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SizedBox(
          width: 320,
          child: ListView(
            shrinkWrap: true,
            children: kSupportedLanguages.map((l) {
              final selected = l.code == currentCode;
              return ListTile(
                leading: Text(l.flag, style: const TextStyle(fontSize: 24)),
                title: Text(l.label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? AppColors.primary : null,
                    )),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLanguage(l.code);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr(context).cancel)),
        ],
      ),
    );
  }
}
