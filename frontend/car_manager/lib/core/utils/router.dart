import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/cars/screens/add_car_screen.dart';
import '../../features/cars/screens/car_detail_screen.dart';
import '../../features/vignette/screens/vignettes_screen.dart';
import '../../features/vignette/screens/add_vignette_screen.dart';
import '../../features/insurance/screens/insurance_screen.dart';
import '../../features/insurance/screens/add_insurance_screen.dart';
import '../../features/maintenance/screens/maintenance_screen.dart';
import '../../features/maintenance/screens/add_maintenance_screen.dart';
import '../../features/modifications/screens/modifications_screen.dart';
import '../../features/modifications/screens/add_modification_screen.dart';
import '../../features/registration/screens/registration_screen.dart';
import '../../features/registration/screens/add_registration_screen.dart';
import '../../core/models/documents.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (authState.isLoading) return null;
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',  builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),

      GoRoute(path: '/cars/add', builder: (_, __) => const AddCarScreen()),

      GoRoute(
        path: '/cars/:carId',
        builder: (_, s) => CarDetailScreen(carId: s.pathParameters['carId']!),
        routes: [
          // ── Roviniete ──────────────────────────────────────
          GoRoute(
            path: 'vignettes',
            builder: (_, s) => VignettesScreen(carId: s.pathParameters['carId']!),
          ),
          GoRoute(
            path: 'vignette/add',
            builder: (_, s) => AddVignetteScreen(
              carId: s.pathParameters['carId']!,
              existing: s.extra as Vignette?,
            ),
          ),

          // ── Asigurări ──────────────────────────────────────
          GoRoute(
            path: 'insurance',
            builder: (_, s) => InsuranceScreen(carId: s.pathParameters['carId']!),
          ),
          GoRoute(
            path: 'insurance/add',
            builder: (_, s) => AddInsuranceScreen(
              carId: s.pathParameters['carId']!,
              initialType: s.uri.queryParameters['type'] ?? 'RCA',
              existing: s.extra as InsurancePolicy?,
            ),
          ),

          // ── Talon / ITP ────────────────────────────────────
          GoRoute(
            path: 'registrations',
            builder: (_, s) => RegistrationScreen(carId: s.pathParameters['carId']!),
          ),
          GoRoute(
            path: 'registration/add',
            builder: (_, s) => AddRegistrationScreen(
              carId: s.pathParameters['carId']!,
              existing: s.extra as VehicleRegistration?,
            ),
          ),

          // ── Service & Mentenanță ───────────────────────────
          GoRoute(
            path: 'maintenance',
            builder: (_, s) => MaintenanceScreen(carId: s.pathParameters['carId']!),
          ),
          GoRoute(
            path: 'maintenance/add',
            builder: (_, s) => AddMaintenanceScreen(
              carId: s.pathParameters['carId']!,
              existing: s.extra as MaintenanceRecord?,
            ),
          ),

          // ── Modificări ─────────────────────────────────────
          GoRoute(
            path: 'modifications',
            builder: (_, s) => ModificationsScreen(carId: s.pathParameters['carId']!),
          ),
          GoRoute(
            path: 'modifications/add',
            builder: (_, s) => AddModificationScreen(
              carId: s.pathParameters['carId']!,
              existing: s.extra as CarModification?,
            ),
          ),
        ],
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
