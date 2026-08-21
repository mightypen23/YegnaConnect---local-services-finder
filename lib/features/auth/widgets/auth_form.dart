import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key, required this.title, required this.subtitle, required this.submit, required this.switchText, required this.switchRoute, this.signUp = false});
  final String title;
  final String subtitle;
  final String submit;
  final String switchText;
  final String switchRoute;
  final bool signUp;
  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool visible = false;
  bool _submitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      if (widget.signUp) {
        await ref.read(authProvider.notifier).register(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      } else {
        await ref.read(authProvider.notifier).login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
      // Navigation on success is handled by the router's auth redirect.
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
                const SizedBox(height: 10),
                const Center(child: AuthLogo(width: 140)),
                const SizedBox(height: 24),
                Text(widget.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 7),
                Text(widget.subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 15)),
                const SizedBox(height: 24),
                if (widget.signUp) ...[
                  AuthField(
                    label: 'Full name',
                    icon: Icons.person_outline,
                    controller: _fullNameController,
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 12),
                ],
                AuthField(
                  label: 'Email address',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !visible,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    if (widget.signUp && val.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(onPressed: () => setState(() => visible = !visible), icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
                  ),
                ),
                if (!widget.signUp) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot password?'))),
                const SizedBox(height: 16),
                AuthButton(
                  label: _submitting ? 'Please wait...' : widget.submit,
                  onPressed: _submitting ? () {} : _submit,
                ),
                const SizedBox(height: 20),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12))), Expanded(child: Divider())]),
                const SizedBox(height: 20),
                AuthButton(
                  label: 'Continue with Google',
                  outlined: true,
                  icon: SvgPicture.asset('assets/branding/google_logo.svg', width: 22, height: 22),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google sign-in is coming soon')),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: TextButton(onPressed: () => context.go(widget.switchRoute), child: Text(widget.switchText))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
