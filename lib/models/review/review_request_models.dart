/// Yeni yorum oluşturma isteği.
class CreateReviewRequest {
  const CreateReviewRequest({
    required this.orderId,
    required this.rating,
    required this.comment,
    this.imageUrl1,
    this.imageUrl2,
    this.imageUrl3,
  });

  final int orderId;
  final int rating;
  final String comment;
  final String? imageUrl1;
  final String? imageUrl2;
  final String? imageUrl3;

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
        if (imageUrl1 != null) 'image_url_1': imageUrl1,
        if (imageUrl2 != null) 'image_url_2': imageUrl2,
        if (imageUrl3 != null) 'image_url_3': imageUrl3,
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
