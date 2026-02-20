import '../../models/auth/auth_request_models.dart';
import '../../models/auth/auth_response_models.dart';

/// Auth servisinin sözleşmesi (interface).
/// İleride [ApiAuthService] ile gerçek API'ye bağlanılacak.
abstract class IAuthService {
  /// Email ve şifre ile giriş yapar.
  Future<AuthResponse> login(LoginRequest request);

  /// Yeni hesap oluşturur.
  Future<AuthResponse> register(RegisterRequest request);

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> forgotPassword(ForgotPasswordRequest request);

  /// E-postaya gönderilen doğrulama kodunu doğrular.
  Future<void> verifyCode(VerifyCodeRequest request);

  /// Doğrulama kodunu tekrar gönderir.
  Future<void> resendCode(String email);
}
