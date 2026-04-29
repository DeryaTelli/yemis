class AddressModel {
  final int id;
  final int userId;
  final String label;
  final String addressLine;
  final String? city;
  final String? district;
  final String? neighborhood;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final bool isActive;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine,
    this.city,
    this.district,
    this.neighborhood,
    required this.latitude,
    required this.longitude,
    this.isDefault = true,
    this.isActive = true,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      label: json['label'] ?? '',
      addressLine: json['address_line'] ?? '',
      city: json['city'] as String?,
      district: json['district'] as String?,
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isDefault: json['is_default'] ?? true,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'label': label,
      'address_line': addressLine,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'is_active': isActive,
    };
    if (city != null && city!.isNotEmpty) map['city'] = city;
    if (district != null && district!.isNotEmpty) map['district'] = district;
    if (neighborhood != null && neighborhood!.isNotEmpty) map['neighborhood'] = neighborhood;
    return map;
  }

  AddressModel copyWith({
    int? id,
    int? userId,
    String? label,
    String? addressLine,
    String? city,
    String? district,
    String? neighborhood,
    double? latitude,
    double? longitude,
    bool? isDefault,
    bool? isActive,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }
}
