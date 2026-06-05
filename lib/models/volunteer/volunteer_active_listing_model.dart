import 'package:intl/intl.dart';
import 'package:yemis/utils/constants/api_constants.dart';
import 'volunteer_listing.dart';

class VolunteerActiveListingModel {
  final int id;
  final int? taskId;
  final int? mealId;
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
  final String? reviewCreatedAt;
  final List<String> reviewImages;
  final double? volunteerRating;
  final int? acceptedByUserId;

  final String? posterName;
  final String? posterImageUrl;
  final String? assignedVolunteerName;
  final String? assignedVolunteerAvatar;
  final VolunteerTaskProgress? ownerProgress;
  final VolunteerTaskProgress? volunteerProgress;

  VolunteerActiveListingModel({
    required this.id,
    this.taskId,
    this.mealId,
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
    this.reviewCreatedAt,
    this.reviewImages = const [],
    this.volunteerRating,
    this.posterName,
    this.posterImageUrl,
    this.assignedVolunteerName,
    this.assignedVolunteerAvatar,
    this.acceptedByUserId,
    this.ownerProgress,
    this.volunteerProgress,
  });

  factory VolunteerActiveListingModel.fromJson(Map<String, dynamic> json) {
    String? pName = json['creator_name']?.toString();
    String? pImage = json['owner_image_url']?.toString();
    String? assignedName = json['assigned_volunteer_name']?.toString();
    String? assignedAvatar =
        json['assigned_volunteer_image']?.toString() ??
        json['assigned_volunteer_image_url']?.toString();
    String? volunteerComment =
        json['volunteer_comment']?.toString() ??
        (json['review'] is Map ? null : json['review']?.toString()) ??
        json['comment']?.toString();

    // Eğer ilan bilgisi bir alt objede geliyorsa (meal veya meal_share)
    Map<String, dynamic>? mealData;
    if (json['meal'] != null && json['meal'] is Map) {
      mealData = json['meal'] as Map<String, dynamic>;
    } else if (json['meal_share'] != null && json['meal_share'] is Map) {
      mealData = json['meal_share'] as Map<String, dynamic>;
    }

    final volunteerData = _firstMap(json, const [
      'volunteer',
      'assigned_volunteer',
      'accepted_by',
      'accepted_user',
      'user',
    ]);
    if (volunteerData != null &&
        (json.containsKey('meal') ||
            json.containsKey('meal_share') ||
            json.containsKey('task_id') ||
            json.containsKey('volunteer_task_id'))) {
      assignedName ??=
          volunteerData['name']?.toString() ??
          volunteerData['full_name']?.toString() ??
          volunteerData['username']?.toString();
      assignedAvatar ??=
          volunteerData['image_url']?.toString() ??
          volunteerData['imageUrl']?.toString() ??
          volunteerData['avatar_url']?.toString() ??
          volunteerData['profile_image']?.toString();
    }

    final reviewData = json['volunteer_review'] is Map
        ? Map<String, dynamic>.from(json['volunteer_review'] as Map)
        : (json['review'] is Map
              ? Map<String, dynamic>.from(json['review'] as Map)
              : null);

    final parsedReviewImages = <String>[];
    String? reviewCreatedAt;
    if (reviewData != null) {
      volunteerComment ??=
          reviewData['comment']?.toString() ??
          reviewData['review']?.toString() ??
          reviewData['text']?.toString();

      if (reviewData['image_url_1'] != null &&
          reviewData['image_url_1'].toString().isNotEmpty) {
        parsedReviewImages.add(reviewData['image_url_1'].toString());
      }
      if (reviewData['image_url_2'] != null &&
          reviewData['image_url_2'].toString().isNotEmpty) {
        parsedReviewImages.add(reviewData['image_url_2'].toString());
      }
      if (reviewData['image_url_3'] != null &&
          reviewData['image_url_3'].toString().isNotEmpty) {
        parsedReviewImages.add(reviewData['image_url_3'].toString());
      }

      if (reviewData['created_at'] != null) {
        final rawCreatedAt = reviewData['created_at'].toString();
        try {
          final dt = DateTime.parse(rawCreatedAt).toLocal();
          final now = DateTime.now();
          if (dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day) {
            reviewCreatedAt = 'Bugün, ${DateFormat('HH:mm').format(dt)}';
          } else {
            reviewCreatedAt = DateFormat('dd.MM.yyyy, HH:mm').format(dt);
          }
        } catch (_) {
          reviewCreatedAt = rawCreatedAt;
        }
      }
    }
    final ownerProgress = _progressFromJson(json['owner_progress']);
    final volunteerProgress =
        _progressFromJson(json['volunteer_progress']) ??
        _progressFromJson(json['progress']) ??
        _progressFromJson(json['task_progress']);
    final availableActions = _stringList(json['available_actions']);
    final topLevelProgress = availableActions.isEmpty
        ? null
        : VolunteerTaskProgress(
            status:
                (json['delivery_status'] ??
                        json['status'] ??
                        json['task_status'])
                    ?.toString(),
            message: json['message']?.toString(),
            availableActions: availableActions,
          );

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

    if (assignedAvatar != null &&
        assignedAvatar.isNotEmpty &&
        !assignedAvatar.startsWith('http')) {
      final cleanPath = assignedAvatar.startsWith('/')
          ? assignedAvatar
          : '/$assignedAvatar';
      assignedAvatar = '${ApiConstants.baseUrl}$cleanPath';
    }

    if (listingImg != null &&
        listingImg.isNotEmpty &&
        !listingImg.startsWith('http')) {
      final cleanPath = listingImg.startsWith('/')
          ? listingImg
          : '/$listingImg';
      listingImg = '${ApiConstants.baseUrl}$cleanPath';
    }

    final parsedTopLevelId = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '');
    final parsedExplicitTaskId = int.tryParse(
      (json['task_id'] ??
                  json['volunteer_task_id'] ??
                  json['delivery_task_id'] ??
                  json['active_task_id'])
              ?.toString() ??
          '',
    );
    final parsedMealId =
        (json['meal_id'] is int ? json['meal_id'] as int : null) ??
        int.tryParse(json['meal_id']?.toString() ?? '') ??
        (json['meal_share_id'] is int ? json['meal_share_id'] as int : null) ??
        int.tryParse(json['meal_share_id']?.toString() ?? '') ??
        (mealData?['id'] is int ? mealData!['id'] as int : null) ??
        int.tryParse(mealData?['id']?.toString() ?? '');
    final effectiveTaskId =
        parsedExplicitTaskId ??
        (parsedMealId != null ? parsedTopLevelId : null);

