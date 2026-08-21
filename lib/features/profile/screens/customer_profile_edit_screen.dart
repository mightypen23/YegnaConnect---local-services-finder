import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../auth/widgets/auth_widgets.dart';

class CustomerProfileEditScreen extends ConsumerStatefulWidget {
  const CustomerProfileEditScreen({super.key});

  @override
  ConsumerState<CustomerProfileEditScreen> createState() =>
      _CustomerProfileEditScreenState();
}

class _CustomerProfileEditScreenState
    extends ConsumerState<CustomerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  // Holds the 9-digit suffix (without +251) for the EthiopianPhoneField
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  Uint8List? _profileBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user.fullName);
    // Strip +251 prefix so the field shows only the 9-digit part
    final phone = user.phoneNumber;
    _phoneController = TextEditingController(
      text: phone.startsWith('+251') ? phone.substring(4) : phone,
    );
    _locationController = TextEditingController(text: user.location);
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
    final user = ref.watch(userProvider);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Top Green Gradient Header with Avatar Edit Icon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppTheme.ink),
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
                    // Avatar with Camera Icon
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.border,
                            backgroundImage: _profileBytes != null
                                ? MemoryImage(_profileBytes!)
                                : (user.profileImage != null
                                    ? NetworkImage(user.profileImage!)
                                    : null),
                            child: _profileBytes == null &&
                                    user.profileImage == null
                                ? const Icon(Icons.person,
                                    size: 55, color: AppTheme.muted)
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.green,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              final picked = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                  maxWidth: 800);
                              if (picked == null) return;
                              final bytes = await picked.readAsBytes();
                              if (mounted) setState(() => _profileBytes = bytes);
                            },
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 16),
                          ),
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
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Name is required' : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Phone No',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    // Bug #5 fix: replaced plain TextField with validated EthiopianPhoneField
                    EthiopianPhoneField(controller: _phoneController),
                    const SizedBox(height: 16),

                    const Text(
                      'Location',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
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
                        onPressed: _saving
                            ? null
                            : () async {
                                // Bug #5 fix: validate before saving
                                if (!_formKey.currentState!.validate()) return;
                                setState(() => _saving = true);
                                try {
                                  await ref
                                      .read(userProvider.notifier)
                                      .updateProfile(
                                        fullName: _nameController.text,
                                        phoneNumber: EthiopianPhoneField
                                            .fullNumber(_phoneController),
                                        location: _locationController.text,
                                        profileImage: _profileBytes == null
                                            ? null
                                            : 'data:image/jpeg;base64,${base64Encode(_profileBytes!)}',
                                      );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Profile updated successfully')),
                                  );
                                  context.pop();
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(e
                                              .toString()
                                              .replaceFirst('Exception: ', ''))),
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.greenLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
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
      ),
    );
  }
}
