class ReviewModel {
  final String id;
  final String requestId;
  final String customerId;
  final String customerName;
  final String providerId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
