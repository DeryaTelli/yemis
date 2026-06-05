import 'dart:convert';
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

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    debugPrint('🔑 [ApiFoodService] Headers: $headers');
    return headers;
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
              // Detaylı log bastırma
              debugPrint('--- 📦 İlan Detayı (Ham Veri) ---');
              debugPrint(const JsonEncoder.withIndent('  ').convert(item));
              
              final businessModel = BusinessListingModel.fromJson(item);
              final foodListing = businessModel.toFoodListing();
              listings.add(foodListing);
              
              debugPrint('✅ İşlenen Model: ${foodListing.title} | Kat: ${foodListing.category} | Fiyat: ${foodListing.price}');
              debugPrint('---------------------------------');
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
          '❌ [ApiFoodService] API Hatası (${response.statusCode}): ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] Genel Hata: $e');
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
    // Şimdilik boş veya mock dönebiliriz, API'de reviews endpoint'i kontrol edilmeli
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
        debugPrint('❌ [ApiFoodService] Favori silme hatası: ${response.body}');
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
            final id = (item['bag_id'] ??
                    (item['bag'] != null ? item['bag']['id'] : null))
                ?.toString();
            if (id != null) bagIds.add(id);
          }
        }

        debugPrint('🔍 [ApiFoodService] Favori Bag IDleri: $bagIds');

        // Her bir ID için detayları çek
        final List<FoodListing> listings = [];
        final results = await Future.wait(
          bagIds.map((id) => getFoodDetail(id).catchError((e) {
                debugPrint('❌ [ApiFoodService] Detay çekme hatası ($id): $e');
                return null;
              })),
        );

        for (var res in results) {
          if (res != null) {
            listings.add(res.copyWith(isFavorite: true));
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

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.myOrders}',
      );
      debugPrint('📡 [ApiFoodService] GET Request: $url');
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      debugPrint('📥 [ApiFoodService] getMyOrders Status: ${response.statusCode}');

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
            debugPrint('❌ [ApiFoodService] Sipariş işleme hatası: $itemError | Item: $item');
          }
        }
        return orders;
      }
      return [];
    } catch (e) {
      debugPrint('🚨 [ApiFoodService] getMyOrders hatası: $e');
      return [];
    }
  }
}
