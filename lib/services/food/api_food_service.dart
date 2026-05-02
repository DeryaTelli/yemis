import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/business/business_listing_model.dart';
import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';
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

  @override
  Future<List<FoodListing>> getFeaturedListings() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bags}');
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) {
          final businessModel = BusinessListingModel.fromJson(json);
          return businessModel.toFoodListing();
        }).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching featured listings: $e');
      return [];
    }
  }

  @override
  Future<FoodListing> getFoodDetail(String id) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bagById(int.parse(id))}');
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final businessModel = BusinessListingModel.fromJson(data);
        return businessModel.toFoodListing();
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
  void toggleFavorite(String id) {
    // Favori API entegrasyonu buraya gelecek
  }

  @override
  List<FoodListing> getFavorites() {
    return [];
  }
}
