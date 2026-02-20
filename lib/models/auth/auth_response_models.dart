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
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      errorKey: json['error_key'] as String?,
      token: json['token'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
