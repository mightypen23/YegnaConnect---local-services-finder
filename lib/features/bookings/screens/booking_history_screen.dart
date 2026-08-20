import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/app_providers.dart';
import '../../../models/service_request.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(serviceRequestsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Top Green Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
                    onPressed: () => context.go('/home'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_toggle_off_rounded, color: AppTheme.ink, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Your Booking\nHistory',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.ink,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search for service',
                      prefixIcon: Icon(Icons.search, color: AppTheme.muted),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'recently',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (requests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No booking history yet.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return _BookingHistoryCard(request: req);
                      },
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

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({required this.request});
  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case RequestStatus.accepted:
        statusColor = AppTheme.green;
        break;
      case RequestStatus.pending:
        statusColor = AppTheme.blue;
        break;
      case RequestStatus.inProgress:
        statusColor = AppTheme.accentOrange;
        break;
      case RequestStatus.completed:
        statusColor = AppTheme.greenDark;
        break;
      case RequestStatus.cancelled:
      case RequestStatus.rejected:
        statusColor = AppTheme.accentRed;
        break;
    }

    return InkWell(
      onTap: () => context.push('/request-detail/${request.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFF2F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.border,
              child: const Icon(Icons.person, color: AppTheme.muted, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.providerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text(
                        '4.0 ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: i < 4 ? Colors.amber : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const Text(
                        ' (1.2k)',
                        style: TextStyle(color: AppTheme.muted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '4 skills',
                    style: TextStyle(color: AppTheme.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              request.status.displayName,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
