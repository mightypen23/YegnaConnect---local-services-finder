import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/network_providers.dart';

class ProviderVerificationScreen extends ConsumerStatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  ConsumerState<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends ConsumerState<ProviderVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  String? _documentName;
  bool _submitted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.dio.post('/providers/me/verification', data: {
        'id_number': _idController.text.trim(),
        if (_documentName != null) 'evidence_url': _documentName,
      });
      if (!mounted) return;
      setState(() {
        _submitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification details submitted successfully!'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_outlined,
                          color: AppTheme.green, size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Get verified to display the verified badge and rank higher in customer searches.',
                          style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_submitted) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF2F6)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.hourglass_top_rounded,
                            color: AppTheme.blue, size: 48),
                        SizedBox(height: 12),
                        Text('Verification Under Review',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 6),
                        Text(
                            'Our admin team is reviewing your documents. Verification takes 24-48 hours.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppTheme.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text('National ID / Kebele Card Number',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _idController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'ID number is required'
                        : null,
                    decoration: const InputDecoration(
                      hintText: 'Enter ID number',
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Trade License / Certificate (Optional)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _documentName = 'kebele_id_document.pdf';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document attached: kebele_id_document.pdf'),
                        ),
                      );
                    },
                    icon: Icon(
                      _documentName != null
                          ? Icons.check_circle_outline
                          : Icons.upload_file,
                      color: _documentName != null ? AppTheme.green : null,
                    ),
                    label: Text(_documentName ?? 'Upload Document Photo'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submitVerification,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit Verification Details'),
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
