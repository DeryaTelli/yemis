import 'package:flutter/material.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/locale_keys.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final IAuthService _authService;

  ForgotPasswordViewModel(this._authService);

  // --- Controllers ---
  final TextEditingController emailController = TextEditingController();

  // --- State ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _emailSent = false;
  bool get emailSent => _emailSent;

  /// Locale key döner — View .tr() ile çevirir
  String? _errorKey;
  String? get errorKey => _errorKey;

  // --- Actions ---

  void clearError() {
    _errorKey = null;
    notifyListeners();
  }

  void clearFields() {
    emailController.clear();
    _emailSent = false;
    _errorKey = null;
  }

  /// Şifre sıfırlama e-postası gönderir. Başarılıysa [onSuccess] çağrılır.
  Future<void> sendResetEmail({
    required GlobalKey<FormState> formKey,
    required void Function(String email) onSuccess,
    Function(String)? onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(
        ForgotPasswordRequest(email: emailController.text.trim()),
      );
      if (response.success) {
        _emailSent = true;
        onSuccess(emailController.text.trim());
      } else {
        _errorKey = response.errorKey ?? LocaleKeys.auth_errors_emailSendFailed;
        if (onError != null) {
          onError(response.message ?? 'E-posta gönderilemedi. Lütfen tekrar deneyin.');
        }
      }
    } catch (e) {
      _errorKey = LocaleKeys.auth_errors_emailSendFailed;
      if (onError != null) {
        onError('Sunucuya bağlanılamadı. Lütfen tekrar deneyin.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
