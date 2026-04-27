class AddressModel {
  final int id;
  final int userId;
  final String label;
  final String addressLine;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final bool isActive;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine,
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
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isDefault: json['is_default'] ?? true,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'address_line': addressLine,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault,
    'is_active': isActive,
  };
}
