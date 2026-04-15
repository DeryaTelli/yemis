import 'user_model.dart';

/// API'den dönen auth yanıtı.
/// [errorKey] → LocaleKeys sabiti, View tarafında .tr() ile çevrilir.
class AuthResponse {
  final bool success;
  final String message;
  final String? errorKey;
  final String? token;
  final UserModel? user;

  const AuthResponse({
    required this.success,
    required this.message,
    this.errorKey,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final dynamic successRaw = json['success'];
    final bool parsedSuccess = successRaw is bool
        ? successRaw
        : successRaw?.toString().toLowerCase() == 'true';
    final dynamic tokenRaw = json['token'] ?? json['access_token'];
    return AuthResponse(
      success: parsedSuccess,
      message: (json['message'] ?? json['detail'] ?? 'Unknown error').toString(),
      errorKey: json['error_key'] as String?,
      token: tokenRaw?.toString(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
