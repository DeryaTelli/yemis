import 'package:flutter/material.dart';

import '../../utils/constants/api_constants.dart';

/// Uygulamadaki iki kullanıcı tipi.
///
/// - [food]     → Normal kullanıcı. Yemek satın alabilir, Gönüllü modülüne erişebilir.
/// - [business] → İşletme kullanıcısı. Yemek listeleyebilir, Gönüllü modülüne erişebilir.
enum UserType { food, business }

/// Kullanıcı modeli
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? imageUrl;
  final String? city;
  final String? district;
  final bool isVerified;
  final bool isVolunteer;
  final UserType userType;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phoneNumber,
    this.address,
    this.city,
    this.district,
    this.imageUrl,
    this.isVerified = false,
    this.isVolunteer = false,
  });

  bool get isBusiness => userType == UserType.business;
  bool get isFood => userType == UserType.food;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Rol tespiti için çoklu kontrol
    final dynamic rawRole =
        json['role'] ?? json['userType'] ?? json['user_type'];
    final bool rawIsBusiness = json['is_business'] ?? false;

    final roleStr = (rawRole?.toString().toLowerCase() ?? '');

    // Eğer role 'business' ise VEYA is_business true ise Business kabul et
    UserType detectedType = UserType.food;
    if (roleStr == 'business' || rawIsBusiness == true) {
      detectedType = UserType.business;
    }

    // Image URL işleme: Eğer relative path ise tam URL'e çevir
    String? rawImageUrl = json['image_url']?.toString() ?? json['imageUrl']?.toString();
    String? processedImageUrl;
    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http')) {
        processedImageUrl = rawImageUrl;
      } else {
        final cleanPath = rawImageUrl.startsWith('/') ? rawImageUrl : '/$rawImageUrl';
        processedImageUrl = '${ApiConstants.baseUrl}$cleanPath';
      }
    }

    debugPrint('--- [DEBUG] UserModel.fromJson ---');
    debugPrint('ID: ${json['id']}');
    debugPrint('Raw Role: $rawRole');
    debugPrint('Processed Image URL: $processedImageUrl');
    debugPrint('----------------------------------');

    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      imageUrl: processedImageUrl,
      isVerified: json['is_verified'] ?? false,
      isVolunteer: json['is_volunteer'] ?? false,
      userType: detectedType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address,
    'city': city,
    'district': district,
    'imageUrl': imageUrl,
    'isVerified': isVerified,
    'isVolunteer': isVolunteer,
    'userType': userType.name,
  };
}
