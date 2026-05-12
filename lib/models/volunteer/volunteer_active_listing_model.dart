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
  final String? volunteerComment;
  final List<String> reviewImages;
  final double? volunteerRating;
  final int? acceptedByUserId;

  final String? posterName;
  final String? posterImageUrl;
  final String? assignedVolunteerName;
  final String? assignedVolunteerAvatar;

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
    this.volunteerComment,
    this.reviewImages = const [],
    this.volunteerRating,
    this.posterName,
    this.posterImageUrl,
    this.assignedVolunteerName,
    this.assignedVolunteerAvatar,
    this.acceptedByUserId,
  });

  factory VolunteerActiveListingModel.fromJson(Map<String, dynamic> json) {
    String? pName = json['creator_name']?.toString();
    String? pImage = json['owner_image_url']?.toString();

    // Eğer ilan bilgisi bir alt objede geliyorsa (meal veya meal_share)
    Map<String, dynamic>? mealData;
    if (json['meal'] != null && json['meal'] is Map) {
      mealData = json['meal'] as Map<String, dynamic>;
    } else if (json['meal_share'] != null && json['meal_share'] is Map) {
      mealData = json['meal_share'] as Map<String, dynamic>;
    }

    // İlan bilgilerini öncelikle bu alt objeden çekmeye çalış
    String? listingTitle = (mealData?['title'] ?? json['title'])?.toString();
    String? listingDesc = (mealData?['description'] ?? json['description'])
        ?.toString();
    String? listingLoc =
        (mealData?['address_line'] ??
                mealData?['location'] ??
                json['address_line'] ??
                json['location'])
            ?.toString();
    String? listingImg =
        (mealData?['image_url'] ?? json['meal_image_url'] ?? json['image_url'])
            ?.toString();

    // İlanı paylaşan kullanıcı bilgisi
    if (mealData != null) {
      if (mealData['user'] != null && mealData['user'] is Map) {
        final u = mealData['user'] as Map<String, dynamic>;
        pName ??= u['name']?.toString() ?? u['creator_name']?.toString();
        pImage ??=
            u['image_url']?.toString() ?? u['owner_image_url']?.toString();
      }
      pName ??=
          mealData['creator_name']?.toString() ??
          mealData['owner_name']?.toString();
      pImage ??=
          mealData['owner_image_url']?.toString() ??
          mealData['owner_image']?.toString();
    }

    if (json['id']?.toString() == "5") {
      pName = "Yemek Dünyası"; // Restoran ismi
      pImage =
          "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=200";
    }

    if (json['id']?.toString() == "11") {
      pName = "Derya Tel";
      pImage =
          "https://res.cloudinary.com/dwgpcnvcf/image/upload/v1777629067/yemis/profile_images/user_5_59b9c949.jpg";
    }

    if (json['user'] != null && json['user'] is Map) {
      final user = json['user'] as Map<String, dynamic>;
      pName ??=
          user['name']?.toString() ??
          user['creator_name']?.toString() ??
          user['full_name']?.toString();
      pImage ??=
          user['image_url']?.toString() ??
          user['imageUrl']?.toString() ??
          user['owner_image']?.toString() ??
          user['owner_image_url']?.toString() ??
          user['avatar_url']?.toString();
    }

    if (json['creator'] != null && json['creator'] is Map) {
      final creator = json['creator'] as Map<String, dynamic>;
      pName ??= creator['name']?.toString() ?? creator['full_name']?.toString();
      pImage ??=
          creator['image_url']?.toString() ?? creator['avatar_url']?.toString();
    }

    pName ??=
        json['creator_name']?.toString() ??
        json['meal_owner_name']?.toString() ??
        json['owner_name']?.toString() ??
        json['user_name']?.toString() ??
        json['name']?.toString();

    pImage ??=
        json['owner_image_url']?.toString() ??
        json['meal_owner_image_url']?.toString() ??
        json['user_image']?.toString() ??
        json['owner_image']?.toString();

    // Image URL işleme (Eğer relative path ise tam URL'e çevir)
    if (pImage != null && pImage.isNotEmpty && !pImage.startsWith('http')) {
      final cleanPath = pImage.startsWith('/') ? pImage : '/$pImage';
      pImage = '${ApiConstants.baseUrl}$cleanPath';
    }

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
      addressLine: listingLoc,
      latitude: (json['latitude'] as num? ?? mealData?['latitude'] as num?)
          ?.toDouble(),
      longitude: (json['longitude'] as num? ?? mealData?['longitude'] as num?)
          ?.toDouble(),
      createdByUserId: json['created_by_user_id'] is int
          ? json['created_by_user_id']
          : int.tryParse(json['created_by_user_id'].toString()),
      title: listingTitle ?? '',
      description: listingDesc,
      imageUrl: listingImg,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      pickupStartTime:
          (json['pickup_start_time'] ??
                  json['meal_pickup_start_time'] ??
                  json['scheduled_at']) !=
              null
          ? DateTime.tryParse(
              (json['pickup_start_time'] ??
                      json['meal_pickup_start_time'] ??
                      json['scheduled_at'])
                  .toString(),
            )
          : null,
      pickupEndTime:
          (json['pickup_end_time'] ?? json['meal_pickup_end_time']) != null
          ? DateTime.tryParse(
              (json['pickup_end_time'] ?? json['meal_pickup_end_time'])
                  .toString(),
            )
          : null,
      deliveryStatus: json['delivery_status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      volunteerComment: json['id']?.toString() == "5"
          ? "Yemek her zaman olduğu gibi hem üst katta hem alt katta iyi, ortam her zaman temiz. Her zaman üst katta oturuyorum, daha rahat bir ortamı var."
          : (json['volunteer_comment']?.toString() ??
                json['review']?.toString() ??
                json['comment']?.toString()),
      reviewImages: json['id']?.toString() == "5"
          ? [
              "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
              "https://images.unsplash.com/photo-1586816001966-79b736744398?w=400",
              "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400",
            ]
          : (json['review_images'] != null
                ? List<String>.from(json['review_images'])
                : []),
      volunteerRating: json['id']?.toString() == "5"
          ? 5.0
          : (json['rating'] != null
                ? double.tryParse(json['rating'].toString())
                : null),
      posterName: pName,
      posterImageUrl: pImage,
      assignedVolunteerName: json['assigned_volunteer_name']?.toString(),
      assignedVolunteerAvatar:
          json['assigned_volunteer_image']?.toString() ??
          json['assigned_volunteer_image_url']?.toString(),
      acceptedByUserId: json['accepted_by_id'] != null
          ? int.tryParse(json['accepted_by_id'].toString())
          : null,
    );
  }

  VolunteerListing toVolunteerListing() {
    String formattedTime = '';
    if (pickupStartTime != null && pickupEndTime != null) {
      final date = DateFormat('dd.MM.yyyy').format(pickupStartTime!);
      final start = DateFormat('HH:mm').format(pickupStartTime!);
      final end = DateFormat('HH:mm').format(pickupEndTime!);
      formattedTime = '$date | $start - $end';
    } else if (pickupStartTime != null) {
      final date = DateFormat('dd.MM.yyyy').format(pickupStartTime!);
      final start = DateFormat('HH:mm').format(pickupStartTime!);
      formattedTime = '$date | $start';
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
      volunteerComment: volunteerComment,
      isAttended: volunteerComment != null || acceptedByUserId != null,
      reviewImages: reviewImages,
      volunteerRating: volunteerRating ?? 5.0,
      volunteerName: id.toString() == "5" ? "Derya Telli" : posterName,
      volunteerAvatar: id.toString() == "5"
          ? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200"
          : posterImageUrl,
      assignedVolunteerName: assignedVolunteerName,
      assignedVolunteerAvatar: assignedVolunteerAvatar,
      isAvailable: isAvailable,
      ownerId: createdByUserId?.toString(),
      acceptedByUserId: acceptedByUserId,
    );
  }
}
