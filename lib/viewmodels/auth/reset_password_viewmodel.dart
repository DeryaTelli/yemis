import 'package:flutter/material.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/locale_keys.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final String email;
  final String otp;

  ResetPasswordViewModel(this._authService,
      {required this.email, required this.otp});

  // --- Controllers ---
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // --- State ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  String? _errorKey;
  String? get errorKey => _errorKey;

  // --- Actions ---

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorKey = null;
    notifyListeners();
  }

  void clearFields() {
    passwordController.clear();
    confirmPasswordController.clear();
    _errorKey = null;
  }

  Future<void> resetPassword({
    required GlobalKey<FormState> formKey,
    required VoidCallback onSuccess,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      _errorKey = LocaleKeys.auth_validation_passwordsNotMatch;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        ResetPasswordRequest(
          email: email,
          otp: otp,
          password: passwordController.text,
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
