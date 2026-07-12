import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
    if (mounted) {
      final state = ref.read(authStateProvider);
      state.whenOrNull(
        data: (user) {
          if (user != null) context.go('/dashboard');
        },
        error: (e, _) => _showError(e),
      );
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(parseError(e)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car_rounded, size: 72, color: Colors.white),
                    SizedBox(height: 12),
                    Text('CarRecords',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    Text('Gestionează-ți mașinile cu ușurință',
                        style: TextStyle(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            // Form card
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bun venit!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Autentifică-te pentru a continua',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      CmTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'email@exemplu.ro',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Câmp obligatoriu';
                          if (!v.contains('@')) return 'Email invalid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CmTextField(
                        controller: _passCtrl,
                        label: 'Parolă',
                        hint: '••••••••',
                        obscureText: _obscurePass,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Câmp obligatoriu' : null,
                      ),
                      const SizedBox(height: 24),
                      CmButton(
                        label: 'Autentificare',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _login,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/register'),
                          child: const Text.rich(TextSpan(children: [
                            TextSpan(text: 'Nu ai cont? ', style: TextStyle(color: AppColors.textSecondary)),
                            TextSpan(text: 'Înregistrează-te',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
