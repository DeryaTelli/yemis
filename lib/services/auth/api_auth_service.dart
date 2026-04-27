import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yemis/models/auth/user_model.dart';

import '../../models/auth/address_model.dart';
import '../../models/auth/auth_request_models.dart';
import '../../models/auth/auth_response_models.dart';
import '../../utils/constants/api_constants.dart';
import 'i_auth_service.dart';

class ApiAuthService implements IAuthService {
  final http.Client _client = http.Client();
  String? _authToken;

  /// Token'ı günceller (Login sonrası veya Session'dan).
  void setToken(String? token) => _authToken = token;

  /// Ortak GET isteği metodu.
  Future<dynamic> _get(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    if (kDebugMode) {
      print('--- API REQUEST ---');
      print('URL: $url');
      print('Method: GET');
      if (_authToken != null) print('Token: ${_authToken!.substring(0, 5)}...');
      print('-------------------');
    }

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      if (kDebugMode) {
        print('--- API RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  /// Ortak POST isteği metodur. Detaylı loglama içerir.
  Future<AuthResponse> _post(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    if (kDebugMode) {
      print('--- API REQUEST ---');
      print('URL: $url');
      print('Method: POST');
      if (body != null) print('Body: ${jsonEncode(body)}');
      if (_authToken != null) print('Token: ${_authToken!.substring(0, 5)}...');
      print('-------------------');
    }

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: body != null ? jsonEncode(body) : null,
      );

      if (kDebugMode) {
        print('--- API RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('--------------------');
      }

      // Sunucu 200-299 arası dönmüyorsa JSON parse etmeden önce status check yap
      if (response.statusCode < 200 || response.statusCode >= 300) {
        try {
          final data = jsonDecode(response.body);
          final String message = data is Map
              ? (data['message'] ?? 'Sunucu hatası')
              : 'Sunucu hatası';
          return AuthResponse(
            success: false,
            message: message,
            errorKey: data is Map ? data['error_key'] : null,
          );
        } catch (_) {
          // JSON değilse düz metin olarak hatayı al
          return AuthResponse(
            success: false,
            message: 'Sunucu hatası: ${response.statusCode} - ${response.body}',
          );
        }
      }

      final dynamic data = jsonDecode(response.body);
      return AuthResponse.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('--- API ERROR ---');
        print('Exception: $e');
        print('-----------------');
      }
      return AuthResponse(
        success: false,
        message: 'Ağ hatası: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) {
    return _post(ApiConstants.login, request.toJson());
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    return _post(ApiConstants.register, request.toJson());
  }

  @override
  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    return _post(ApiConstants.forgotPassword, request.toJson());
  }

  @override
  Future<AuthResponse> verifyCode(VerifyCodeRequest request) async {
    return _post(ApiConstants.verifyCode, request.toJson());
  }

  @override
  Future<AuthResponse> resendCode(String email) async {
    return _post(ApiConstants.resendCode, {'email': email});
  }

  @override
  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    return _post(ApiConstants.resetPassword, request.toJson());
  }

  @override
  Future<AuthResponse> logout() async {
    final response = await _post(ApiConstants.logout, null);
    if (response.success) {
      setToken(null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
    return response;
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    final data = await _get('/api/users/me/addresses');
    if (data is List) {
      return data
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> createAddress(AddressModel address) async {
    final response = await _post('/api/users/me/addresses', address.toJson());
    return response.success;
  }

  @override
  Future<UserModel?> getProfile() async {
    final data = await _get(ApiConstants.profile);
    if (data != null && data is Map<String, dynamic>) {
      return UserModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthResponse> updateProfile(Map<String, dynamic> data) async {
    return _patch(ApiConstants.profile, data);
  }

  @override
  Future<AuthResponse> deleteAccount() async {
    return _delete(ApiConstants.profile);
  }

  /// Ortak PATCH isteği metodu.
  Future<AuthResponse> _patch(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    if (kDebugMode) {
      print('--- API REQUEST (PATCH) ---');
      print('URL: $url');
      if (body != null) print('Body: ${jsonEncode(body)}');
      print('-------------------');
    }

    try {
      final response = await _client.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: body != null ? jsonEncode(body) : null,
      );

      return _processResponse(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  /// Ortak DELETE isteği metodu.
  Future<AuthResponse> _delete(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    if (kDebugMode) {
      print('--- API REQUEST (DELETE) ---');
      print('URL: $url');
      print('-------------------');
    }

    try {
      final response = await _client.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      );

      return _processResponse(response);
    } catch (e) {
      return AuthResponse(success: false, message: e.toString());
    }
  }

  AuthResponse _processResponse(http.Response response) {
    if (kDebugMode) {
      print('--- API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('--------------------');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final data = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'İşlem başarısız.',
        );
      } catch (_) {
        return AuthResponse(
          success: false,
          message: 'Sunucu hatası: ${response.statusCode}',
        );
      }
    }

    try {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (_) {
      return const AuthResponse(success: true, message: 'İşlem başarılı.');
    }
  }
}
