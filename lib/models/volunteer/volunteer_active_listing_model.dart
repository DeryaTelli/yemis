import 'package:intl/intl.dart';
import 'volunteer_listing.dart';

class VolunteerActiveListingModel {
  final int id;
  final int? addressId;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final int? createdByUserId;
  final String title;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime? pickupStartTime;
  final DateTime? pickupEndTime;
  final String? deliveryStatus;
  final DateTime? createdAt;

  VolunteerActiveListingModel({
    required this.id,
    this.addressId,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.createdByUserId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.isAvailable,
    this.pickupStartTime,
    this.pickupEndTime,
    this.deliveryStatus,
    this.createdAt,
  });

  factory VolunteerActiveListingModel.fromJson(Map<String, dynamic> json) {
    return VolunteerActiveListingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      addressId: json['address_id'] is int ? json['address_id'] : int.tryParse(json['address_id'].toString()),
      addressLine: json['address_line']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdByUserId: json['created_by_user_id'] is int ? json['created_by_user_id'] : int.tryParse(json['created_by_user_id'].toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      pickupStartTime: json['pickup_start_time'] != null ? DateTime.tryParse(json['pickup_start_time'].toString()) : null,
      pickupEndTime: json['pickup_end_time'] != null ? DateTime.tryParse(json['pickup_end_time'].toString()) : null,
      deliveryStatus: json['delivery_status']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  VolunteerListing toVolunteerListing() {
    String formattedTime = '';
    if (pickupStartTime != null && pickupEndTime != null) {
      final start = DateFormat('HH:mm').format(pickupStartTime!);
      final end = DateFormat('HH:mm').format(pickupEndTime!);
      formattedTime = '$start - $end';
    }

    return VolunteerListing(
      id: id.toString(),
      title: title,
      userName: 'Ben', // Aktif ilanlarım olduğu için
      location: addressLine ?? 'Konum Belirtilmedi',
      timeRange: formattedTime,
      imageUrl: imageUrl ?? '',
      rating: 5.0,
      section: VolunteerSection.nearYou,
      description: description,
      latitude: latitude,
      longitude: longitude,
      isNetworkImage: imageUrl != null && imageUrl!.startsWith('http'),
    );
  }
}
