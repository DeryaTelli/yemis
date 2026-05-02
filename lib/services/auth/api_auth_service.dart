import 'dart:convert';
import 'package:http_parser/http_parser.dart';
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
      if (data is Map<String, dynamic> && !data.containsKey('success')) {
        // API bazen direkt objeyi döner (success: true demeden). Status code 2xx ise başarılı kabul et.
        return AuthResponse.fromJson({...data, 'success': true});
      }
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
  Future<bool> updateAddress(int id, AddressModel address) async {
    final response = await _put('/api/users/me/addresses/$id', address.toJson());
    return response.success;
  }

  @override
  Future<bool> deleteAddress(int id) async {
    final response = await _delete('/api/users/me/addresses/$id');
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
  Future<AuthResponse> updateProfile(int userId, Map<String, dynamic> data) async {
    return _put('/api/users/$userId', data);
  }

  @override
  Future<AuthResponse> deleteAccount() async {
    return _delete(ApiConstants.profile);
  }
  
  @override
  Future<String?> uploadImage(String filePath) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadImage}');

    if (kDebugMode) {
      print('--- IMAGE UPLOAD REQUEST ---');
      print('URL: $url');
      print('FilePath: $filePath');
      print('----------------------------');
    }

    try {
      final request = http.MultipartRequest('POST', url);
      
      // Token ekle
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Dosyayı ekle (Backend 'file' anahtarı bekliyor)
      // Dosya türünü belirle (Backend application/octet-stream kabul etmiyor)
      final extension = filePath.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      else if (extension == 'webp') mimeType = 'image/webp';
      else if (extension == 'gif') mimeType = 'image/gif';

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('--- IMAGE UPLOAD RESPONSE ---');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('-----------------------------');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // API genelde {"url": "..."} veya {"image_url": "..."} döner.
        return data['url'] ?? data['image_url'] ?? data['path'];
      }
    } catch (e) {
      if (kDebugMode) print('Image upload error: $e');
    }
    return null;
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

  /// Ortak PUT isteği metodu.
  Future<AuthResponse> _put(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    if (kDebugMode) {
      print('--- API REQUEST (PUT) ---');
      print('URL: $url');
      if (body != null) print('Body: ${jsonEncode(body)}');
      print('Token: ${_authToken?.substring(0, 5)}...');
      print('-------------------');
    }

    try {
      final response = await _client.put(
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
      if (data is Map<String, dynamic>) {
        if (!data.containsKey('success')) {
          // API doğrudan nesne döndü (örn. user veya address objesi), 2xx ise başarılı say
          // Eğer bu bir kullanıcı objesi ise AuthResponse içine gömelim
          UserModel? user;
          if (data.containsKey('id') && (data.containsKey('email') || data.containsKey('role'))) {
             try {
               user = UserModel.fromJson(data);
             } catch (_) {}
          }

          return AuthResponse(
            success: true, 
            message: 'İşlem başarılı.',
            user: user,
          );
        }
        return AuthResponse.fromJson(data);
      }
      return const AuthResponse(success: true, message: 'İşlem başarılı.');
    } catch (_) {
      return const AuthResponse(success: true, message: 'İşlem başarılı.');
    }
  }
}
