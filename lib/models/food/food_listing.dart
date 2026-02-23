/// Bir yemek ilanını temsil eder.
class FoodListing {
  const FoodListing({
    required this.id,
    required this.title,
    required this.shopName,
    required this.location,
    required this.category,
    required this.timeRange,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.section,
    this.isFavorite = false,
    // ─── Detay alanları (opsiyonel) ───────────────────────
    this.description,
    this.ingredients,
    this.allergens,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String shopName;
  final String location;
  final String category;
  final String timeRange;
  final String imageUrl;
  final double price;
  final double rating;
  final FoodSection section;
  final bool isFavorite;

  // Detay ekranında kullanılır
  final String? description;
  final String? ingredients;
  final String? allergens;
  final double? latitude;
  final double? longitude;

  FoodListing copyWith({
    bool? isFavorite,
    String? description,
    String? ingredients,
    String? allergens,
    double? latitude,
    double? longitude,
  }) {
    return FoodListing(
      id: id,
      title: title,
      shopName: shopName,
      location: location,
      category: category,
      timeRange: timeRange,
      imageUrl: imageUrl,
      price: price,
      rating: rating,
      section: section,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// Hangi bölümde gösterileceğini belirtir.
enum FoodSection {
  surpriseBox,   // Sürpriz Kutu
  buyNow,        // Şimdi Al
  todayPopular,  // Bugün Popüler
}
