import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProviderProfileEditScreen extends ConsumerStatefulWidget {
  const ProviderProfileEditScreen({super.key});

  @override
  ConsumerState<ProviderProfileEditScreen> createState() => _ProviderProfileEditScreenState();
}

class _ProviderProfileEditScreenState extends ConsumerState<ProviderProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  final List<String> _services = ['Tv/Dish', 'Electrician', 'Plumber'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Solomon Getachew');
    _phoneController = TextEditingController(text: '+251-912345678');
    _locationController = TextEditingController(text: 'Kality, Addis Abeba');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Top Green Gradient Header with Avatar Edit Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.border,
                          child: const Icon(Icons.person, size: 55, color: AppTheme.muted),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Full Name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.ink),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Phone No',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.ink),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Services',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.ink),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ..._services.map((s) {
                          return Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => _services.remove(s)),
                            backgroundColor: const Color(0xFFF4F7F9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          );
                        }),
                        ActionChip(
                          label: const Text('Add...', style: TextStyle(color: AppTheme.blue, fontSize: 12)),
                          onPressed: () {
                            setState(() => _services.add('Painting'));
                          },
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.ink),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Save Changes Green Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Provider profile updated successfully')),
                        );
                        context.pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.greenLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
