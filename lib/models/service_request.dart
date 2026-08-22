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
  final String? providerPhoneNumber;
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
    this.providerPhoneNumber,
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
    String? providerPhoneNumber,
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
      'providerPhoneNumber': providerPhoneNumber,
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
      providerPhoneNumber: json['providerPhoneNumber'] as String?,
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
      unlockCreditCost: json['unlockCreditCost'] as int? ?? 10,
      syncToken: json['syncToken'] as String? ?? json['id'] as String,
      isSyncedOffline: (json['isSyncedOffline'] == 1 || json['isSyncedOffline'] == true),
    );
  }

  // Maps the backend's snake_case request status onto the local enum.
  static RequestStatus _statusFromApi(String? status) {
    switch (status) {
      case 'in_progress':
        return RequestStatus.inProgress;
      case 'failed':
        return RequestStatus.rejected;
      case 'accepted':
        return RequestStatus.accepted;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'pending':
      default:
        return RequestStatus.pending;
    }
  }

  // Builds a ServiceRequest from a `GET/POST /api/requests*` backend response.
  factory ServiceRequest.fromApiJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final provider = json['provider'] as Map<String, dynamic>?;
    final providerUser = provider?['user'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final createdAt = DateTime.parse(json['created_at'] as String);
    final status = _statusFromApi(json['status'] as String?);

    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      customerName: customer?['full_name'] as String? ?? 'Customer',
      providerId: json['provider_id'] as String? ?? '',
      providerName: providerUser?['full_name'] as String? ?? 'Unassigned',
      providerPhoneNumber: providerUser?['phone_number'] as String? ?? '',
      categoryId: json['category_id'] as String,
      serviceTitle: category?['name'] as String? ?? 'Service Request',
      description: json['description'] as String? ?? '',
      location: (latitude != null && longitude != null)
          ? 'Lat: $latitude, Lng: $longitude'
          : 'Location not shared',
      status: status,
      createdAt: createdAt,
      scheduledAt: createdAt,
      // A pending request's contact details are hidden until a provider
      // accepts it (spending credit), which is what "unlocks" the lead.
      isUnlockedByProvider: status != RequestStatus.pending,
      unlockCreditCost: 10,
      syncToken: json['id'] as String,
      isSyncedOffline: true,
    );
  }
}
