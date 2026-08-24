import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';
import '../../../l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose(); _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).register(
          _emailCtrl.text.trim(),
          _passCtrl.text,
          _nameCtrl.text.trim(),
          _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text.trim() : null,
        );
    if (mounted) {
      final state = ref.read(authStateProvider);
      state.whenOrNull(
        data: (user) { if (user != null) context.go('/dashboard'); },
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(parseError(e)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.newAccount),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.register, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(t.fillDetails, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              CmTextField(
                controller: _nameCtrl,
                label: t.fullName,
                hint: 'Ion Popescu',
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.length < 3) ? t.minChars3 : null,
              ),
              const SizedBox(height: 16),
              CmTextField(
                controller: _emailCtrl,
                label: t.email,
                hint: 'email@exemplu.ro',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return t.required;
                  if (!v.contains('@')) return t.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CmTextField(
                controller: _phoneCtrl,
                label: t.phoneOptional,
                hint: '07XX XXX XXX',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              CmTextField(
                controller: _passCtrl,
                label: t.password,
                hint: t.passwordRulesHint,
                obscureText: _obscurePass,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return t.passwordTooShort;
                  if (!v.contains(RegExp(r'[A-Z]'))) return t.passwordNeedsUpper;
                  if (!v.contains(RegExp(r'[0-9]'))) return t.passwordNeedsDigit;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CmTextField(
                controller: _pass2Ctrl,
                label: t.confirmPassword,
                hint: '••••••••',
                obscureText: _obscurePass,
                prefixIcon: Icons.lock_outline,
                validator: (v) => v != _passCtrl.text ? t.passwordsDoNotMatch : null,
              ),
              const SizedBox(height: 28),
              CmButton(label: t.register, isLoading: isLoading, onPressed: isLoading ? null : _register),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: t.haveAccount, style: const TextStyle(color: AppColors.textSecondary)),
                    TextSpan(text: t.login,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
