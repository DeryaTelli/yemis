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
  final String? address;
  final double? latitude;
  final double? longitude;

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
    this.address,
    this.latitude,
    this.longitude,
  });

  factory OrderBagModel.fromJson(Map<String, dynamic> json) {
    final store = json['store'] is Map
        ? Map<String, dynamic>.from(json['store'] as Map)
        : null;
    final business = json['business'] is Map
        ? Map<String, dynamic>.from(json['business'] as Map)
        : null;

    return OrderBagModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: (json['image_url'] ?? json['bag_image_url'] ?? json['image'])
          ?.toString(),
      discountedPrice: (json['discounted_price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num).toDouble(),
      pickupStartTime: DateTime.parse(
        json['pickup_start_time'] as String,
      ).toLocal(),
      pickupEndTime: DateTime.parse(
        json['pickup_end_time'] as String,
      ).toLocal(),
      shopName:
          (json['business_name'] ??
                  json['shop_name'] ??
                  business?['name'] ??
                  store?['name'])
              ?.toString(),
      shopLogoUrl:
          (json['business_logo_url'] ??
                  json['shop_logo_url'] ??
                  business?['logo_url'] ??
                  store?['logo_url'])
              ?.toString(),
      address:
          (json['address'] ??
                  json['full_address'] ??
                  json['location_address'] ??
                  business?['address'] ??
                  store?['address'])
              ?.toString(),
      latitude: _toDouble(
        json['latitude'] ??
            json['lat'] ??
            business?['latitude'] ??
            store?['latitude'],
      ),
      longitude: _toDouble(
        json['longitude'] ??
            json['lng'] ??
            business?['longitude'] ??
            store?['longitude'],
      ),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
