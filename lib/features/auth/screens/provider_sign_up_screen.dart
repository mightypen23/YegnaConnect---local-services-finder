import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/category.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class ProviderSignUpScreen extends ConsumerStatefulWidget {
  const ProviderSignUpScreen({super.key});

  @override
  ConsumerState<ProviderSignUpScreen> createState() => _ProviderSignUpScreenState();
}

class _ProviderSignUpScreenState extends ConsumerState<ProviderSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _passwordVisible = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final fullPhone = EthiopianPhoneField.fullNumber(_phoneController);
      final devCode = await ref.read(authProvider.notifier).initiateProviderRegistration(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: fullPhone,
            location: _locationController.text.trim(),
          );
      
      if (!mounted) return;
      setState(() => _submitting = false);
      _showOtpDialog(fullPhone, devCode);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _showOtpDialog(String phoneNumber, String? devCode) {
    final codeController = TextEditingController();
    bool verifying = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Verify your phone number',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.ink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to $phoneNumber',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (devCode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dev code: $devCode',
                      style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: '6-Digit Verification Code',
                      hintText: '123456',
                      prefixIcon: Icon(Icons.security_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: verifying
                          ? null
                          : () async {
                              if (codeController.text.trim().length != 6) return;
                              setModalState(() => verifying = true);
                              try {
                                await ref.read(authProvider.notifier).finalizeProviderRegistration(
                                      phoneNumber: phoneNumber,
                                      code: codeController.text.trim(),
                                      fullName: _nameController.text.trim(),
                                      location: _locationController.text.trim(),
                                      bio: _descriptionController.text.trim(),
                                      categoryId: _selectedCategory!,
                                    );
                                // Router handles navigation to provider dashboard on AuthState change
                                if (ctx.mounted) Navigator.pop(ctx);
                              } on ApiException catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.message)));
                                }
                                setModalState(() => verifying = false);
                              }
                            },
                      child: verifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Verify & Create Account', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
                ),
                const SizedBox(height: 10),
                const Center(child: AuthLogo(width: 140)),
                const SizedBox(height: 24),
                const Text(
                  'Become a service provider',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Tell clients about you and the services you offer.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 15),
                ),
                const SizedBox(height: 24),

                // Full Name Field (Required)
                AuthField(
                  label: 'Full name *',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                AuthField(
                  label: 'Email address *',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!val.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    if (val.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone Number Field (Required)
                EthiopianPhoneField(
                  controller: _phoneController,
                  label: 'Phone number *',
                ),
                const SizedBox(height: 14),

                // Service Offered Dropdown Field (Required)
                categories.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const Text(
                    'Could not load service categories. Check your connection and try again.',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  data: (items) => DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Service you provide *',
                      labelStyle: TextStyle(color: AppTheme.muted, fontSize: 14),
                      prefixIcon: Icon(Icons.handyman_outlined, size: 20, color: AppTheme.muted),
                    ),
                    items: items.map((ServiceCategory c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.title,
                          style: const TextStyle(color: AppTheme.ink, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a service category';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Location / City Field (Required)
                AuthField(
                  label: 'Location / city *',
                  icon: Icons.location_on_outlined,
                  controller: _locationController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Location is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Short Description Field (Required)
                AuthField(
                  label: 'Short description *',
                  icon: Icons.notes_outlined,
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Short description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                AuthButton(
                  label: _submitting ? 'Creating your profile...' : 'Continue',
                  onPressed: _submitting ? () {} : _submit,
                ),
                const SizedBox(height: 16),

                // Already have an account option
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/sign-in'),
                    child: const Text(
                      'Already have a provider account? Sign in',
                      style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
