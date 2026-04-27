import 'package:flutter/material.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/locale_keys.dart';

class RegisterViewModel extends ChangeNotifier {
  final IAuthService _authService;

  RegisterViewModel(this._authService);

  // --- Controllers ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // --- State ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  bool _kvkkAccepted = false;
  bool get kvkkAccepted => _kvkkAccepted;

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

  void toggleKvkk() {
    _kvkkAccepted = !_kvkkAccepted;
    notifyListeners();
  }

  void clearError() {
    _errorKey = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    _kvkkAccepted = false;
    _errorKey = null;
    _errorMessage = null;
  }

  /// Kayıt olur. Başarılıysa [onSuccess] callback'i çağrılır.
  Future<void> register({
    required GlobalKey<FormState> formKey,
    required void Function(String email) onSuccess,
    Function(String)? onError,
  }) async {
    if (!formKey.currentState!.validate()) return;
    if (!_kvkkAccepted) {
      _errorKey = LocaleKeys.auth_validation_kvkkRequired;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorKey = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        RegisterRequest(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      if (response.success) {
        onSuccess(emailController.text.trim());
      } else {
        _errorKey = response.errorKey;
        // Eğer errorKey yoksa backend'den gelen detaylı mesajı al
        if (_errorKey == null) {
          _errorMessage = response.message;
        }
        if (onError != null) {
          onError(_errorMessage ?? _errorKey?.toString() ?? 'Kayıt sırasında bir hata oluştu');
        }
      }
    } catch (_) {
      _errorKey = LocaleKeys.auth_errors_general;
      if (onError != null) {
        onError('Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
