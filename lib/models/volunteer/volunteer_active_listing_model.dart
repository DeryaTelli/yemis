import 'package:intl/intl.dart';
import 'package:yemis/utils/constants/api_constants.dart';
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

  final String? posterName;
  final String? posterImageUrl;

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
    this.posterName,
    this.posterImageUrl,
  });

  factory VolunteerActiveListingModel.fromJson(Map<String, dynamic> json) {
    // Kullanıcı bilgisini çek (İlanı paylaşan kişi)
    // API'den gelen gerçek keyler: creator_name ve owner_image_url
    String? pName = json['creator_name']?.toString();
    String? pImage = json['owner_image_url']?.toString();

    if (json['user'] != null && json['user'] is Map) {
      final user = json['user'] as Map<String, dynamic>;
      pName ??= user['name']?.toString() ?? user['creator_name']?.toString();
      pImage ??=
          user['image_url']?.toString() ??
          user['imageUrl']?.toString() ??
          user['owner_image']?.toString() ??
          user['owner_image_url']?.toString();
    }

    pName ??= json['user_name']?.toString() ?? json['name']?.toString();
    pImage ??=
        json['user_image']?.toString() ??
        json['owner_image']?.toString() ??
        json['ownerImage']?.toString();

    // Image URL işleme (Eğer relative path ise tam URL'e çevir)
    if (pImage != null && pImage.isNotEmpty && !pImage.startsWith('http')) {
      final cleanPath = pImage.startsWith('/') ? pImage : '/$pImage';
      pImage = '${ApiConstants.baseUrl}$cleanPath';
    }

    String? listingImg = json['image_url']?.toString();
    if (listingImg != null &&
        listingImg.isNotEmpty &&
        !listingImg.startsWith('http')) {
      final cleanPath = listingImg.startsWith('/')
          ? listingImg
          : '/$listingImg';
      listingImg = '${ApiConstants.baseUrl}$cleanPath';
    }

    return VolunteerActiveListingModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      addressId: json['address_id'] is int
          ? json['address_id']
          : int.tryParse(json['address_id'].toString()),
      addressLine: (json['address_line'] ?? json['location'])?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdByUserId: json['created_by_user_id'] is int
          ? json['created_by_user_id']
          : int.tryParse(json['created_by_user_id'].toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: listingImg,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      pickupStartTime: (json['pickup_start_time'] ?? json['scheduled_at']) != null
          ? DateTime.tryParse((json['pickup_start_time'] ?? json['scheduled_at']).toString())
          : null,
      pickupEndTime: json['pickup_end_time'] != null
          ? DateTime.tryParse(json['pickup_end_time'].toString())
          : null,
      deliveryStatus: json['delivery_status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      posterName: pName,
      posterImageUrl: pImage,
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
      userName: posterName ?? 'Bilinmiyor',
      userLogoUrl: posterImageUrl,
      location: addressLine ?? 'Konum Belirtilmedi',
      timeRange: formattedTime,
      imageUrl: imageUrl ?? '',
      rating: 4.8,
      section: VolunteerSection.nearYou,
      description: description,
      latitude: latitude,
      longitude: longitude,
      isNetworkImage: imageUrl != null && imageUrl!.startsWith('http'),
    );
  }
}
