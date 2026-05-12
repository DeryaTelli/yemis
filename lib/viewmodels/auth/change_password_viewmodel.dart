import 'package:flutter/material.dart';
import '../../services/auth/i_auth_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final IAuthService _authService;

  ChangePasswordViewModel({required IAuthService authService})
      : _authService = authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _oldPassword = '';
  String _newPassword = '';

  void onOldPasswordChanged(String value) {
    _oldPassword = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onNewPasswordChanged(String value) {
    _newPassword = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (_oldPassword.isEmpty || _newPassword.isEmpty) {
      _errorMessage = 'Lütfen tüm alanları doldurun.';
      notifyListeners();
      return false;
    }

    if (_newPassword.length < 8 || !_newPassword.contains(RegExp(r'[A-Z]'))) {
      _errorMessage =
          'Yeni şifre en az 8 karakter olmalı ve en az bir büyük harf içermelidir.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        _oldPassword,
        _newPassword,
      );

      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
