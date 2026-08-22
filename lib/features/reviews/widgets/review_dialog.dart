import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/service_request.dart';
import '../../../providers/network_providers.dart';
import '../../../core/network/api_client.dart';

class ReviewDialog extends ConsumerStatefulWidget {
  const ReviewDialog({
    super.key,
    required this.request,
  });

  final ServiceRequest request;

  @override
  ConsumerState<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<ReviewDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.dio.post('/reviews', data: {
        'provider_id': widget.request.providerId,
        'request_id': widget.request.id,
        'rating': _rating.toInt(),
        if (_commentController.text.trim().isNotEmpty)
          'comment': _commentController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for submitting your review!')),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e is ApiException ? e.message : e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rate & Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.ink),
            ),
            const SizedBox(height: 6),
            Text(
              'How was your experience with ${widget.request.providerName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Interactive 1-5 Star Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  icon: Icon(
                    starValue <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = starValue),
                );
              }),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a comment about the service (optional)...',
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _submitting ? null : _submitReview,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