    return VolunteerActiveListingModel(
      id: parsedMealId ?? parsedTopLevelId ?? 0,
      taskId: effectiveTaskId,
      mealId: parsedMealId,
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
      deliveryStatus:
          (json['delivery_status'] ??
                  json['status'] ??
                  json['task_status'] ??
                  ownerProgress?.status ??
                  volunteerProgress?.status)
              ?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      volunteerComment: volunteerComment,
      reviewCreatedAt: reviewCreatedAt,
      reviewImages: parsedReviewImages.isNotEmpty
          ? parsedReviewImages
          : (json['review_images'] != null
                ? List<String>.from(json['review_images'])
                : []),
      volunteerRating: reviewData?['rating'] != null
          ? double.tryParse(reviewData!['rating'].toString())
          : json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      posterName: pName,
      posterImageUrl: pImage,
      assignedVolunteerName: assignedName,
      assignedVolunteerAvatar: assignedAvatar,
      ownerProgress: ownerProgress,
      volunteerProgress: volunteerProgress ?? topLevelProgress,
      acceptedByUserId: int.tryParse(
        (json['accepted_by_id'] ??
                    json['accepted_by_user_id'] ??
                    json['volunteer_id'])
                ?.toString() ??
            '',
      ),
    );
  }

  static Map<String, dynamic>? _firstMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static VolunteerTaskProgress? _progressFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return VolunteerTaskProgress.fromJson(value);
    }
    if (value is Map) {
      return VolunteerTaskProgress.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return const [];
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

    final mappedStatus = _mapDeliveryStatus(deliveryStatus);
    final effectiveStatus =
        volunteerComment != null &&
            mappedStatus == DeliveryStatus.deliveredPendingReview
        ? DeliveryStatus.completed
        : mappedStatus;

    return VolunteerListing(
      id: id.toString(),
      taskId: taskId?.toString(),
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
      reviewCreatedAt: reviewCreatedAt,
      isAttended: volunteerComment != null || acceptedByUserId != null,
      reviewImages: reviewImages,
      volunteerRating: volunteerRating ?? 5.0,
      volunteerName: assignedVolunteerName ?? posterName,
      volunteerAvatar: assignedVolunteerAvatar ?? posterImageUrl,
      assignedVolunteerName: assignedVolunteerName,
      assignedVolunteerAvatar: assignedVolunteerAvatar,
      isAvailable: isAvailable,
      ownerId: createdByUserId?.toString(),
      acceptedByUserId: acceptedByUserId,
      deliveryStatus: effectiveStatus,
      ownerProgress: ownerProgress,
      volunteerProgress: volunteerProgress,
      pickupStartTime: pickupStartTime,
      pickupEndTime: pickupEndTime,
    );
  }

  DeliveryStatus _mapDeliveryStatus(String? status) {
    if (status == null) return DeliveryStatus.pendingOwnerApproval;

    switch (status.toLowerCase()) {
      case 'pending_owner_approval':
      case 'requested':
      case 'basvuruldu':
        return DeliveryStatus.pendingOwnerApproval;
      case 'accepted':
      case 'atanildi':
        return DeliveryStatus.accepted;
      case 'going_to_pickup':
      case 'almaya_gidiyor':
        return DeliveryStatus.goingToPickUp;
      case 'owner_handed_over':
      case 'ilan_verildi':
        return DeliveryStatus.ownerHandedOver;
      case 'picked_up':
      case 'evden_alindi':
      case 'teslim_alindi':
        return DeliveryStatus.pickedUp;
      case 'going_to_shelter':
      case 'yolda':
        return DeliveryStatus.goingToShelter;
      case 'delivered_pending_review':
      case 'teslim_edildi':
        return DeliveryStatus.deliveredPendingReview;
      case 'completed':
      case 'tamamlandi':
        return DeliveryStatus.completed;
      case 'cancelled':
      case 'iptal_edildi':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pendingOwnerApproval;
    }
  }
}
