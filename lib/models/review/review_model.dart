/// Food ve Volunteer modülleri için ortak yorum modeli.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.storeId,
    this.orderId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
    this.imageUrl1,
    this.imageUrl2,
    this.imageUrl3,
    this.isOwn = false,
  });

  final int id;
  final int storeId;
  final int? orderId;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime date;
  final String? imageUrl1;
  final String? imageUrl2;
  final String? imageUrl3;
  List<String> get imageUrls => [imageUrl1, imageUrl2, imageUrl3]
      .whereType<String>()
      .where((url) => url.trim().isNotEmpty)
      .toList();

  /// Bu yorum oturum açmış kullanıcıya mı ait?
  final bool isOwn;

  factory ReviewModel.fromJson(Map<String, dynamic> json, {bool isOwn = false}) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      orderId: _toInt(
        json['order_id'] ??
            (json['order'] is Map ? (json['order'] as Map)['id'] : null),
      ),
      reviewerName: (json['reviewer_name'] ?? json['user_name'] ?? 'Kullanıcı').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: (json['comment'] ?? '').toString(),
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imageUrl1: _toUrl(json['image_url_1']),
      imageUrl2: _toUrl(json['image_url_2']),
      imageUrl3: _toUrl(json['image_url_3']),
      isOwn: isOwn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_id': storeId,
        if (orderId != null) 'order_id': orderId,
        'reviewer_name': reviewerName,
        'rating': rating,
        'comment': comment,
        'created_at': date.toIso8601String(),
        if (imageUrl1 != null) 'image_url_1': imageUrl1,
        if (imageUrl2 != null) 'image_url_2': imageUrl2,
        if (imageUrl3 != null) 'image_url_3': imageUrl3,
      };

  ReviewModel copyWith({
    int? id,
    int? storeId,
    int? orderId,
    String? reviewerName,
    double? rating,
    String? comment,
    DateTime? date,
    String? imageUrl1,
    String? imageUrl2,
    String? imageUrl3,
    bool? isOwn,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      orderId: orderId ?? this.orderId,
      reviewerName: reviewerName ?? this.reviewerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      imageUrl1: imageUrl1 ?? this.imageUrl1,
      imageUrl2: imageUrl2 ?? this.imageUrl2,
      imageUrl3: imageUrl3 ?? this.imageUrl3,
      isOwn: isOwn ?? this.isOwn,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _toUrl(dynamic value) {
    final url = value?.toString().trim();
    return url == null || url.isEmpty ? null : url;
  }
}
