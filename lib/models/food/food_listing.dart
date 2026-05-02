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
    this.shopLogoUrl,
    this.isFavorite = false,
    this.isNetworkImage = false,
    // ─── Detay alanları (opsiyonel) ───────────────────────
    this.description,
    this.ingredients,
    this.allergens,
    this.latitude,
    this.longitude,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.originalPrice,
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
  final String? shopLogoUrl;
  final bool isFavorite;
  final bool isNetworkImage;

  // Detay ekranında kullanılır
  final String? description;
  final String? ingredients;
  final String? allergens;
  final double? latitude;
  final double? longitude;
  final DateTime? deliveryStartTime;
  final DateTime? deliveryEndTime;
  final double? originalPrice;

  FoodListing copyWith({
    bool? isFavorite,
    bool? isNetworkImage,
    String? description,
    String? ingredients,
    String? allergens,
    double? latitude,
    double? longitude,
    DateTime? deliveryStartTime,
    DateTime? deliveryEndTime,
    double? originalPrice,
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
      shopLogoUrl: shopLogoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryStartTime: deliveryStartTime ?? this.deliveryStartTime,
      deliveryEndTime: deliveryEndTime ?? this.deliveryEndTime,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }
}

/// Hangi bölümde gösterileceğini belirtir.
enum FoodSection {
  surpriseBox, // Sürpriz Kutu
  buyNow, // Şimdi Al
  todayPopular, // Bugün Popüler
}
