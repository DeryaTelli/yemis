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
    this.ownerImageUrl,
    this.isFavorite = false,
    this.isNetworkImage = false,
    this.isSoldOut = false,
    // ─── Detay alanları (opsiyonel) ───────────────────────
    this.description,
    this.ingredients,
    this.allergens,
    this.latitude,
    this.longitude,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.originalPrice,
    this.fullAddress,
    this.totalQuantity,
    this.availableQuantity,
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
  final String? ownerImageUrl;
  final bool isFavorite;
  final bool isNetworkImage;
  final bool isSoldOut;

  // Detay ekranında kullanılır
  final String? description;
  final String? ingredients;
  final String? allergens;
  final double? latitude;
  final double? longitude;
  final DateTime? deliveryStartTime;
  final DateTime? deliveryEndTime;
  final double? originalPrice;
  final String? fullAddress;
  final int? totalQuantity;
  final int? availableQuantity;

  FoodListing copyWith({
    String? id,
    String? title,
    String? shopName,
    String? location,
    String? category,
    String? timeRange,
    String? imageUrl,
    double? price,
    double? rating,
    FoodSection? section,
    String? shopLogoUrl,
    String? ownerImageUrl,
    bool? isFavorite,
    bool? isNetworkImage,
    bool? isSoldOut,
    String? description,
    String? ingredients,
    String? allergens,
    double? latitude,
    double? longitude,
    DateTime? deliveryStartTime,
    DateTime? deliveryEndTime,
    double? originalPrice,
    String? fullAddress,
    int? totalQuantity,
    int? availableQuantity,
  }) {
    return FoodListing(
      id: id ?? this.id,
      title: title ?? this.title,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      category: category ?? this.category,
      timeRange: timeRange ?? this.timeRange,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      section: section ?? this.section,
      shopLogoUrl: shopLogoUrl ?? this.shopLogoUrl,
      ownerImageUrl: ownerImageUrl ?? this.ownerImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryStartTime: deliveryStartTime ?? this.deliveryStartTime,
      deliveryEndTime: deliveryEndTime ?? this.deliveryEndTime,
      originalPrice: originalPrice ?? this.originalPrice,
      fullAddress: fullAddress ?? this.fullAddress,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }
}

/// Hangi bölümde gösterileceğini belirtir.
enum FoodSection {
  nearYou, // Sana Yakın Yerler
  buyNow, // Şimdi Al
  todayPopular, // Bugün Popüler
  todayPopularAll, // Bugün Popüler (Tümü)
}
