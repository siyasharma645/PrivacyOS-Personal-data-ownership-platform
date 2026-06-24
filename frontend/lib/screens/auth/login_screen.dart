
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'demo@privacyos.io');
  final _pass = TextEditingController(text: 'Demo@1234');
  bool _obscure = true, _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final err = await ref.read(authProvider.notifier).login(_email.text.trim(), _pass.text);
    if (mounted) {
      setState(() => _loading = false);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.critical));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(children: [
        // Branding panel (wide screens)
        if (MediaQuery.of(context).size.width > 800)
          Container(
            width: 420,
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(right: BorderSide(color: AppColors.border))),
            padding: const EdgeInsets.all(48),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.security, color: Colors.white)),
                const SizedBox(width: 12),
                const Text('PrivacyOS', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 80),
              const Text('Your privacy,\nunder control.', style: TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 16),
              const Text('Understand, monitor, and control your digital footprint across the internet.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.6)),
              const SizedBox(height: 48),
              ...['🛡️ Real-time breach monitoring','🔍 AI-powered permission analysis','📊 Privacy score tracking','🕸️ Interactive data ownership graph'].map((f) =>
                Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
                  Text(f.substring(0,2), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(f.substring(3), style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ]))),
            ]),
          ),
        // Form
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Sign in', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    GestureDetector(onTap: () => context.go('/register'),
                      child: const Text('Create one', style: TextStyle(color: AppColors.brand, fontSize: 13, fontWeight: FontWeight.w500))),
                  ]),
                  const SizedBox(height: 24),
                  // Demo hint
                  Container(padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.brand.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brand.withOpacity(0.3))),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Demo credentials pre-filled', style: TextStyle(color: AppColors.brandLight, fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('email: demo@privacyos.io / Demo@1234', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ])),
                  const SizedBox(height: 20),
                  const Text('EMAIL', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'you@example.com')),
                  const SizedBox(height: 16),
                  const Text('PASSWORD', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  TextFormField(controller: _pass, obscureText: _obscure,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(hintText: '••••••••',
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textMuted),
                        onPressed: () => setState(() => _obscure = !_obscure)))),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Sign in', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    )),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
