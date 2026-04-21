/// Yeni yorum oluşturma isteği.
class CreateReviewRequest {
  const CreateReviewRequest({
    required this.storeId,
    required this.rating,
    required this.comment,
  });

  final int storeId;
  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
      };
}

/// Mevcut yorumu güncelleme isteği.
class UpdateReviewRequest {
  const UpdateReviewRequest({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  final int reviewId;
  final int rating;
  final String comment;

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
      };
}
