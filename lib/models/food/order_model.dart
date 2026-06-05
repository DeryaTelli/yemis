class OrderModel {
  final int id;
  final int userId;
  final int bagId;
  final String orderStatus;
  final int quantityReserved;
  final DateTime orderTime;
  final String? pickupCode;
  final String? pickupQrToken;
  final OrderBagModel? bag;

  OrderModel({
    required this.id,
    required this.userId,
    required this.bagId,
    required this.orderStatus,
    required this.quantityReserved,
    required this.orderTime,
    this.pickupCode,
    this.pickupQrToken,
    this.bag,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bagId: json['bag_id'] as int,
      orderStatus: json['order_status'] as String,
      quantityReserved: json['quantity_reserved'] as int,
      orderTime: DateTime.parse(json['order_time'] as String).toLocal(),
      pickupCode: json['pickup_code'] as String?,
      pickupQrToken: json['pickup_qr_token'] as String?,
      bag: json['bag'] != null
          ? OrderBagModel.fromJson(json['bag'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OrderBagModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final double discountedPrice;
  final double originalPrice;
  final DateTime pickupStartTime;
  final DateTime pickupEndTime;
  final String? shopName;
  final String? shopLogoUrl;

  OrderBagModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.discountedPrice,
    required this.originalPrice,
    required this.pickupStartTime,
    required this.pickupEndTime,
    this.shopName,
    this.shopLogoUrl,
  });

  factory OrderBagModel.fromJson(Map<String, dynamic> json) {
    return OrderBagModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      discountedPrice: (json['discounted_price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num).toDouble(),
      pickupStartTime: DateTime.parse(json['pickup_start_time'] as String).toLocal(),
      pickupEndTime: DateTime.parse(json['pickup_end_time'] as String).toLocal(),
      shopName: json['shop_name'] as String?,
      shopLogoUrl: json['shop_logo_url'] as String?,
    );
  }
}
