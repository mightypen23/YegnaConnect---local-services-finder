import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/notification_model.dart';
import '../../../providers/app_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch fresh notifications every time the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final dateFormat = DateFormat('MMM dd, hh:mm a');
    final hasMore = ref.read(notificationsProvider.notifier).hasMore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllRead();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const Center(
                child: Text('No notifications yet.', style: TextStyle(color: AppTheme.muted)),
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length + (hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }

                  final notif = notifications[index];
                  IconData icon;
                  Color iconColor;

                  switch (notif.type) {
                    case NotificationType.requestAccepted:
                    case NotificationType.requestStatusChanged:
                      icon = Icons.sync_rounded;
                      iconColor = AppTheme.green;
                      break;
                    case NotificationType.requestCompleted:
                      icon = Icons.check_circle_outline_rounded;
                      iconColor = AppTheme.green;
                      break;
                    case NotificationType.requestCancelled:
                      icon = Icons.cancel_outlined;
                      iconColor = Colors.red;
                      break;
                    case NotificationType.newRequest:
                      icon = Icons.add_circle_outline_rounded;
                      iconColor = AppTheme.blue;
                      break;
                    case NotificationType.chatMessage:
                      icon = Icons.chat_bubble_outline_rounded;
                      iconColor = AppTheme.blue;
                      break;
                    case NotificationType.walletCredit:
                      icon = Icons.account_balance_wallet_outlined;
                      iconColor = AppTheme.greenLight;
                      break;
                    case NotificationType.verificationUpdate:
                      icon = Icons.verified_outlined;
                      iconColor = AppTheme.green;
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: notif.isRead ? Colors.white : AppTheme.green.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFF2F6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: .1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.ink),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dateFormat.format(notif.timestamp),
                                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
