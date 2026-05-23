import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemis/services/auth/api_auth_service.dart';
import 'package:yemis/services/business/api_business_service.dart';
import 'package:yemis/services/business/i_business_service.dart';
import 'package:yemis/services/food/api_food_service.dart';
import 'package:yemis/services/food/i_food_service.dart';
import 'package:yemis/services/notifications/api_notification_service.dart';
import 'package:yemis/services/volunteer/api_volunteer_service.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/locale_keys.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import 'package:yemis/services/common/notification_service.dart';
import 'package:yemis/services/common/assistant_service.dart';
import 'dart:io';

class LoginViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IBusinessService _businessService;
  final IFoodService _foodService;
  final IVolunteerService _volunteerService;
  final ApiNotificationService _notificationService;
  final IAssistantService _assistantService;
  final UserSession _userSession;

  /// SharedPreferences anahtarı — LocationViewModel ile ortak
  static const String locationOnboardingKey = 'location_onboarding_done';

  LoginViewModel(
    this._authService,
    this._businessService,
    this._foodService,
    this._volunteerService,
    this._notificationService,
    this._assistantService,
    this._userSession,
  );

  // --- Controllers ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- State ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  bool _rememberMe = true;
  bool get rememberMe => _rememberMe;

  /// Locale key döner — View .tr() ile çevirir
  String? _errorKey;
  String? get errorKey => _errorKey;

  /// Backend'den gelen ham hata mesajı (LocaleKey yoksa kullanılır)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Actions ---

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  void clearError() {
    _errorKey = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    _errorKey = null;
    _errorMessage = null;
  }

  /// Giriş yapar. Başarılıysa [onSuccess] callback'i çağrılır.
  Future<void> login({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
    Function(String)? onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    _errorKey = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
          rememberMe: _rememberMe,
        ),
      );

      if (response.success && response.user != null) {
        // --- Hata Ayıklama Logları ---
        debugPrint('--- LOGIN SUCCESS ---');
        debugPrint('User ID: ${response.user?.id}');
        debugPrint('User Name: ${response.user?.name}');
        debugPrint('User Email: ${response.user?.email}');
        debugPrint('User Role (API): ${response.user?.userType}');
        debugPrint('Is Business: ${response.user?.isBusiness}');
        debugPrint('Is Food: ${response.user?.isFood}');
        debugPrint('----------------------');

        _userSession.setUser(response.user!, token: response.token, persist: _rememberMe);
        if (_authService is ApiAuthService) {
          (_authService as ApiAuthService).setToken(response.token);
        }
        if (_businessService is ApiBusinessService) {
          (_businessService as ApiBusinessService).setToken(response.token);
        }
        if (_foodService is ApiFoodService) {
          (_foodService as ApiFoodService).setToken(response.token ?? '');
        }
        if (_volunteerService is ApiVolunteerService) {
          (_volunteerService as ApiVolunteerService).setToken(response.token);
        }
        _notificationService.setToken(response.token);
        if (_assistantService is ApiAssistantService) {
          (_assistantService as ApiAssistantService).setToken(response.token);
        }

        // --- Register Device Token ---
        Future<void>(() async {
          try {
            final fcmToken = await NotificationService().getToken();
            if (fcmToken != null) {
              final platform = Platform.isAndroid ? 'android' : 'ios';
              await _notificationService.registerDeviceToken(fcmToken, platform);
            }
          } catch (e) {
            debugPrint('Error registering device token: $e');
          }
        });

        onSuccess();
      } else {
        _errorKey = response.errorKey;
        if (_errorKey == null) {
          _errorMessage = response.message;
        }
        if (onError != null) {
          onError(_errorMessage ?? _errorKey?.toString() ?? 'Bir hata oluştu');
        }
      }
    } catch (e) {
      _errorKey = LocaleKeys.auth_errors_general;
      if (onError != null) {
        onError('Bağlantı hatası oluştu. Lütfen tekrar deneyin.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login başarısından sonra hangi sayfaya gidileceğini döner.
  Future<String> afterLoginRoute() async {
    try {
      final addresses = await _authService.getAddresses();
      if (addresses.isEmpty) {
        return AppRoutes.location;
      } else {
        // İlk adresi veya varsayılan adresi seçip oturuma ekle
        final def = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        _userSession.updateLocation(
          def.addressLine,
          lat: def.latitude,
          lng: def.longitude,
        );

        // Yerel belleğe de işaret koy (onboarding tamamlandı gibi)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(locationOnboardingKey, true);
        await prefs.setString('current_location_address', def.addressLine);
        await prefs.setDouble('current_lat', def.latitude);
        await prefs.setDouble('current_lng', def.longitude);

        return AppRoutes.home;
      }
    } catch (_) {
      // Hata durumunda güvenli tarafta kalıp Home'a atıyoruz (veya Location'a da atılabilir)
      return AppRoutes.home;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
