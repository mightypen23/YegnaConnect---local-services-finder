import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import 'auth_widgets.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, required this.title, required this.subtitle, required this.submit, required this.switchText, required this.switchRoute, this.signUp = false});
  final String title;
  final String subtitle;
  final String submit;
  final String switchText;
  final String switchRoute;
  final bool signUp;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                const AuthField(label: 'Full name', icon: Icons.person_outline),
                const SizedBox(height: 12),
              ],
              const AuthField(label: 'Email address', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(
                obscureText: !visible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(onPressed: () => setState(() => visible = !visible), icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined)),
                ),
              ),
              if (!widget.signUp) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot password?'))),
              const SizedBox(height: 16),
              AuthButton(label: widget.submit, onPressed: () => context.go('/home')),
              const SizedBox(height: 20),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12))), Expanded(child: Divider())]),
              const SizedBox(height: 20),
              AuthButton(label: 'Continue with Google', outlined: true, icon: SvgPicture.asset('assets/branding/google_logo.svg', width: 22, height: 22), onPressed: () => context.go('/home')),
              const SizedBox(height: 20),
              Center(child: TextButton(onPressed: () => context.go(widget.switchRoute), child: Text(widget.switchText))),
            ],
          ),
        ),
      ),
    );
  }
}
