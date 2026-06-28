class ReviewModel {
  final String id;
  final String carId;
  final String userId;
  final String? userName;
  final double rating;
  final String? comment;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.carId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'].toString(),
      carId: json['car_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
