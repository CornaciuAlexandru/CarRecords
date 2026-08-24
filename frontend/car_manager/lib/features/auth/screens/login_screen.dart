import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';
import '../../../core/utils/l10n.dart';

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
    final t = AppLocalizations.of(context);
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_car_rounded, size: 72, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text('CarRecords',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(tr(context).loginSubtitle,
                        style: const TextStyle(fontSize: 16, color: Colors.white70)),
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
                      Text(tr(context).loginTitle,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(tr(context).loginSubtitle,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      CmTextField(
                        controller: _emailCtrl,
                        label: tr(context).email,
                        hint: 'email@exemplu.ro',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return tr(context).required;
                          if (!v.contains('@')) return tr(context).invalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CmTextField(
                        controller: _passCtrl,
                        label: tr(context).password,
                        hint: '••••••••',
                        obscureText: _obscurePass,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? tr(context).required : null,
                      ),
                      const SizedBox(height: 24),
                      CmButton(
                        label: tr(context).login,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _login,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(text: tr(context).noAccount, style: const TextStyle(color: AppColors.textSecondary)),
                            TextSpan(text: tr(context).register,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
