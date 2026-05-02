import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/business/business_listing_model.dart';
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
      final response = await _client.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

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
    final url = Uri.parse('${ApiConstants.baseUrl}/api/bags/my');

    if (kDebugMode) {
      print('--- API REQUEST (GET MY BAGS) ---');
      print('URL: $url');
      print('---------------------------------');
    }

    try {
      final response = await _client.get(url, headers: _headers);
      
      if (kDebugMode) {
        print('--- API RESPONSE (GET MY BAGS) ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('----------------------------------');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => BusinessListingModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching bags: $e');
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
      final response = await _client.delete(url, headers: headers);

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
      final response = await _client.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

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
}
