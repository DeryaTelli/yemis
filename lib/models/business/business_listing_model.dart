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
  final String? category;
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
    this.category,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory BusinessListingModel.fromJson(Map<String, dynamic> json) {
    return BusinessListingModel(
      id: json['bag_id'] != null 
          ? (json['bag_id'] is int ? json['bag_id'] : int.tryParse(json['bag_id'].toString()) ?? 0)
          : (json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0),
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      businessName: json['business_name']?.toString() ?? json['shop_name']?.toString() ?? json['business']?['name']?.toString(),
      ownerImageUrl: json['owner_image_url'] ?? json['business']?['image_url'],
      businessLogoUrl: json['business_logo_url']?.toString() ?? json['shop_logo_url']?.toString() ?? json['business']?['logo_url']?.toString(),
      title: json['title']?.toString() ?? json['bag_title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? json['content']?.toString(),
      addressId: json['address_id'] is int ? json['address_id'] : int.tryParse(json['address_id'].toString()),
      address: json['address']?.toString() ?? json['full_address']?.toString() ?? json['location_address']?.toString(),
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      pickupStartTime: json['pickup_start_time'] != null
          ? DateTime.tryParse(json['pickup_start_time'].toString())
          : (json['delivery_start_time'] != null ? DateTime.tryParse(json['delivery_start_time'].toString()) : null),
      pickupEndTime: json['pickup_end_time'] != null
          ? DateTime.tryParse(json['pickup_end_time'].toString())
          : (json['delivery_end_time'] != null ? DateTime.tryParse(json['delivery_end_time'].toString()) : null),
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 0,
      availableQuantity: (json['available_quantity'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString() ?? json['bag_image_url']?.toString() ?? json['image']?.toString(),
      allergens: json['allergens']?.toString(),
      category: json['category']?.toString(),
      latitude: json['latitude'] != null 
          ? (json['latitude'] as num).toDouble() 
          : (json['lat'] != null ? (json['lat'] as num).toDouble() : null),
      longitude: json['longitude'] != null 
          ? (json['longitude'] as num).toDouble() 
          : (json['lng'] != null ? (json['lng'] as num).toDouble() : null),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get isSold => availableQuantity == 0;
  
  bool get isExpired {
    if (pickupEndTime == null) return false;
    return DateTime.now().isAfter(pickupEndTime!);
  }

  bool get isActive => !isSold && !isExpired;

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
      'category': category,
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

    String shortLocation = '';
    if (address != null) {
      final parts = address!.split('/').map((e) => e.trim()).toList();
      if (parts.length >= 2) {
        shortLocation = '${parts[1]}, ${parts[0]}'; // "Merkez, Kastamonu"
      } else if (parts.isNotEmpty) {
        shortLocation = parts[0];
      }
    }

    return FoodListing(
      id: id.toString(),
      title: title,
      shopName: businessName ?? 'İşletme',
      location: shortLocation,
      category: category ?? 'Sürpriz Kutu',
      timeRange: formattedTime,
      imageUrl: imageUrl ?? '',
      price: discountedPrice,
      rating: 4.8,
      section: FoodSection.nearYou,
      isNetworkImage: imageUrl != null && imageUrl!.startsWith('http'),
      shopLogoUrl: businessLogoUrl,
      isSoldOut: isSold,
      description: description,
      allergens: allergens,
      latitude: latitude,
      longitude: longitude,
      deliveryStartTime: pickupStartTime,
      deliveryEndTime: pickupEndTime,
      originalPrice: originalPrice,
      fullAddress: address,
    );
  }
}
