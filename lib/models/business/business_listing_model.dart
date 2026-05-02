import 'package:intl/intl.dart';
import '../food/food_listing.dart';

class BusinessListingModel {
  final int id;
  final int userId;
  final String? businessName;
  final String? ownerImageUrl;
  final String? businessLogoUrl;
  final String title;
  final String? description;
  final int? addressId;
  final String? address;
  final double originalPrice;
  final double discountedPrice;
  final DateTime? pickupStartTime;
  final DateTime? pickupEndTime;
  final int totalQuantity;
  final int availableQuantity;
  final String? imageUrl;
  final String? allergens;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  BusinessListingModel({
    required this.id,
    required this.userId,
    this.businessName,
    this.ownerImageUrl,
    this.businessLogoUrl,
    required this.title,
    this.description,
    this.addressId,
    this.address,
    required this.originalPrice,
    required this.discountedPrice,
    this.pickupStartTime,
    this.pickupEndTime,
    required this.totalQuantity,
    required this.availableQuantity,
    this.imageUrl,
    this.allergens,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory BusinessListingModel.fromJson(Map<String, dynamic> json) {
    return BusinessListingModel(
      id: json['id'],
      userId: json['user_id'],
      businessName: json['business_name'],
      ownerImageUrl: json['owner_image_url'],
      businessLogoUrl: json['business_logo_url'],
      title: json['title'] ?? '',
      description: json['description'],
      addressId: json['address_id'],
      address: json['address'],
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble() ?? 0.0,
      pickupStartTime: json['pickup_start_time'] != null
          ? DateTime.parse(json['pickup_start_time'])
          : null,
      pickupEndTime: json['pickup_end_time'] != null
          ? DateTime.parse(json['pickup_end_time'])
          : null,
      totalQuantity: json['total_quantity'] ?? 0,
      availableQuantity: json['available_quantity'] ?? 0,
      imageUrl: json['image_url'],
      allergens: json['allergens'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'address_id': addressId,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'pickup_start_time': pickupStartTime?.toIso8601String(),
      'pickup_end_time': pickupEndTime?.toIso8601String(),
      'total_quantity': totalQuantity,
      'available_quantity': availableQuantity,
      'image_url': imageUrl,
      'allergens': allergens,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  FoodListing toFoodListing() {
    String formattedTime = '';
    if (pickupStartTime != null && pickupEndTime != null) {
      final start = DateFormat('HH:mm').format(pickupStartTime!);
      final end = DateFormat('HH:mm').format(pickupEndTime!);
      formattedTime = '$start - $end';
    } else {
      formattedTime = 'Belirtilmedi';
    }

    return FoodListing(
      id: id.toString(),
      title: title,
      shopName: businessName ?? 'İşletme',
      location: address?.split('/').first.trim() ?? '',
      category: 'Sürpriz Kutu',
      timeRange: formattedTime,
      imageUrl: imageUrl ?? '',
      price: discountedPrice,
      rating: 4.8,
      section: FoodSection.surpriseBox,
      isNetworkImage: imageUrl != null && imageUrl!.startsWith('http'),
      shopLogoUrl: businessLogoUrl,
      description: description,
      allergens: allergens,
      latitude: latitude,
      longitude: longitude,
      deliveryStartTime: pickupStartTime,
      deliveryEndTime: pickupEndTime,
      originalPrice: originalPrice,
    );
  }
}
