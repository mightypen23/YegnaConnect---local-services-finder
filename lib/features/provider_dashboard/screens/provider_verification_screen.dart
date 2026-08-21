import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() => _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState extends State<ProviderVerificationScreen> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    Icon(Icons.verified_user_outlined, color: AppTheme.green, size: 30),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Get verified to display the verified badge and rank higher in customer searches.',
                        style: TextStyle(color: AppTheme.ink, fontSize: 13, fontWeight: FontWeight.bold),
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
                      Icon(Icons.hourglass_top_rounded, color: AppTheme.blue, size: 48),
                      SizedBox(height: 12),
                      Text('Verification Under Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 6),
                      Text('Our admin team is reviewing your documents. Verification takes 24-48 hours.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                    ],
                  ),
                ),
              ] else ...[
                const Text('National ID / Kebele Card Number', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const TextField(decoration: InputDecoration(hintText: 'Enter ID number')),
                const SizedBox(height: 16),

                const Text('Trade License / Certificate (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Document Photo'),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => setState(() => _submitted = true),
                    child: const Text('Submit Verification Details'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
