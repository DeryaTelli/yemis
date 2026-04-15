import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/auth/auth_request_models.dart';
import '../../models/auth/auth_response_models.dart';
import '../../utils/constants/api_constants.dart';
import 'i_auth_service.dart';

class ApiAuthService implements IAuthService {
  final http.Client _client = http.Client();

  /// Ortak POST isteği metodur. Detaylı loglama içerir.
  Future<AuthResponse> _post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    
    if (kDebugMode) {
      print('--- API REQUEST ---');
      print('URL: $url');
      print('Method: POST');
      print('Body: ${jsonEncode(body)}');
      print('-------------------');
    }

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
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
          final String message = data is Map ? (data['message'] ?? 'Sunucu hatası') : 'Sunucu hatası';
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
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await _post(ApiConstants.forgotPassword, request.toJson());
  }

  @override
  Future<void> verifyCode(VerifyCodeRequest request) async {
    await _post(ApiConstants.verifyCode, request.toJson());
  }

  @override
  Future<void> resendCode(String email) async {
    await _post(ApiConstants.register, {'email': email}); // Örnek, endpoint değişebilir
  }
}
