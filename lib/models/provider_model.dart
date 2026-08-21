enum VerificationStatus { pending, approved, rejected, suspended }

class ProviderModel {
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String? profileImage;
  final String location;
  final String bio;
  final double rating;
  final int reviewCount;
  final int skillsCount;
  final int completedOrders;
  final int totalOrders;
  final List<String> services;
  final List<String> categoryIds;
  final bool isVerified;
  final VerificationStatus verificationStatus;
  final double distanceKm;
  final double latitude;
  final double longitude;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    required this.location,
    required this.bio,
    this.rating = 4.0,
    this.reviewCount = 1200,
    this.skillsCount = 6,
    this.completedOrders = 89,
    this.totalOrders = 94,
    required this.services,
    this.categoryIds = const [],
    this.isVerified = true,
    this.verificationStatus = VerificationStatus.approved,
    this.distanceKm = 1.5,
    this.latitude = 9.0192,
    this.longitude = 38.7525,
  });

  ProviderModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    String? location,
    String? bio,
    double? rating,
    int? reviewCount,
    int? skillsCount,
    int? completedOrders,
    int? totalOrders,
    List<String>? services,
    List<String>? categoryIds,
    bool? isVerified,
    VerificationStatus? verificationStatus,
    double? distanceKm,
    double? latitude,
    double? longitude,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      skillsCount: skillsCount ?? this.skillsCount,
      completedOrders: completedOrders ?? this.completedOrders,
      totalOrders: totalOrders ?? this.totalOrders,
      services: services ?? this.services,
      categoryIds: categoryIds ?? this.categoryIds,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'] as List<dynamic>? ?? [];
    final location = json['location'] as Map<String, dynamic>?;
    final trustScore = json['trust_score'];

    return ProviderModel(
      id: json['id'] as String,
      userId: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown provider',
      phoneNumber: json['phone_number'] as String? ?? '',
      location: (location?['city'] as String?) ??
          (location?['address'] as String?) ??
          (location?['region'] as String?) ??
          'Location not set',
      bio: json['bio'] as String? ?? '',
      rating: trustScore == null ? 0.0 : (trustScore as num).toDouble(),
      reviewCount: 0,
      skillsCount: categories.length,
      completedOrders: 0,
      totalOrders: 0,
      services: categories.map((c) => c['name'] as String).toList(),
      categoryIds: categories.map((c) => c['id'] as String).toList(),
      isVerified: json['verification_status'] == 'verified',
      verificationStatus: json['verification_status'] == 'verified' ? VerificationStatus.approved : VerificationStatus.pending,
      distanceKm: 0.0,
      latitude: location == null ? 9.0192 : (location['latitude'] as num).toDouble(),
      longitude: location == null ? 38.7525 : (location['longitude'] as num).toDouble(),
    );
  }
}
