/// Gönüllü ilanının hangi bölümde gösterileceğini belirtir.
enum VolunteerSection {
  nearYou,       // Sana Yakın Yerler
  todayPopular,  // Bugün Popüler Olanlar
}

/// Bir gönüllü ilanını temsil eder.
class VolunteerListing {
  const VolunteerListing({
    required this.id,
    required this.title,
    required this.userName,
    required this.location,
    required this.timeRange,
    required this.imageUrl,
    required this.rating,
    required this.section,
    this.latitude,
    this.longitude,
    // ── Detay Alanları (Opsiyonel) ──
    this.description,
    this.ingredients,
    this.packageInfo,
    this.shelterLatitude,
    this.shelterLongitude,
  });

  final String id;
  final String title;
  final String userName;
  final String location;
  final String timeRange;
  final String imageUrl;
  final double rating;
  final VolunteerSection section;

  // Harita için opsiyonel koordinatlar
  final double? latitude;
  final double? longitude;

  // Detay ekranı için opsiyonel alanlar
  final String? description;
  final String? ingredients;
  final String? packageInfo;
  final double? shelterLatitude;
  final double? shelterLongitude;

  VolunteerListing copyWith({
    double? latitude,
    double? longitude,
  }) {
    return VolunteerListing(
      id: id,
      title: title,
      userName: userName,
      location: location,
      timeRange: timeRange,
      imageUrl: imageUrl,
      rating: rating,
      section: section,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      packageInfo: packageInfo ?? this.packageInfo,
      shelterLatitude: shelterLatitude ?? this.shelterLatitude,
      shelterLongitude: shelterLongitude ?? this.shelterLongitude,
    );
  }
}
