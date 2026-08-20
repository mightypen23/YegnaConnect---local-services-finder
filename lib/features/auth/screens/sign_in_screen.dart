import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
class SignInScreen extends StatelessWidget { const SignInScreen({super.key}); @override Widget build(BuildContext context) => const AuthForm(title: 'Welcome back', subtitle: 'Sign in to continue to YegnaConnect', submit: 'Sign in', switchText: 'New here? Create an account', switchRoute: '/sign-up'); }
