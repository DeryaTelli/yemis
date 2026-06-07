import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/business/business_listing_model.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';
import '../../models/food/order_model.dart';
import '../../utils/constants/api_constants.dart';
import 'i_food_service.dart';

class ApiFoodService implements IFoodService {
  final http.Client _client = http.Client();
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> _getWithSingleTimeoutRetry(Uri url) async {
    try {
      return await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
    } on TimeoutException {
      debugPrint(
        '⏱️ [ApiFoodService] GET zaman aşımına uğradı, bir kez tekrar deneniyor: ${url.path}',
      );
      await Future<void>.delayed(const Duration(milliseconds: 750));
      return _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
    }
  }

  @override
  Future<List<FoodListing>> getFeaturedListings() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bags}');
      debugPrint('📡 [ApiFoodService] GET Request: $url');

      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      debugPrint('📥 [ApiFoodService] Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'] as List;
        } else if (decoded is Map && decoded.containsKey('bags')) {
          data = decoded['bags'] as List;
        } else {
          debugPrint('⚠️ [ApiFoodService] Beklenmeyen yanıt formatı: $decoded');
          return [];
        }

        debugPrint('📦 [ApiFoodService] İşlenecek ilan sayısı: ${data.length}');

        final List<FoodListing> listings = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              final businessModel = BusinessListingModel.fromJson(item);
              final foodListing = businessModel.toFoodListing();
              listings.add(foodListing);
            } else {
              debugPrint('⚠️ [ApiFoodService] Öğe bir Map değil: $item');
            }
          } catch (itemError) {
            debugPrint(
              '❌ [ApiFoodService] Öğe işleme hatası: $itemError | Item: $item',
            );
          }
        }

        debugPrint(
          '✅ [ApiFoodService] Toplam başarıyla işlenen ilan: ${listings.length}',
        );
        return listings;
      } else {
        debugPrint(
          '❌ [ApiFoodService] API isteği başarısız: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] Genel Hata: $e');
      return [];
    }
  }

  @override
  Future<List<FoodListing>> getPopularListings({
    int? limit,
    String? category,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (limit != null) {
        queryParameters['limit'] = limit.toString();
      }
      if (category != null) {
        queryParameters['category'] = category;
      }

      final baseUrlUri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.popularBags}',
      );
      final uri = queryParameters.isNotEmpty
          ? baseUrlUri.replace(queryParameters: queryParameters)
          : baseUrlUri;

      debugPrint('📡 [ApiFoodService] GET Popular Request: $uri');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      debugPrint(
        '📥 [ApiFoodService] Popular Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'] as List;
        } else if (decoded is Map && decoded.containsKey('bags')) {
          data = decoded['bags'] as List;
        } else {
          debugPrint(
            '⚠️ [ApiFoodService] Beklenmeyen popüler yanıt formatı: $decoded',
          );
          return [];
        }

        debugPrint(
          '📦 [ApiFoodService] İşlenecek popüler ilan sayısı: ${data.length}',
        );

        final List<FoodListing> listings = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              final businessModel = BusinessListingModel.fromJson(item);
              final foodListing = businessModel.toFoodListing().copyWith(
                section: FoodSection.todayPopular,
              );
              listings.add(foodListing);
            } else {
              debugPrint(
                '⚠️ [ApiFoodService] Popüler öğe bir Map değil: $item',
              );
            }
          } catch (itemError) {
            debugPrint(
              '❌ [ApiFoodService] Popüler öğe işleme hatası: $itemError | Item: $item',
            );
          }
        }
        return listings;
      } else {
        debugPrint(
          '❌ [ApiFoodService] Popüler API isteği başarısız: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] Popüler Genel Hata: $e');
      return [];
    }
  }

  @override
  Future<List<FoodListing>> getPopularTodayListings({
    int? limit,
    String? category,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (limit != null) {
        queryParameters['limit'] = limit.toString();
      }
      if (category != null) {
        queryParameters['category'] = category;
      }

      final baseUrlUri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.popularTodayBags}',
      );
      final uri = queryParameters.isNotEmpty
          ? baseUrlUri.replace(queryParameters: queryParameters)
          : baseUrlUri;

      debugPrint('📡 [ApiFoodService] GET Popular Today Request: $uri');

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      debugPrint(
        '📥 [ApiFoodService] Popular Today Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];

        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'] as List;
        } else if (decoded is Map && decoded.containsKey('bags')) {
          data = decoded['bags'] as List;
        } else {
          debugPrint(
            '⚠️ [ApiFoodService] Beklenmeyen popüler bugün yanıt formatı: $decoded',
          );
          return [];
        }

        debugPrint(
          '📦 [ApiFoodService] İşlenecek popüler bugün ilan sayısı: ${data.length}',
        );

        final List<FoodListing> listings = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              final businessModel = BusinessListingModel.fromJson(item);
              final foodListing = businessModel.toFoodListing().copyWith(
                section: FoodSection.todayPopularAll,
              );
              listings.add(foodListing);
            } else {
              debugPrint(
                '⚠️ [ApiFoodService] Popüler bugün öğe bir Map değil: $item',
              );
            }
          } catch (itemError) {
            debugPrint(
              '❌ [ApiFoodService] Popüler bugün öğe işleme hatası: $itemError | Item: $item',
            );
          }
        }
        return listings;
      } else {
        debugPrint(
          '❌ [ApiFoodService] Popüler bugün isteği başarısız: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] Popüler Bugün Genel Hata: $e');
      return [];
    }
  }

  @override
  Future<FoodListing> getFoodDetail(String id) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.bagById(int.parse(id))}',
      );
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        Map<String, dynamic>? data;

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else if (decoded is List && decoded.isNotEmpty) {
          data = decoded.first as Map<String, dynamic>;
        }

        if (data != null) {
          if (kDebugMode) {
            print('--- API RESPONSE (FOOD DETAIL) ---');
            print('Data: $data');
            print('----------------------------------');
          }
          final businessModel = BusinessListingModel.fromJson(data);
          return businessModel.toFoodListing();
        }
      }
      throw Exception('Failed to load food detail');
    } catch (e) {
      if (kDebugMode) print('Error fetching food detail: $e');
      rethrow;
    }
  }

  @override
  Future<List<FoodReview>> getFoodReviews(String id) async {
    try {
      final bagId = int.tryParse(id);
      if (bagId == null) return [];

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviewsForBag(bagId)}');
      debugPrint('📡 [ApiFoodService] GET Bag Reviews Request: $url');

      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      debugPrint('📥 [ApiFoodService] Bag Reviews Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          final nested = decoded['data'] ?? decoded['reviews'];
          if (nested is List) data = nested;
        }

        final List<FoodReview> reviews = [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            final user = item['user'] is Map ? item['user'] as Map : const {};
            final List<String> photoUrls = [];
            for (final key in ['image_url_1', 'image_url_2', 'image_url_3']) {
              final url = item[key]?.toString().trim();
              if (url != null && url.isNotEmpty) photoUrls.add(url);
            }

            reviews.add(
              FoodReview(
                id: item['id']?.toString() ?? '',
                reviewerName:
                    (item['reviewer_name'] ??
                            item['user_name'] ??
                            user['full_name'] ??
                            user['name'] ??
                            'Kullanıcı')
                        .toString(),
                avatarUrl:
                    (item['user_image_url'] ??
                            item['reviewer_image_url'] ??
                            user['profile_image_url'] ??
                            user['image_url'] ??
                            '')
                        .toString(),
                rating: double.tryParse(item['rating']?.toString() ?? '') ?? 0.0,
                comment: item['comment']?.toString() ?? '',
                date: item['created_at'] != null 
                    ? DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now()
                    : DateTime.now(),
                photoUrls: photoUrls,
              ),
            );
          }
        }
        return reviews;
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] getFoodReviews error: $e');
    }
    return [];
  }

  @override
  Future<String> getUserLocationName() async {
    return 'Konum Seçiniz'; // Varsayılan, UserSession'dan alınacak
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      final bagId = int.tryParse(id);
      if (bagId == null) return;

      // Önce mevcut favorileri kontrol et (SİL mi EKLE mi?)
      // Direkt API'den ham veriyi çekip kontrol edelim, daha sağlam olur.
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.myFavorites}',
      );
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final favItem = data.firstWhere(
          (item) =>
              item['bag_id']?.toString() == id ||
              (item['bag'] != null && item['bag']['id']?.toString() == id),
          orElse: () => null,
        );

        if (favItem != null) {
          // Zaten favori -> SİL (DELETE)
          final favId = int.tryParse(favItem['id']?.toString() ?? '');
          if (favId != null) {
            await removeFavorite(favId);
          }
        } else {
          // Favori değil -> EKLE (POST)
          final postUrl = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.favorites}',
          );
          final postResponse = await _client
              .post(
                postUrl,
                headers: _headers,
                body: jsonEncode({'bag_id': bagId}),
              )
              .timeout(ApiConstants.requestTimeout);

          if (postResponse.statusCode == 201 ||
              postResponse.statusCode == 200) {
            debugPrint('✅ [ApiFoodService] Favori eklendi: $id');
          }
        }
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] toggleFavorite hatası: $e');
    }
  }

  /// Favori silme işlemi için özel metod
  Future<void> removeFavorite(int favoriteId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.favoriteById(favoriteId)}',
      );
      final response = await _client
          .delete(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        debugPrint('✅ [ApiFoodService] Favori silindi: $favoriteId');
      } else {
        debugPrint(
          '❌ [ApiFoodService] Favori silme başarısız: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] removeFavorite hatası: $e');
    }
  }

  @override
  Future<List<FoodListing>> getFavorites() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.myFavorites}',
      );
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      debugPrint(
        '📥 [ApiFoodService] getFavorites Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'];
        }

        final List<String> bagIds = [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            final id =
                (item['bag_id'] ??
                        (item['bag'] != null ? item['bag']['id'] : null))
                    ?.toString();
            if (id != null) bagIds.add(id);
          }
        }

        debugPrint('🔍 [ApiFoodService] Favori Bag IDleri: $bagIds');

        // Her bir ID için detayları çek
        final List<FoodListing> listings = [];
        for (final id in bagIds) {
          try {
            final detail = await getFoodDetail(id);
            listings.add(detail.copyWith(isFavorite: true));
          } catch (e) {
            debugPrint('❌ [ApiFoodService] Detay çekme hatası ($id): $e');
          }
        }

        debugPrint(
          '✅ [ApiFoodService] Toplam başarıyla işlenen favori: ${listings.length}',
        );
        return listings;
      }
      return [];
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] getFavorites hatası: $e');
      return [];
    }
  }

  /// Her sipariş için tekil Idempotency-Key üretir (UUID v4 formatı).
  String _generateIdempotencyKey() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    // UUID v4: version bits ve variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  Future<bool> createOrder(int bagId, int quantity) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}');
      final body = jsonEncode({'bag_id': bagId, 'quantity_reserved': quantity});
      final idempotencyKey = _generateIdempotencyKey();

      final headers = {..._headers, 'Idempotency-Key': idempotencyKey};

      debugPrint('📡 [ApiFoodService] POST Order: ${url.path}');

      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(ApiConstants.requestTimeout);

      debugPrint('📥 [ApiFoodService] Order Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [ApiFoodService] Sipariş oluşturuldu');
        return true;
      } else {
        debugPrint(
          '❌ [ApiFoodService] Sipariş isteği başarısız: ${response.statusCode}',
        );
        return false;
      }
    } on TimeoutException {
      debugPrint('⏱️ [ApiFoodService] Sipariş isteği zaman aşımına uğradı');
      return false;
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] createOrder başarısız');
      return false;
    }
  }

  @override
  Future<bool> cancelOrder(int orderId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.cancelOrder(orderId)}',
      );
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      debugPrint('📥 [ApiFoodService] Cancel Order: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException {
      debugPrint(
        '⏱️ [ApiFoodService] İptal isteği zaman aşımına uğradı; güvenlik nedeniyle otomatik tekrar gönderilmedi',
      );
      return false;
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] cancelOrder başarısız');
      return false;
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myOrders}');
      debugPrint('📡 [ApiFoodService] GET Request: $url');
      final response = await _getWithSingleTimeoutRetry(url);
      debugPrint(
        '📥 [ApiFoodService] getMyOrders Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'] as List;
        }

        final List<OrderModel> orders = [];
        for (var item in data) {
          try {
            if (item is Map<String, dynamic>) {
              orders.add(OrderModel.fromJson(item));
            }
          } catch (itemError) {
            debugPrint(
              '❌ [ApiFoodService] Sipariş işleme hatası: $itemError | Item: $item',
            );
          }
        }
        return orders;
      }
      return [];
    } on TimeoutException {
      debugPrint(
        '⏱️ [ApiFoodService] Siparişler iki denemede de zaman aşımına uğradı',
      );
      return [];
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] getMyOrders başarısız');
      return [];
    }
  }
}
