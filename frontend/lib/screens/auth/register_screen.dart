
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true, _loading = false;

  Future<void> _submit() async {
    if (_pass.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 8 characters')));
      return;
    }
    setState(() => _loading = true);
    final err = await ref.read(authProvider.notifier).register(_email.text.trim(), _pass.text, _name.text.trim());
    if (mounted) {
      setState(() => _loading = false);
      if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.critical));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.security, color: Colors.white, size: 20)),
                const SizedBox(width: 10),
                const Text('PrivacyOS', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 32),
              const Text('Create your account', style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have one? ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                GestureDetector(onTap: () => context.go('/login'),
                  child: const Text('Sign in', style: TextStyle(color: AppColors.brand, fontSize: 13, fontWeight: FontWeight.w500))),
              ]),
              const SizedBox(height: 28),
              _label('FULL NAME'),
              const SizedBox(height: 6),
              TextFormField(controller: _name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Alex Rivera')),
              const SizedBox(height: 14),
              _label('EMAIL ADDRESS'),
              const SizedBox(height: 6),
              TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'you@example.com')),
              const SizedBox(height: 14),
              _label('PASSWORD'),
              const SizedBox(height: 6),
              TextFormField(controller: _pass, obscureText: _obscure,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(hintText: 'Min. 8 characters',
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.textMuted),
                    onPressed: () => setState(() => _obscure = !_obscure)))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity,
                child: ElevatedButton(onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)))),
            ]),
          ),
        ),
      ),
    );
  }
  Widget _label(String t) => Align(alignment: Alignment.centerLeft,
    child: Text(t, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)));
}
