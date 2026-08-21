import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../providers/app_providers.dart';
import '../../../models/category.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  ConsumerState<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Mexico, Addis Ababa');

  String? _selectedCategoryId;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<ServiceCategory> categories) async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) return;
    final providers = ref.read(providerSearchProvider);

    setState(() => _submitting = true);
    try {
      await ref.read(serviceRequestsProvider.notifier).createRequest(
            categoryId: _selectedCategoryId!,
            description: '${_titleController.text}\n${_descriptionController.text}',
            providerId: providers.isNotEmpty ? providers.first.id : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service request submitted successfully!')),
      );
      context.go('/history');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Request'),
      ),
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text('Failed to load categories: $err')),
          data: (categories) {
            _selectedCategoryId ??= categories.isNotEmpty ? categories.first.id : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Category',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.title),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategoryId = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Service Title / Summary',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Repair leaking pipe in kitchen',
                        prefixIcon: Icon(Icons.build_outlined),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter service title' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Description & Special Instructions',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Provide details about what work needs to be done...',
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter description' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Location / Service Address',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter location' : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _submitting ? null : () => _submit(categories),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Submit Service Request'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
