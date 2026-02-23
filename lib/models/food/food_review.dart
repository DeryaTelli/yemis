/// Bir yemek ilanına yapılan yorumu temsil eder.
class FoodReview {
  const FoodReview({
    required this.id,
    required this.reviewerName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
    this.photoUrls = const [],
  });

  final String id;
  final String reviewerName;
  final String avatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> photoUrls;
}
