import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
class SignUpScreen extends StatelessWidget { const SignUpScreen({super.key}); @override Widget build(BuildContext context) => const AuthForm(title: 'Create your account', subtitle: 'Connect with trusted local services', submit: 'Create account', switchText: 'Already have an account? Sign in', switchRoute: '/sign-in', signUp: true); }
