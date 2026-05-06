/// Gönüllü ilanının hangi bölümde gösterileceğini belirtir.
enum VolunteerSection {
  nearYou, // Sana Yakın Yerler
  todayPopular, // Bugün Popüler Olanlar
}

/// Bir gönüllü ilanını temsil eder.
class VolunteerListing {
  const VolunteerListing({
    required this.id,
    required this.title,
    required this.userName,
    this.userLogoUrl,
    required this.location,
    required this.timeRange,
    required this.imageUrl,
    required this.rating,
    required this.section,
    this.latitude,
    this.longitude,
    this.isNetworkImage = false,
    this.shopLogoUrl,
    // ── Detay Alanları (Opsiyonel) ──
    this.description,
    this.ingredients,
    this.packageInfo,
    this.shelterLatitude,
    this.shelterLongitude,
    this.shelterName,
    this.shelterAddress,
  });

  final String id;
  final String title;
  final String userName;
  final String? userLogoUrl;
  final String location;
  final String timeRange;
  final String imageUrl;
  final double rating;
  final VolunteerSection section;

  // Harita için opsiyonel koordinatlar
  final double? latitude;
  final double? longitude;
  final bool isNetworkImage;
  final String? shopLogoUrl;

  // Detay ekranı için opsiyonel alanlar
  final String? description;
  final String? ingredients;
  final String? packageInfo;
  final double? shelterLatitude;
  final double? shelterLongitude;
  final String? shelterName;
  final String? shelterAddress;

  VolunteerListing copyWith({
    String? title,
    String? userName,
    String? userLogoUrl,
    String? location,
    String? timeRange,
    String? imageUrl,
    double? rating,
    VolunteerSection? section,
    double? latitude,
    double? longitude,
    bool? isNetworkImage,
    String? shopLogoUrl,
    String? description,
    String? ingredients,
    String? packageInfo,
    double? shelterLatitude,
    double? shelterLongitude,
    String? shelterName,
    String? shelterAddress,
  }) {
    return VolunteerListing(
      id: id,
      title: title ?? this.title,
      userName: userName ?? this.userName,
      userLogoUrl: userLogoUrl ?? this.userLogoUrl,
      location: location ?? this.location,
      timeRange: timeRange ?? this.timeRange,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      section: section ?? this.section,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
      shopLogoUrl: shopLogoUrl ?? this.shopLogoUrl,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      packageInfo: packageInfo ?? this.packageInfo,
      shelterLatitude: shelterLatitude ?? this.shelterLatitude,
      shelterLongitude: shelterLongitude ?? this.shelterLongitude,
      shelterName: shelterName ?? this.shelterName,
      shelterAddress: shelterAddress ?? this.shelterAddress,
    );
  }
}
