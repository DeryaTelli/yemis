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
  Future<List<VolunteerListing>> getFeaturedListings({
    double? lat,
    double? lng,
    double? radius,
  }) async {
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
    final list = await _fetchVolunteerListingsFromUrl(
      '${ApiConstants.baseUrl}${ApiConstants.mealById(int.parse(id))}',
    );
    if (list.isNotEmpty) return list.first;
    throw Exception('Listing not found');
  }

  @override
  Future<List<VolunteerListing>> getActiveListings() async {
    final meals = await _tryFetchVolunteerListingsFromUrl(
      '${ApiConstants.baseUrl}${ApiConstants.myActiveMeals}',
    );
    final ownerTasks = await _tryFetchVolunteerListingsFromUrl(
      '${ApiConstants.baseUrl}${ApiConstants.ownerVolunteerTasks}',
    );

    if (ownerTasks.isEmpty) return meals;
    if (meals.isEmpty) return ownerTasks;

    final mergedByMealId = {for (final meal in meals) meal.id: meal};
    for (final ownerTask in ownerTasks) {
      mergedByMealId[ownerTask.id] = ownerTask;
    }
    return mergedByMealId.values.toList();
  }

  @override
  Future<List<VolunteerListing>> getOwnerVolunteerTasks() async {
    return _fetchVolunteerListingsFromUrl(
      '${ApiConstants.baseUrl}${ApiConstants.ownerVolunteerTasks}',
    );
  }

  @override
  Future<List<VolunteerListing>> getPastListings() async {
    return _fetchVolunteerListingsFromUrl(
      '${ApiConstants.baseUrl}${ApiConstants.myPastMeals}',
    );
  }

  @override
  Future<List<VolunteerListing>> getAttendedListings() async {
    try {
      return await _fetchVolunteerListingsFromUrl(
        '${ApiConstants.baseUrl}${ApiConstants.attendedTasks}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching attended tasks from API: $e');
      }
      return const [];
    }
  }


  @override
  Future<List<VolunteerListing>> getMyActiveTasks() async {
    return _fetchVolunteerListingsFromUrl(
      '${ApiConstants.baseUrl}${ApiConstants.myActiveTasks}',
    );
  }

  Future<List<VolunteerListing>> _fetchVolunteerListingsFromUrl(
    String urlString,
  ) async {
    final url = Uri.parse(urlString);
    final endpointLabel = _endpointLabel(urlString);

    if (kDebugMode) {
      print('--- API REQUEST ($endpointLabel) ---');
      print('URL: $url');
      print('------------------------------');
    }

    try {
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      if (kDebugMode) {
        print('--- API RESPONSE ($endpointLabel) ---');
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
          final value = decoded['data'];
          if (value is List) data = value;
          if (value is Map && value['results'] is List) {
            data = value['results'] as List;
          }
        } else if (decoded is Map && decoded['results'] is List) {
          data = decoded['results'] as List;
        } else if (decoded is Map && decoded['items'] is List) {
          data = decoded['items'] as List;
        } else if (decoded is Map && decoded['meals'] is List) {
          data = decoded['meals'] as List;
        } else if (decoded is Map) {
          // Tekil nesne dönmüş olabilir
          data = [decoded];
        }

        return data
            .map((e) {
              if (e is Map<String, dynamic>) {
                return VolunteerActiveListingModel.fromJson(
                  e,
                ).toVolunteerListing();
              }
              return null;
            })
            .whereType<VolunteerListing>()
            .toList();
      } else {
        throw Exception(
          'Failed to fetch meals: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching $endpointLabel from $urlString: $e');
      }
      rethrow;
    }
  }

  String _endpointLabel(String urlString) {
    if (urlString.contains(ApiConstants.myActiveTasks)) {
      return 'VOLUNTEER ACTIVE TASKS';
    }
    if (urlString.contains(ApiConstants.ownerVolunteerTasks)) {
      return 'OWNER VOLUNTEER TASKS';
    }
    if (urlString.contains(ApiConstants.attendedTasks)) {
      return 'ATTENDED TASKS';
    }
    if (urlString.contains(ApiConstants.meals)) {
      return 'MEALS';
    }
    return 'VOLUNTEER API';
  }

  Future<List<VolunteerListing>> _tryFetchVolunteerListingsFromUrl(
    String urlString,
  ) async {
    try {
      return await _fetchVolunteerListingsFromUrl(urlString);
    } catch (e) {
      if (kDebugMode) {
        print('Optional volunteer listing fetch failed: $urlString -> $e');
      }
      return [];
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
      final response = await _client
          .post(url, headers: _headers, body: jsonEncode(data))
          .timeout(ApiConstants.requestTimeout);

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
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.mealById(id)}',
    );

    if (kDebugMode) {
      print('--- API REQUEST (DELETE MEAL) ---');
      print('URL: $url');
      print('--------------------------------');
    }

    try {
      final response = await _client
          .delete(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

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
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.mealById(id)}',
    );

    if (kDebugMode) {
      print('--- API REQUEST (PUT MEAL) ---');
      print('URL: $url');
      print('Headers: $_headers');
      print('Body: ${jsonEncode(data)}');
      print('------------------------------');
    }

    try {
      final response = await _client
          .put(url, headers: _headers, body: jsonEncode(data))
          .timeout(ApiConstants.requestTimeout);

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
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

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
    String urlString =
        '${ApiConstants.baseUrl}${ApiConstants.sheltersNearby}?lat=$lat&lng=$lng&radius_km=$radiusKm';
    if (city != null && city.isNotEmpty) {
      urlString += '&city=$city';
    }
    if (district != null && district.isNotEmpty) {
      urlString += '&district=$district';
    }

    final url = Uri.parse(urlString);

    if (kDebugMode) {
      print('--- API REQUEST (GET NEARBY SHELTERS) ---');
      print('URL: $url');
      print('-----------------------------------------');
    }

    try {
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

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
  Future<bool> startPickup(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.startPickup(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error starting pickup: $e');
      return false;
    }
  }

  @override
  Future<bool> markPickedUp(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.markPickedUp(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error marking picked up: $e');
      return false;
    }
  }

  @override
  Future<bool> startDelivery(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.startDelivery(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error starting delivery: $e');
      return false;
    }
  }

  @override
  Future<bool> confirmDelivery(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.confirmDelivery(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error confirming delivery: $e');
      return false;
    }
  }

  @override
  Future<bool> acceptVolunteer(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.acceptVolunteer(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      if (kDebugMode) {
        print(
          'acceptVolunteer($taskId) -> ${response.statusCode} ${response.body}',
        );
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error accepting volunteer: $e');
      return false;
    }
  }

  @override
  Future<bool> rejectVolunteer(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.rejectVolunteer(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      if (kDebugMode) {
        print(
          'rejectVolunteer($taskId) -> ${response.statusCode} ${response.body}',
        );
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error rejecting volunteer: $e');
      return false;
    }
  }

  @override
  Future<bool> ownerHandover(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ownerHandover(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      if (kDebugMode) {
        print(
          'ownerHandover($taskId) -> ${response.statusCode} ${response.body}',
        );
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error in owner handover: $e');
      return false;
    }
  }

  @override
  Future<bool> submitVolunteerReview(
    int taskId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.volunteerReview(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers, body: jsonEncode(data))
          .timeout(ApiConstants.requestTimeout);
      if (kDebugMode) {
        print(
          'submitVolunteerReview($taskId) -> ${response.statusCode} ${response.body}',
        );
      }
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error submitting volunteer review: $e');
      return false;
    }
  }

  @override
  Future<bool> submitOwnerReview(int taskId, Map<String, dynamic> data) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.ownerReview(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers, body: jsonEncode(data))
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error submitting owner review: $e');
      return false;
    }
  }

  @override
  Future<bool> completeTask(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.completeTask(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error completing task: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelTask(int taskId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.cancelTask(taskId)}',
    );
    try {
      final response = await _client
          .post(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error cancelling task: $e');
      return false;
    }
  }
}
