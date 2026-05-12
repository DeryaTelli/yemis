class ShelterModel {
  final int id;
  final String name;
  final String city;
  final String district;
  final String address;
  final String? phoneNumber;
  final double latitude;
  final double longitude;
  final int capacity;
  final bool isActive;
  final double distanceKm;

  ShelterModel({
    required this.id,
    required this.name,
    required this.city,
    required this.district,
    required this.address,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.isActive,
    required this.distanceKm,
  });

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      capacity: json['capacity'] ?? 0,
      isActive: json['is_active'] ?? true,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
