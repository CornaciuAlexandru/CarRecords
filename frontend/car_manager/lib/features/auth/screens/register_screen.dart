import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/widgets/cm_text_field.dart';
import '../../../shared/widgets/cm_button.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cont nou'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Creează cont', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Completează datele de mai jos', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              CmTextField(
                controller: _nameCtrl,
                label: 'Nume complet',
                hint: 'Ion Popescu',
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.length < 3) ? 'Minim 3 caractere' : null,
              ),
              const SizedBox(height: 16),
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
                controller: _phoneCtrl,
                label: 'Telefon (opțional)',
                hint: '07XX XXX XXX',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              CmTextField(
                controller: _passCtrl,
                label: 'Parolă',
                hint: 'Min. 8 caractere, 1 majusculă, 1 cifră',
                obscureText: _obscurePass,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Minim 8 caractere';
                  if (!v.contains(RegExp(r'[A-Z]'))) return 'Trebuie cel puțin o literă mare';
                  if (!v.contains(RegExp(r'[0-9]'))) return 'Trebuie cel puțin o cifră';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CmTextField(
                controller: _pass2Ctrl,
                label: 'Confirmă parola',
                hint: '••••••••',
                obscureText: _obscurePass,
                prefixIcon: Icons.lock_outline,
                validator: (v) => v != _passCtrl.text ? 'Parolele nu coincid' : null,
              ),
              const SizedBox(height: 28),
              CmButton(label: 'Înregistrare', isLoading: isLoading, onPressed: isLoading ? null : _register),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text.rich(TextSpan(children: [
                    TextSpan(text: 'Ai deja cont? ', style: TextStyle(color: AppColors.textSecondary)),
                    TextSpan(text: 'Autentifică-te',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
