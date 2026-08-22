import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool _codeSent = false;
  bool _submitting = false;
  String? _devCode;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final fullPhone = EthiopianPhoneField.fullNumber(_phoneController);
      final devCode = await ref
          .read(authProvider.notifier)
          .requestOtp(phoneNumber: fullPhone);
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _devCode = devCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            devCode != null
                ? 'Verification code sent! (Dev code: $devCode)'
                : 'Verification code sent to $fullPhone',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final fullPhone = EthiopianPhoneField.fullNumber(_phoneController);
      await ref
          .read(authProvider.notifier)
          .verifyOtp(phoneNumber: fullPhone, code: _codeController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account verified and logged in!')),
      );
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
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
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 25),
                const Center(child: AuthLogo(width: 140)),
                const SizedBox(height: 28),
                Text(
                  _codeSent ? 'Enter Verification Code' : 'Reset Account via OTP',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? 'Enter the 6-digit code sent to your phone number.'
                      : 'Enter your phone number to receive a 6-digit OTP code.',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                ),
                const SizedBox(height: 24),
                if (!_codeSent) ...[
                  EthiopianPhoneField(controller: _phoneController),
                  const SizedBox(height: 24),
                  AuthButton(
                    label: _submitting ? 'Sending code...' : 'Send Verification Code',
                    onPressed: _submitting ? () {} : _handleRequestOtp,
                  ),
                ] else ...[
                  if (_devCode != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.greenLight.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.greenLight),
                      ),
                      child: Text(
                        'Development Code: $_devCode',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.greenLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (val) => val == null || val.trim().length != 6
                        ? 'Enter 6-digit code'
                        : null,
                    decoration: const InputDecoration(
                      labelText: '6-Digit Verification Code',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.security_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    label: _submitting ? 'Verifying...' : 'Verify & Continue',
                    onPressed: _submitting ? () {} : _handleVerifyOtp,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _codeSent = false),
                      child: const Text('Change Phone Number'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
