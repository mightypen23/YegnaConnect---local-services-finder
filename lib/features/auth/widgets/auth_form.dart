import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_providers.dart';
import 'auth_widgets.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submit,
    required this.switchText,
    required this.switchRoute,
    this.signUp = false,
  });

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
  bool visible = false;
  bool isLoading = false;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      if (widget.signUp) {
        await ref.read(userProvider.notifier).register(
              fullNameController.text,
              emailController.text,
              passwordController.text,
            );
      } else {
        await ref.read(userProvider.notifier).login(
              emailController.text,
              passwordController.text,
            );
      }
      if (mounted) {
        // Bug #1 fix: redirect based on role — providers go to their dashboard
        final role = ref.read(userProvider).role;
        context.go(role == UserRole.provider ? '/provider-home' : '/home');
      }
    } catch (e) {
      if (mounted) {
        // Bug #2 fix: surface the real error message from the API
        final message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isNotEmpty ? message : (widget.signUp ? 'Unable to create account' : 'Invalid email/password'))),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                    controller: fullNameController,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                ],
                AuthField(
                  label: 'Email address',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: !visible,
                  validator: (v) => v!.length < 8 ? 'Min 8 chars' : null,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                        onPressed: () => setState(() => visible = !visible),
                        icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
                  ),
                ),
                if (!widget.signUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot password?')),
                  ),
                const SizedBox(height: 16),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AuthButton(label: widget.submit, onPressed: _submit),
                const SizedBox(height: 20),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Divider())
                ]),
                const SizedBox(height: 20),
                AuthButton(
                    label: 'Continue with Google',
                    outlined: true,
                    icon: SvgPicture.asset('assets/branding/google_logo.svg', width: 22, height: 22),
                    onPressed: () {
                      // Google sign-in to be implemented next
                    }),
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
