enum NotificationType {
  requestStatusChanged,
  requestAccepted,
  requestCompleted,
  requestCancelled,
  newRequest,
  chatMessage,
  verificationUpdate,
  walletCredit,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? targetId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.targetId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? targetId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      targetId: targetId ?? this.targetId,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
      type: _parseType(json['type'] as String),
      isRead: json['is_read'] as bool? ?? false,
      targetId: json['reference_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': timestamp.toIso8601String(),
      'type': type.name,
      'is_read': isRead,
      'reference_id': targetId,
    };
  }

  static NotificationType _parseType(String value) {
    return switch (value) {
      'request_accepted' => NotificationType.requestAccepted,
      'request_completed' => NotificationType.requestCompleted,
      'request_cancelled' => NotificationType.requestCancelled,
      'new_request' => NotificationType.newRequest,
      'chat_message' => NotificationType.chatMessage,
      'wallet_credit' => NotificationType.walletCredit,
      'verification_update' => NotificationType.verificationUpdate,
      _ => NotificationType.requestStatusChanged,
    };
  }
}
