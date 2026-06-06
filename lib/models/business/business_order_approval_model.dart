import 'dart:convert';

class BusinessOrderApprovalModel {
  const BusinessOrderApprovalModel({
    required this.id,
    required this.bagId,
    required this.status,
    required this.quantity,
    required this.listingTitle,
    required this.businessName,
    this.customerName,
    this.imageUrl,
    this.pickupCode,
    this.pickupQrToken,
  });

  final int id;
  final int bagId;
  final String status;
  final int quantity;
  final String listingTitle;
  final String businessName;
  final String? customerName;
  final String? imageUrl;
  final String? pickupCode;
  final String? pickupQrToken;

  factory BusinessOrderApprovalModel.fromJson(Map<String, dynamic> json) {
    final bag = _map(json['bag']) ?? _map(json['listing']);
    final user = _map(json['user']) ?? _map(json['customer']);
    final business = _map(bag?['business']) ?? _map(json['business']);

    return BusinessOrderApprovalModel(
      id: _int(json['id'] ?? json['order_id']),
      bagId: _int(json['bag_id'] ?? bag?['id']),
      status: (json['order_status'] ?? json['status'] ?? 'pending').toString(),
      quantity: _int(
        json['quantity_reserved'] ?? json['quantity'] ?? json['count'],
        fallback: 1,
      ),
      listingTitle:
          (bag?['title'] ??
                  json['bag_title'] ??
                  json['listing_title'] ??
                  'Sürpriz Kutu')
              .toString(),
      businessName:
          (bag?['shop_name'] ??
                  bag?['business_name'] ??
                  business?['name'] ??
                  'İşletme')
              .toString(),
      customerName:
          (user?['full_name'] ??
                  user?['name'] ??
                  json['customer_name'] ??
                  json['user_name'])
              ?.toString(),
      imageUrl:
          (bag?['image_url'] ??
                  bag?['bag_image_url'] ??
                  json['image_url'] ??
                  json['bag_image_url'])
              ?.toString(),
      pickupCode: (json['pickup_code'] ?? json['code'])?.toString(),
      pickupQrToken:
          (json['pickup_qr_token'] ?? json['qr_token'] ?? json['qr_code'])
              ?.toString(),
    );
  }

  bool matchesScan(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return false;
    if (_matchesValue(value)) {
      return true;
    }

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        final data = Map<String, dynamic>.from(decoded);
        final scannedId = data['order_id'] ?? data['orderId'] ?? data['id'];
        final scannedToken =
            data['pickup_qr_token'] ?? data['qr_token'] ?? data['token'];
        final scannedCode = data['pickup_code'] ?? data['code'];
        return _matchesValue(scannedId?.toString()) ||
            _matchesValue(scannedToken?.toString()) ||
            _matchesValue(scannedCode?.toString());
      }
    } catch (_) {
      // QR content is not JSON; continue with URI matching.
    }

    final uri = Uri.tryParse(value);
    if (uri != null) {
      final scannedId =
          uri.queryParameters['order_id'] ??
          uri.queryParameters['orderId'] ??
          uri.queryParameters['id'];
      final scannedToken =
          uri.queryParameters['token'] ??
          uri.queryParameters['pickup_qr_token'] ??
          uri.queryParameters['qr_token'];
      final scannedCode =
          uri.queryParameters['pickup_code'] ?? uri.queryParameters['code'];
      return _matchesValue(scannedId) ||
          _matchesValue(scannedToken) ||
          _matchesValue(scannedCode);
    }
    return false;
  }

  bool _matchesValue(String? value) {
    if (value == null || value.isEmpty) return false;
    return pickupQrToken == value ||
        pickupCode == value ||
        id.toString() == value;
  }

  static Map<String, dynamic>? _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
