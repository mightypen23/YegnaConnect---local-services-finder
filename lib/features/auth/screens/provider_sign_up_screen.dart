import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/category.dart';
import '../widgets/auth_widgets.dart';

class ProviderSignUpScreen extends StatefulWidget {
  const ProviderSignUpScreen({super.key});

  @override
  State<ProviderSignUpScreen> createState() => _ProviderSignUpScreenState();
}

class _ProviderSignUpScreenState extends State<ProviderSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;

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

                // Phone Number Field (Required)
                AuthField(
                  label: 'Phone number *',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Service Offered Dropdown Field (Required)
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Service you provide *',
                    labelStyle: TextStyle(color: AppTheme.muted, fontSize: 14),
                    prefixIcon: Icon(Icons.handyman_outlined, size: 20, color: AppTheme.muted),
                  ),
                  items: ServiceCategory.defaultCategories.map((c) {
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Provider profile registered successfully!')),
                      );
                      context.go('/provider-home');
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
