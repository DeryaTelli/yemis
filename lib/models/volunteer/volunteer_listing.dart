/// Gönüllü ilanının hangi bölümde gösterileceğini belirtir.
enum VolunteerSection {
  nearYou, // Sana Yakın Yerler
  todayPopular, // Bugün Popüler Olanlar
}

/// Gönüllü görevinin teslimat durumunu belirtir.
enum DeliveryStatus {
  pendingOwnerApproval,         // Gönüllü talep etti, sahip onayı bekliyor (requested)
  accepted,                     // Sahibi onayladı, gönüllü bekleniyor
  goingToPickUp,               // Gönüllü almaya geliyor (start-pickup)
  ownerHandedOver,             // Sahibi ilanı verdiğini bildirdi (owner-handover)
  pickedUp,                    // Gönüllü teslim aldığını onayladı (mark-picked-up)
  goingToShelter,              // Barınağa götürülüyor (start-delivery)
  deliveredPendingReview,      // Barınağa ulaştı, yorum bekleniyor (complete)
  completed,                   // Tamamlandı ve yorum yapıldı
  cancelled,                   // İptal edildi
}

class VolunteerProgressStep {
  const VolunteerProgressStep({
    required this.index,
    required this.key,
    required this.label,
    required this.state,
  });

  final int index;
  final String key;
  final String label;
  final String state;

  factory VolunteerProgressStep.fromJson(Map<String, dynamic> json) {
    return VolunteerProgressStep(
      index: int.tryParse(json['index']?.toString() ?? '') ?? 0,
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }
}

class VolunteerTaskProgress {
  const VolunteerTaskProgress({
    this.status,
    this.message,
    this.currentStep,
    this.steps = const [],
    this.availableActions = const [],
  });

  final String? status;
  final String? message;
  final int? currentStep;
  final List<VolunteerProgressStep> steps;
  final List<String> availableActions;

  factory VolunteerTaskProgress.fromJson(Map<String, dynamic> json) {
    return VolunteerTaskProgress(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      currentStep: int.tryParse(json['current_step']?.toString() ?? ''),
      steps: json['steps'] is List
          ? (json['steps'] as List)
              .whereType<Map>()
              .map((e) => VolunteerProgressStep.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      availableActions: json['available_actions'] is List
          ? (json['available_actions'] as List)
              .map((e) => e.toString())
              .toList()
          : const [],
    );
  }
}

/// Bir gönüllü ilanını temsil eder.
class VolunteerListing {
  const VolunteerListing({
    required this.id,
    required this.title,
    required this.userName,
    this.userLogoUrl,
    required this.location,
    required this.timeRange,
    required this.imageUrl,
    required this.rating,
    required this.section,
    this.latitude,
    this.longitude,
    this.isNetworkImage = false,
    this.shopLogoUrl,
    // ── Detay Alanları (Opsiyonel) ──
    this.description,
    this.ingredients,
    this.packageInfo,
    this.shelterLatitude,
    this.shelterLongitude,
    this.shelterName,
    this.shelterAddress,
    this.volunteerComment,
    this.isAttended = false,
    this.reviewImages = const [],
    this.volunteerRating = 5.0,
    this.volunteerName,
    this.volunteerAvatar,
    this.assignedVolunteerName,
    this.assignedVolunteerAvatar,
    this.isAvailable = true,
    this.ownerId,
    this.acceptedByUserId,
    this.deliveryStatus = DeliveryStatus.pendingOwnerApproval,
    this.ownerProgress,
    this.volunteerProgress,
    this.taskId,
    this.pickupStartTime,
    this.pickupEndTime,
  });

  final String id;
  final String? taskId; // Gönüllü görevi için task ID
  final DateTime? pickupStartTime;
  final DateTime? pickupEndTime;
  final String title;
  final String userName;
  final String? userLogoUrl;
  final String location;
  final String timeRange;
  final String imageUrl;
  final double rating;
  final VolunteerSection section;

