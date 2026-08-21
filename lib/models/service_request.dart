enum RequestStatus {
  pending,
  accepted,
  inProgress,
  completed,
  rejected,
  cancelled,
}

extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending Request...';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.inProgress:
        return 'In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class ServiceRequest {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerImage;
  final String providerId;
  final String providerName;
  final String? providerImage;
  final String categoryId;
  final String serviceTitle;
  final String description;
  final String location;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime scheduledAt;
  final bool isUnlockedByProvider;
  final int unlockCreditCost;
  final String syncToken;
  final bool isSyncedOffline;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerImage,
    required this.providerId,
    required this.providerName,
    this.providerImage,
    required this.categoryId,
    required this.serviceTitle,
    required this.description,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.scheduledAt,
    this.isUnlockedByProvider = false,
    this.unlockCreditCost = 10,
    required this.syncToken,
    this.isSyncedOffline = true,
  });

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerImage,
    String? providerId,
    String? providerName,
    String? providerImage,
    String? categoryId,
    String? serviceTitle,
    String? description,
    String? location,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isUnlockedByProvider,
    int? unlockCreditCost,
    String? syncToken,
    bool? isSyncedOffline,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerImage: customerImage ?? this.customerImage,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerImage: providerImage ?? this.providerImage,
      categoryId: categoryId ?? this.categoryId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isUnlockedByProvider: isUnlockedByProvider ?? this.isUnlockedByProvider,
      unlockCreditCost: unlockCreditCost ?? this.unlockCreditCost,
      syncToken: syncToken ?? this.syncToken,
      isSyncedOffline: isSyncedOffline ?? this.isSyncedOffline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,
      'providerId': providerId,
      'providerName': providerName,
      'providerImage': providerImage,
      'categoryId': categoryId,
      'serviceTitle': serviceTitle,
      'description': description,
      'location': location,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt.toIso8601String(),
      'isUnlockedByProvider': isUnlockedByProvider ? 1 : 0,
      'unlockCreditCost': unlockCreditCost,
      'syncToken': syncToken,
      'isSyncedOffline': isSyncedOffline ? 1 : 0,
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerImage: json['customerImage'] as String?,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerImage: json['providerImage'] as String?,
      categoryId: json['categoryId'] as String,
      serviceTitle: json['serviceTitle'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      isUnlockedByProvider: (json['isUnlockedByProvider'] == 1 || json['isUnlockedByProvider'] == true),
      unlockCreditCost: json['unlockCreditCost'] as int? ?? 5,
      syncToken: json['syncToken'] as String? ?? json['id'] as String,
      isSyncedOffline: (json['isSyncedOffline'] == 1 || json['isSyncedOffline'] == true),
    );
  }

  factory ServiceRequest.fromApiJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final provider = json['provider'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;
    final created = DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now();
    return ServiceRequest(
      id: json['id'].toString(), customerId: json['customer_id']?.toString() ?? '',
      customerName: customer?['full_name']?.toString() ?? 'Customer', providerId: json['provider_id']?.toString() ?? '',
      providerName: provider?['user']?['full_name']?.toString() ?? 'Unassigned provider', categoryId: json['category_id']?.toString() ?? '',
      serviceTitle: category?['name']?.toString() ?? 'Service request', description: json['description']?.toString() ?? '', location: 'Addis Ababa',
      status: RequestStatus.values.firstWhere((s) => s.name == json['status'], orElse: () => RequestStatus.pending), createdAt: created, scheduledAt: created,
      syncToken: json['client_id']?.toString() ?? json['id'].toString(),
    );
  }
}
