import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/models/volunteer/volunteer_active_listing_model.dart';
import 'package:yemis/models/volunteer/shelter_model.dart';
import 'package:yemis/utils/constants/api_constants.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';

class ApiVolunteerService implements IVolunteerService {
  final http.Client _client = http.Client();
  String? _authToken;

  void setToken(String? token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  @override
  Future<String> getUserLocationName() async {
    return 'Karabük, Merkez';
  }

  @override
  Future<List<VolunteerListing>> getFeaturedListings({double? lat, double? lng, double? radius}) async {
    String url = '${ApiConstants.baseUrl}${ApiConstants.meals}';
    List<String> params = [];
    if (lat != null) params.add('lat=$lat');
    if (lng != null) params.add('lng=$lng');
    if (radius != null) params.add('radius=$radius');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    return _fetchVolunteerListingsFromUrl(url);
  }

  @override
  Future<VolunteerListing> getVolunteerDetail(String id) async {
    final list = await _fetchVolunteerListingsFromUrl('${ApiConstants.baseUrl}${ApiConstants.mealById(int.parse(id))}');
    if (list.isNotEmpty) return list.first;
    throw Exception('Listing not found');
  }

  @override
  Future<List<VolunteerListing>> getActiveListings() async {
    return _fetchVolunteerListingsFromUrl('${ApiConstants.baseUrl}${ApiConstants.myActiveMeals}');
  }

  @override
  Future<List<VolunteerListing>> getPastListings() async {
    return _fetchVolunteerListingsFromUrl('${ApiConstants.baseUrl}${ApiConstants.myPastMeals}');
  }

  @override
  Future<List<VolunteerListing>> getAttendedListings() async {
    return _fetchVolunteerListingsFromUrl('${ApiConstants.baseUrl}${ApiConstants.attendedTasks}');
  }

  Future<List<VolunteerListing>> _fetchVolunteerListingsFromUrl(String urlString) async {
    final url = Uri.parse(urlString);

    if (kDebugMode) {
      print('--- API REQUEST (GET MEALS) ---');
      print('URL: $url');
      print('------------------------------');
    }

    try {
      final response = await _client.get(url, headers: _headers);
      
      if (kDebugMode) {
        print('--- API RESPONSE (GET MEALS) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('-------------------------------');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = [];
        
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          data = decoded['data'] as List;
        } else if (decoded is Map) {
          // Tekil nesne dönmüş olabilir
          data = [decoded];
        }

        return data.map((e) {
          if (e is Map<String, dynamic>) {
            return VolunteerActiveListingModel.fromJson(e).toVolunteerListing();
          }
          return null;
        }).whereType<VolunteerListing>().toList();
      } else {
        throw Exception('Failed to fetch meals: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching meals from $urlString: $e');
      rethrow;
    }
  }

  @override
  Future<bool> createMeal(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meals}');

    if (kDebugMode) {
      print('--- API REQUEST (POST MEAL) ---');
      print('URL: $url');
      print('Headers: $_headers');
      print('Body: ${jsonEncode(data)}');
      print('-------------------------------');
    }

    try {
      final response = await _client.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      if (kDebugMode) {
        print('--- API RESPONSE (POST MEAL) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error creating meal: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteMeal(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mealById(id)}');

    if (kDebugMode) {
      print('--- API REQUEST (DELETE MEAL) ---');
      print('URL: $url');
      print('--------------------------------');
    }

    try {
      final response = await _client.delete(url, headers: _headers);

      if (kDebugMode) {
        print('--- API RESPONSE (DELETE MEAL) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('----------------------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error deleting meal: $e');
      return false;
    }
  }

  @override
  Future<bool> updateMeal(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mealById(id)}');

    if (kDebugMode) {
      print('--- API REQUEST (PUT MEAL) ---');
      print('URL: $url');
      print('Headers: $_headers');
      print('Body: ${jsonEncode(data)}');
      print('------------------------------');
    }

    try {
      final response = await _client.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      if (kDebugMode) {
        print('--- API RESPONSE (PUT MEAL) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('-------------------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error updating meal: $e');
      return false;
    }
  }

  @override
  Future<bool> becomeVolunteer(int mealId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.mealVolunteer(mealId)}',
    );

    if (kDebugMode) {
      print('--- API REQUEST (POST VOLUNTEER) ---');
      print('URL: $url');
      print('Headers: $_headers');
      print('------------------------------------');
    }

    try {
      final response = await _client.post(url, headers: _headers);

      if (kDebugMode) {
        print('--- API RESPONSE (POST VOLUNTEER) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('-------------------------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error becoming volunteer for meal $mealId: $e');
      return false;
    }
  }

  @override
  Future<List<ShelterModel>> getNearbyShelters({
    required double lat,
    required double lng,
    double radiusKm = 50,
    String? city,
    String? district,
  }) async {
    String urlString = '${ApiConstants.baseUrl}${ApiConstants.sheltersNearby}?lat=$lat&lng=$lng&radius_km=$radiusKm';
    if (city != null && city.isNotEmpty) urlString += '&city=$city';
    if (district != null && district.isNotEmpty) urlString += '&district=$district';
    
    final url = Uri.parse(urlString);

    if (kDebugMode) {
      print('--- API REQUEST (GET NEARBY SHELTERS) ---');
      print('URL: $url');
      print('-----------------------------------------');
    }

    try {
      final response = await _client.get(url, headers: _headers);

      if (kDebugMode) {
        print('--- API RESPONSE (GET NEARBY SHELTERS) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('------------------------------------------');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ShelterModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching nearby shelters: $e');
    }
    return [];
  }

  @override
  Future<bool> completeTask(int taskId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.completeTask(taskId)}');
    try {
      final response = await _client.post(url, headers: _headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error completing task: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelTask(int taskId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cancelTask(taskId)}');
    try {
      final response = await _client.post(url, headers: _headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error cancelling task: $e');
      return false;
    }
  }
}
