import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';
import '../../../providers/app_providers.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.providerId,
  });

  final String providerId;

  @override
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm1',
      requestId: 'req_101',
      senderId: 'usr_001',
      senderName: 'Jhon Sheferaw',
      text: 'Hello sir,',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    ChatMessage(
      id: 'm2',
      requestId: 'req_101',
      senderId: 'prov_1',
      senderName: 'Solomon Getaw',
      text: 'Yes sir How can I help you?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    ChatMessage(
      id: 'm3',
      requestId: 'req_101',
      senderId: 'usr_001',
      senderName: 'Jhon Sheferaw',
      text: 'I need you to fix my TV Signal please',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ChatMessage(
      id: 'm4',
      requestId: 'req_101',
      senderId: 'prov_1',
      senderName: 'Solomon Getaw',
      text: 'Yes of course where are you?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    ChatMessage(
      id: 'm5',
      requestId: 'req_101',
      senderId: 'usr_001',
      senderName: 'Jhon Sheferaw',
      text: 'Bole, back of Skylight hotel',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      id: 'm6',
      requestId: 'req_101',
      senderId: 'prov_1',
      senderName: 'Solomon Getaw',
      text: 'Okay, Sure when am arrive I will call',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    ChatMessage(
      id: 'm7',
      requestId: 'req_101',
      senderId: 'usr_001',
      senderName: 'Jhon Sheferaw',
      text: 'Thank you!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          requestId: 'req_101',
          senderId: 'usr_001',
          senderName: 'Jhon Sheferaw',
          text: text,
          timestamp: DateTime.now(),
        ),
      );
    });

    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerSearchProvider);
    final provider = providers.firstWhere(
      (p) => p.id == widget.providerId,
      orElse: () => providers.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.ink),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.border,
              child: const Icon(Icons.person, size: 20, color: AppTheme.muted),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.ink,
                    ),
                  ),
                  const Text(
                    'online',
                    style: TextStyle(fontSize: 12, color: AppTheme.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: AppTheme.ink),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${provider.phoneNumber}...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: AppTheme.ink),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('MVP Voice/Video calls not supported per MVP Spec §12')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg.senderId == 'usr_001';

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFEAF7E8) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .03),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            msg.text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all, size: 14, color: AppTheme.blue),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Text Field Input Bar matching Visily design
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEFF2F6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sentiment_satisfied_alt, color: AppTheme.muted, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded, color: AppTheme.muted, size: 20),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_none_rounded, color: AppTheme.muted, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppTheme.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
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
