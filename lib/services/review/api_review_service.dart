import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/review/review_model.dart';
import '../../models/review/review_request_models.dart';
import '../../utils/constants/api_constants.dart';
import 'i_review_service.dart';

/// Gerçek API ile konuşan review servisi.
class ApiReviewService implements IReviewService {
  ApiReviewService({required String? token}) : _token = token;

  final String? _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _get(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (kDebugMode) print('[Review GET] $url');
    final response = await http
        .get(url, headers: _headers)
        .timeout(ApiConstants.requestTimeout);
    if (kDebugMode) print('[Review GET Response] ${response.statusCode} ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (kDebugMode) print('[Review POST] $url body: $body');
    final response = await http
        .post(url, headers: _headers, body: jsonEncode(body))
        .timeout(ApiConstants.requestTimeout);
    if (kDebugMode) print('[Review POST Response] ${response.statusCode} ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<dynamic> _put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (kDebugMode) print('[Review PUT] $url body: $body');
    final response = await http
        .put(url, headers: _headers, body: jsonEncode(body))
        .timeout(ApiConstants.requestTimeout);
    if (kDebugMode) print('[Review PUT Response] ${response.statusCode} ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> _delete(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (kDebugMode) print('[Review DELETE] $url');
    final response = await http
        .delete(url, headers: _headers)
        .timeout(ApiConstants.requestTimeout);
    if (kDebugMode) print('[Review DELETE Response] ${response.statusCode}');
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  @override
  Future<List<ReviewModel>> getStoreReviews(int storeId) async {
    try {
      final data = await _get(ApiConstants.reviewsForStore(storeId));
      if (data is List) {
        return data
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiReviewService] getStoreReviews error: $e');
      return [];
    }
  }

  @override
  Future<ReviewModel?> createReview(CreateReviewRequest request) async {
    try {
      final data = await _post(
        ApiConstants.reviewsForStore(request.storeId),
        request.toJson(),
      );
      if (data is Map<String, dynamic>) {
        return ReviewModel.fromJson(data, isOwn: true);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiReviewService] createReview error: $e');
      return null;
    }
  }

  @override
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final data = await _get(ApiConstants.myReviews);
      if (data is List) {
        return data
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>, isOwn: true))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[ApiReviewService] getMyReviews error: $e');
      return [];
    }
  }

  @override
  Future<ReviewModel?> updateReview(UpdateReviewRequest request) async {
    try {
      final data = await _put(
        ApiConstants.reviewById(request.reviewId),
        request.toJson(),
      );
      if (data is Map<String, dynamic>) {
        return ReviewModel.fromJson(data, isOwn: true);
      }
      return null;
    } catch (e) {
      debugPrint('[ApiReviewService] updateReview error: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteReview(int reviewId) async {
    try {
      return await _delete(ApiConstants.reviewById(reviewId));
    } catch (e) {
      debugPrint('[ApiReviewService] deleteReview error: $e');
      return false;
    }
  }
}
