import 'package:yemis/models/auth/user_model.dart';

/// Login isteği
class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'remember_me': rememberMe,
      };
}

/// Kayıt isteği
class RegisterRequest {
  final String name;
  final String email;
  final String password;

  /// Kullanıcı tipi: [UserType.food] veya [UserType.business]
  final UserType userType;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.userType = UserType.food,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}


/// Şifre sıfırlama isteği
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

/// Doğrulama kodu isteği
class VerifyCodeRequest {
  final String email;
  final String code;

  const VerifyCodeRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
      };
}
