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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Acasă'),
          const NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'Mașini'),
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
            label: 'Alerte',
          ),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil'),
          if (isAdmin)
            const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: 'Admin'),
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
    final authAsync = ref.watch(authStateProvider);
    final carsAsync = ref.watch(carsProvider);

    return Scaffold(
      appBar: AppBar(
        title: authAsync.whenOrNull(
          data: (user) => Text('Bună, ${user?.fullName.split(' ').first ?? ''}! 👋'),
        ) ?? const Text('CarManager'),
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
              data: (cars) => _SummarySection(cars: cars),
            ),
            const SizedBox(height: 20),
            // Recent cars
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mașinile mele', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Vezi toate')),
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
  const _SummarySection({required this.cars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Mașini', value: '${cars.length}',
            icon: Icons.directions_car, color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Alerte active', value: '0',
            icon: Icons.warning_amber_rounded, color: AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Expirate', value: '0',
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
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
              SizedBox(width: 12),
              Text('Adaugă prima mașină', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
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
          ListTile(leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Deconectare', style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }),
        ],
      ),
    );
  }
}
