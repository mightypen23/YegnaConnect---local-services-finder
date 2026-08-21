import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<ChatConversation> _conversations = [
    ChatConversation(
      requestId: 'req_101',
      providerId: 'prov_1',
      providerName: 'Solomon Getaw',
      customerId: 'usr_001',
      customerName: 'Jhon Sheferaw',
      lastMessage: 'Okay, Sure when am arrive I will call',
      lastMessageTime: DateTime.now(),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatConversation(
      requestId: 'req_102',
      providerId: 'prov_2',
      providerName: 'Nardos Tesfaye',
      customerId: 'usr_001',
      customerName: 'Jhon Sheferaw',
      lastMessage: 'I can come tomorrow morning at 9 AM.',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: true,
    ),
    ChatConversation(
      requestId: 'req_103',
      providerId: 'prov_3',
      providerName: 'Abebe sheferaw',
      customerId: 'usr_001',
      customerName: 'Jhon Sheferaw',
      lastMessage: 'Pipe leak is fixed completely.',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatConversation(
      requestId: 'req_104',
      providerId: 'prov_4',
      providerName: 'Sitota Tesfaw',
      customerId: 'usr_001',
      customerName: 'Jhon Sheferaw',
      lastMessage: 'Color options sent for living room.',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.ink, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Contact Service\nProviders',
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
                      hintText: 'Search providers',
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
                    'Messages',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final chat = _conversations[index];
                      return _ChatConversationCard(chat: chat);
                    },
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'there is no any other recently chat',
                      style: TextStyle(color: AppTheme.muted, fontSize: 13),
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

class _ChatConversationCard extends StatelessWidget {
  const _ChatConversationCard({required this.chat});
  final ChatConversation chat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/chat-conversation/${chat.providerId}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFF2F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.border,
                  child: const Icon(Icons.person, color: AppTheme.muted, size: 28),
                ),
                if (chat.isOnline)
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.providerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.isOnline ? 'online' : 'last seen recently',
                    style: TextStyle(
                      fontSize: 12,
                      color: chat.isOnline ? AppTheme.green : AppTheme.muted,
                      fontWeight: chat.isOnline ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.accentRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
