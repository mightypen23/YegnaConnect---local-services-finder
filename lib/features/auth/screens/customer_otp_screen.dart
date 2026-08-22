import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

/// OTP verification screen shown after a customer fills in their phone
/// during sign-up. Expects GoRouter `extra` to be a Map with keys:
///   - `phoneNumber` (String) – the full E.164 phone number
///   - `devCode`    (String?) – populated only in development mode
class CustomerOtpScreen extends ConsumerStatefulWidget {
  const CustomerOtpScreen({
    super.key,
    required this.phoneNumber,
    this.devCode,
  });

  final String phoneNumber;
  final String? devCode;

  @override
  ConsumerState<CustomerOtpScreen> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends ConsumerState<CustomerOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _submitting = false;
  bool _resending = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(authProvider.notifier).verifyCustomerOtp(
            phoneNumber: widget.phoneNumber,
            code: code,
          );
      // Router will redirect to /home on AuthStatus.authenticated.
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      // Clear the boxes so the user can re-enter.
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;
    setState(() => _resending = true);
    try {
      await ref.read(authProvider.notifier).requestOtp(
            phoneNumber: widget.phoneNumber,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent')),
      );
      _startCooldown();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('[CustomerOtpScreen] devCode = ${widget.devCode}');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 10),
              const Center(child: AuthLogo(width: 140)),
              const SizedBox(height: 32),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sms_outlined, size: 40, color: AppTheme.green),
                ),
              ),
              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Verify your phone',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Enter the 6-digit code below',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),

              // Dev mode: show the code visibly so the customer can type it in
              if (widget.devCode != null) ...
                [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.green.withValues(alpha: .3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your verification code',
                          style: TextStyle(color: AppTheme.muted, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.devCode!,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.green,
                            letterSpacing: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

              // 6-box OTP input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextFormField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E4EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        // Auto-submit when all 6 digits are filled.
                        if (_otpCode.length == 6 && !_submitting) _verify();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Verify button
              AuthButton(
                label: _submitting ? 'Verifying...' : 'Verify & Continue',
                onPressed: _submitting ? () {} : _verify,
              ),
              const SizedBox(height: 24),

              // Resend code
              Center(
                child: _resending
                    ? const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.green)
                    : TextButton(
                        onPressed: _resendCooldown > 0 ? null : _resend,
                        child: Text(
                          _resendCooldown > 0
                              ? 'Resend code in ${_resendCooldown}s'
                              : 'Resend code',
                          style: TextStyle(
                            color: _resendCooldown > 0 ? AppTheme.muted : AppTheme.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
