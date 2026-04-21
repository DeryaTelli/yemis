/// Food ve Volunteer modülleri için ortak yorum modeli.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.storeId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
    this.isOwn = false,
  });

  final int id;
  final int storeId;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime date;

  /// Bu yorum oturum açmış kullanıcıya mı ait?
  final bool isOwn;

  factory ReviewModel.fromJson(Map<String, dynamic> json, {bool isOwn = false}) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      reviewerName: (json['reviewer_name'] ?? json['user_name'] ?? 'Kullanıcı').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: (json['comment'] ?? '').toString(),
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isOwn: isOwn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_id': storeId,
        'reviewer_name': reviewerName,
        'rating': rating,
        'comment': comment,
        'created_at': date.toIso8601String(),
      };

  ReviewModel copyWith({
    int? id,
    int? storeId,
    String? reviewerName,
    double? rating,
    String? comment,
    DateTime? date,
    bool? isOwn,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      reviewerName: reviewerName ?? this.reviewerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      isOwn: isOwn ?? this.isOwn,
    );
  }
}
