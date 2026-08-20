class ChatMessage {
  final String id;
  final String requestId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = true,
  });
}

class ChatConversation {
  final String requestId;
  final String providerId;
  final String providerName;
  final String? providerAvatar;
  final String customerId;
  final String customerName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatConversation({
    required this.requestId,
    required this.providerId,
    required this.providerName,
    this.providerAvatar,
    required this.customerId,
    required this.customerName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = true,
  });
}
