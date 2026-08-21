import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../../models/service_request.dart';

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
  
  String? _selectedCategory;
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 3));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerSearchProvider);
    final categories = ref.watch(categoriesProvider);
    _selectedCategory ??= categories.isNotEmpty ? categories.first.id : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  value: _selectedCategory,
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
                    if (val != null) setState(() => _selectedCategory = val);
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (providers.isEmpty || _selectedCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Services are still loading. Please try again.')));
                          return;
                        }
                        final submitted = await ref.read(serviceRequestsProvider.notifier).create(
                          categoryId: _selectedCategory!,
                          description: '${_titleController.text}\n${_descriptionController.text}\nLocation: ${_locationController.text}',
                          providerId: providers.first.id,
                        );
                        if (!context.mounted) return;
                        if (!submitted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit request. Please sign in and check your connection.')));
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Service request submitted successfully!')),
                        );
                        context.go('/history');
                      }
                    },
                    child: const Text('Submit Service Request'),
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
