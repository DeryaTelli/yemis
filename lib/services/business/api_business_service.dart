import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/business/business_listing_model.dart';
import '../../models/business/business_dashboard_model.dart';
import '../../utils/constants/api_constants.dart';
import 'i_business_service.dart';

class ApiBusinessService implements IBusinessService {
  final http.Client _client = http.Client();
  String? _authToken;

  void setToken(String? token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  @override
  Future<bool> createBag(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bags}');

    if (kDebugMode) {
      print('--- API REQUEST (POST BAG) ---');
      print('URL: $url');
      print('Body: ${jsonEncode(data)}');
      print('------------------------------');
    }

    try {
      final response = await _client
          .post(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(ApiConstants.requestTimeout);

      if (kDebugMode) {
        print('--- API RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error creating bag: $e');
      return false;
    }
  }

  @override
  Future<List<BusinessListingModel>> getMyBags() async {
    return _fetchBagsFromUrl('${ApiConstants.baseUrl}${ApiConstants.myBags}');
  }

  @override
  Future<List<BusinessListingModel>> getMyUnsoldBags() async {
    return _fetchBagsFromUrl('${ApiConstants.baseUrl}${ApiConstants.myUnsoldBags}');
  }

  @override
  Future<List<BusinessListingModel>> getMySoldBags() async {
    return _fetchBagsFromUrl('${ApiConstants.baseUrl}${ApiConstants.mySoldBags}');
  }

  Future<List<BusinessListingModel>> _fetchBagsFromUrl(String urlString) async {
    final url = Uri.parse(urlString);

    if (kDebugMode) {
      print('--- API REQUEST (GET BAGS) ---');
      print('URL: $url');
      print('------------------------------');
    }

    try {
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);
      
      if (kDebugMode) {
        print('--- API RESPONSE (GET BAGS) ---');
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
        } else if (decoded is Map && decoded.containsKey('bags')) {
          data = decoded['bags'] as List;
        }

        return data.map((e) {
          if (e is Map<String, dynamic>) {
            return BusinessListingModel.fromJson(e);
          }
          return null;
        }).whereType<BusinessListingModel>().toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching bags from $urlString: $e');
    }
    return [];
  }

  @override
  Future<bool> deleteBag(int id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bagById(id)}');

    // Bazı sunucular boş body'li DELETE isteğinde Content-Type istemeyebilir
    final headers = Map<String, String>.from(_headers);
    headers.remove('Content-Type');

    if (kDebugMode) {
      print('--- API REQUEST (DELETE BAG) ---');
      print('URL: $url');
      print('Method: DELETE');
      print('Headers: $headers');
      print('------------------------------');
    }

    try {
      final response = await _client
          .delete(url, headers: headers)
          .timeout(ApiConstants.requestTimeout);

      if (kDebugMode) {
        print('--- API RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error deleting bag: $e');
      return false;
    }
  }

  @override
  Future<bool> updateBag(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bagById(id)}');

    if (kDebugMode) {
      print('--- API REQUEST (PUT BAG) ---');
      print('URL: $url');
      print('Body: ${jsonEncode(data)}');
      print('-----------------------------');
    }

    try {
      final response = await _client
          .put(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(ApiConstants.requestTimeout);

      if (kDebugMode) {
        print('--- API RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------');
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('Error updating bag: $e');
      return false;
    }
  }

  @override
  Future<BusinessDashboardModel?> getDashboardStats() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.businessDashboard}');

    if (kDebugMode) {
      print('--- API REQUEST (GET DASHBOARD) ---');
      print('URL: $url');
      print('-----------------------------------');
    }

    try {
      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.requestTimeout);

      if (kDebugMode) {
        print('--- API RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return BusinessDashboardModel.fromJson(decoded);
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching dashboard stats: $e');
    }
    return null;
  }
}
