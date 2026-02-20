import 'package:flutter/material.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/locale_keys.dart';

class LoginViewModel extends ChangeNotifier {
  final IAuthService _authService;

  LoginViewModel(this._authService);

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
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
          rememberMe: _rememberMe,
        ),
      );

      if (response.success) {
        onSuccess();
      } else {
        _errorKey = response.errorKey ?? LocaleKeys.auth_errors_general;
      }
    } catch (_) {
      _errorKey = LocaleKeys.auth_errors_general;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