  // Harita için opsiyonel koordinatlar
  final double? latitude;
  final double? longitude;
  final bool isNetworkImage;
  final String? shopLogoUrl;

  // Detay ekranı için opsiyonel alanlar
  final String? description;
  final String? ingredients;
  final String? packageInfo;
  final double? shelterLatitude;
  final double? shelterLongitude;
  final String? shelterName;
  final String? shelterAddress;
  final String? volunteerComment;
  final bool isAttended;
  final List<String> reviewImages;
  final double volunteerRating;
  final String? volunteerName;
  final String? volunteerAvatar;
  final String? assignedVolunteerName;
  final String? assignedVolunteerAvatar;
  final bool isAvailable;
  final String? ownerId;
  final int? acceptedByUserId;
  final DeliveryStatus deliveryStatus;
  final VolunteerTaskProgress? ownerProgress;
  final VolunteerTaskProgress? volunteerProgress;

  VolunteerListing copyWith({
    String? title,
    String? userName,
    String? userLogoUrl,
    String? location,
    String? timeRange,
    String? imageUrl,
    double? rating,
    VolunteerSection? section,
    double? latitude,
    double? longitude,
    bool? isNetworkImage,
    String? shopLogoUrl,
    String? description,
    String? ingredients,
    String? packageInfo,
    double? shelterLatitude,
    double? shelterLongitude,
    String? shelterName,
    String? shelterAddress,
    String? volunteerComment,
    bool? isAttended,
    List<String>? reviewImages,
    double? volunteerRating,
    String? volunteerName,
    String? volunteerAvatar,
    String? assignedVolunteerName,
    String? assignedVolunteerAvatar,
    bool? isAvailable,
    String? ownerId,
    int? acceptedByUserId,
    DeliveryStatus? deliveryStatus,
    VolunteerTaskProgress? ownerProgress,
    VolunteerTaskProgress? volunteerProgress,
    String? taskId,
    DateTime? pickupStartTime,
    DateTime? pickupEndTime,
  }) {
    return VolunteerListing(
      id: id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      userName: userName ?? this.userName,
      userLogoUrl: userLogoUrl ?? this.userLogoUrl,
      location: location ?? this.location,
      timeRange: timeRange ?? this.timeRange,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      section: section ?? this.section,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isNetworkImage: isNetworkImage ?? this.isNetworkImage,
      shopLogoUrl: shopLogoUrl ?? this.shopLogoUrl,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      packageInfo: packageInfo ?? this.packageInfo,
      shelterLatitude: shelterLatitude ?? this.shelterLatitude,
      shelterLongitude: shelterLongitude ?? this.shelterLongitude,
      shelterName: shelterName ?? this.shelterName,
      shelterAddress: shelterAddress ?? this.shelterAddress,
      volunteerComment: volunteerComment ?? this.volunteerComment,
      isAttended: isAttended ?? this.isAttended,
      reviewImages: reviewImages ?? this.reviewImages,
      volunteerRating: volunteerRating ?? this.volunteerRating,
      volunteerName: volunteerName ?? this.volunteerName,
      volunteerAvatar: volunteerAvatar ?? this.volunteerAvatar,
      assignedVolunteerName: assignedVolunteerName ?? this.assignedVolunteerName,
      assignedVolunteerAvatar: assignedVolunteerAvatar ?? this.assignedVolunteerAvatar,
      isAvailable: isAvailable ?? this.isAvailable,
      ownerId: ownerId ?? this.ownerId,
      acceptedByUserId: acceptedByUserId ?? this.acceptedByUserId,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      ownerProgress: ownerProgress ?? this.ownerProgress,
      volunteerProgress: volunteerProgress ?? this.volunteerProgress,
      pickupStartTime: pickupStartTime ?? this.pickupStartTime,
      pickupEndTime: pickupEndTime ?? this.pickupEndTime,
    );
  }
}
