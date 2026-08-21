import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../widgets/auth_widgets.dart';

class ProviderSignUpScreen extends ConsumerStatefulWidget {
  const ProviderSignUpScreen({super.key});

  @override
  ConsumerState<ProviderSignUpScreen> createState() => _ProviderSignUpScreenState();
}

class _ProviderSignUpScreenState extends ConsumerState<ProviderSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final categoriesLoading = ref.watch(categoriesLoadingProvider);
    final categoriesError = ref.watch(categoriesErrorProvider);

    if (_selectedCategory != null && !categories.any((item) => item.id == _selectedCategory)) {
      _selectedCategory = null;
    }

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

                // Phone Number Field (Required) — Ethiopian format with +251 pre-filled
                EthiopianPhoneField(
                  controller: _phoneController,
                  label: 'Phone number *',
                ),
                const SizedBox(height: 14),

                // Service Offered Dropdown Field (Required)
                if (categoriesLoading)
                  const InputDecorator(
                    decoration: InputDecoration(labelText: 'Loading service categories…', prefixIcon: Icon(Icons.handyman_outlined)),
                    child: LinearProgressIndicator(),
                  )
                else if (categoriesError != null || categories.isEmpty)
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Service categories unavailable', prefixIcon: Icon(Icons.error_outline)),
                    child: Row(children: [
                      Expanded(child: Text(categoriesError ?? 'No service categories found')),
                      TextButton(onPressed: () => ref.read(categoriesProvider.notifier).load(), child: const Text('Retry')),
                    ]),
                  )
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey('provider-category-${categories.length}'),
                    value: _selectedCategory,
                    isExpanded: true,
                    menuMaxHeight: 320,
                    decoration: const InputDecoration(
                      labelText: 'Service you provide *',
                      labelStyle: TextStyle(color: AppTheme.muted, fontSize: 14),
                      prefixIcon: Icon(Icons.handyman_outlined, size: 20, color: AppTheme.muted),
                    ),
                    items: categories.map((c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    validator: (val) => val == null ? 'Please select a service category' : null,
                    onChanged: (val) => setState(() => _selectedCategory = val),
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
                  label: 'Continue',
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && !_submitting) {
                      setState(() => _submitting = true);
                      try {
                        final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
                        if (token == null) throw Exception('Please sign in again before creating a provider profile');
                        await ref.read(marketplaceApiProvider).createProvider(
                          token: token,
                          fullName: _nameController.text,
                          // Bug #3 fix: use full +251XXXXXXXXX number
                          phoneNumber: EthiopianPhoneField.fullNumber(_phoneController),
                          bio: _descriptionController.text,
                          categoryId: _selectedCategory!,
                          location: _locationController.text,
                        );
                        await ref.read(userProvider.notifier).loadFromServer();
                        // Bug #3 fix: mounted check BEFORE using context/ScaffoldMessenger
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Provider profile registered successfully!')),
                        );
                        context.go('/provider-home');
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
                        }
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    }
                  },
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
