import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/locale_keys.dart';
import '../../utils/routes/app_routes.dart';

class LoginViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  /// SharedPreferences anahtarı — LocationViewModel ile ortak
  static const String locationOnboardingKey = 'location_onboarding_done';

  LoginViewModel(this._authService, this._userSession);

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

  /// Giriş yapar. Başarılıysa [onSuccess] callback'i çağrılır.
  Future<void> login({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
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
        _userSession.setUser(response.user!);
        onSuccess();
      } else {
        _errorKey = response.errorKey;
        // Eğer errorKey yoksa backend'den gelen detaylı mesajı al
        if (_errorKey == null) {
          _errorMessage = response.message;
        }
      }
    } catch (_) {
      _errorKey = LocaleKeys.auth_errors_general;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login başarısından sonra hangi sayfaya gidileceğini döner.
  /// - `location_onboarding_done = true` → Home
  /// - aksi halde → Location (ilk kez)
  Future<String> afterLoginRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(locationOnboardingKey) ?? false;
    return done ? AppRoutes.home : AppRoutes.location;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
