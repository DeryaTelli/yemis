import 'package:yemis/models/auth/user_model.dart';

import '../../models/auth/address_model.dart';
import '../../models/auth/auth_request_models.dart';
import '../../models/auth/auth_response_models.dart';

/// Auth servisinin sözleşmesi (interface).
/// İleride [ApiAuthService] ile gerçek API'ye bağlanılacak.
abstract class IAuthService {
  /// Email ve şifre ile giriş yapar.
  Future<AuthResponse> login(LoginRequest request);

  /// Yeni hesap oluşturur.
  Future<AuthResponse> register(RegisterRequest request);

  /// Şifre sıfırlama e-postası gönderir (OTP gönderir).
  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request);

  /// E-postaya gönderilen doğrulama kodunu doğrular.
  Future<AuthResponse> verifyCode(VerifyCodeRequest request);

  /// Doğrulama kodunu tekrar gönderir.
  Future<AuthResponse> resendCode(String email);

  /// Şifre yenileme işlemini tamamlar.
  Future<AuthResponse> resetPassword(ResetPasswordRequest request);

  /// Oturumu kapatır.
  Future<AuthResponse> logout();

  /// Kullanıcının adreslerini listeler.
  Future<List<AddressModel>> getAddresses();

  /// Yeni adres oluşturur.
  Future<bool> createAddress(AddressModel address);

  /// Mevcut adresi günceller.
  Future<bool> updateAddress(int id, AddressModel address);

  /// Adresi siler.
  Future<bool> deleteAddress(int id);

  /// Mevcut kullanıcının profil bilgilerini getirir.
  Future<UserModel?> getProfile();

  /// Profil bilgilerini günceller.
  Future<AuthResponse> updateProfile(int userId, Map<String, dynamic> data);

  /// Hesabı siler.
  Future<AuthResponse> deleteAccount();

  /// Görsel yükler ve URL döner.
  Future<String?> uploadImage(String filePath);

  /// Şifre değiştirir.
  Future<AuthResponse> changePassword(String oldPassword, String newPassword);

  /// İşletme istatistiklerini getirir.
  Future<Map<String, dynamic>?> getBusinessDashboardStats();

  /// Kullanıcının kayıtlı kartlarını listeler.
  Future<List<Map<String, dynamic>>?> getCards();

  /// Kullanıcıya yeni kart kaydeder.
  Future<AuthResponse> addCard(Map<String, dynamic> cardData);
}
