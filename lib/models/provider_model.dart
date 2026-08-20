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
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
