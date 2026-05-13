import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yemis/services/auth/api_auth_service.dart';
import 'package:yemis/services/business/api_business_service.dart';
import 'package:yemis/services/business/i_business_service.dart';
import 'package:yemis/services/food/api_food_service.dart';
import 'package:yemis/services/food/i_food_service.dart';
import 'package:yemis/services/volunteer/api_volunteer_service.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import '../../models/auth/auth_request_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/locale_keys.dart';
import '../../services/common/assistant_service.dart';

class VerificationViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IBusinessService _businessService;
  final IFoodService _foodService;
  final IVolunteerService _volunteerService;
  final IAssistantService _assistantService;
  final UserSession _userSession;
  final String email;
  final bool isPasswordReset;

  VerificationViewModel(
    this._authService,
    this._businessService,
    this._foodService,
    this._volunteerService,
    this._assistantService,
    this._userSession, {
    required this.email,
    this.isPasswordReset = false,
  }) {
    _startTimer();
  }

  String get otp => _fullCode;

  // --- Controllers (4 haneli kod için) ---
  final List<TextEditingController> codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  // --- State ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Locale key döner — View .tr() ile çevirir
  String? _errorKey;
  String? get errorKey => _errorKey;

  int _remainingSeconds = 57;
  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _remainingSeconds == 0;

  Timer? _timer;

  // --- Timer ---

  void _startTimer() {
    _remainingSeconds = 57;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  String get timerDisplay {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Code Input Helpers ---

  void onCodeChanged(int index, String value, BuildContext context) {
    if (value.length == 1 && index < 3) {
      focusNodes[index + 1].requestFocus();
    }
    notifyListeners();
  }

  void onCodeBackspace(int index, BuildContext context) {
    if (codeControllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String get _fullCode => codeControllers.map((c) => c.text).join();

  // --- Actions ---

  void clearError() {
    _errorKey = null;
    notifyListeners();
  }

  void clearFields() {
    for (final c in codeControllers) {
      c.clear();
    }
    _errorKey = null;
  }

  /// Kodu doğrular. Başarılıysa [onSuccess] çağrılır.
  Future<void> verify({
    required VoidCallback onSuccess,
    Function(String)? onError,
  }) async {
    final code = otp;
    if (code.length < 4) return;

    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final response = await _authService.verifyCode(
        VerifyCodeRequest(email: email, code: code),
      );

      if (response.success) {
        if (!isPasswordReset && response.user != null) {
          // Giriş bilgilerini kaydet
          _userSession.setUser(response.user!, token: response.token, persist: true);

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
          if (_assistantService is ApiAssistantService) {
            (_assistantService as ApiAssistantService).setToken(response.token);
          }
        }
        onSuccess();
      } else {
        _errorKey = response.errorKey ?? LocaleKeys.auth_errors_codeInvalid;
        if (onError != null) {
          onError(
            response.message ?? 'Doğrulama kodu geçersiz veya süresi dolmuş.',
          );
        }
      }
    } catch (e) {
      _errorKey = LocaleKeys.auth_errors_general;
      if (onError != null) {
        onError('Sunucuya bağlanılamadı. Lütfen tekrar deneyin.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kodu tekrar gönderir.
  Future<void> resendCode({Function(String)? onError}) async {
    if (!canResend) return;

    _isLoading = true;
    _errorKey = null;
    notifyListeners();

    try {
      final response = await _authService.resendCode(email);
      if (response.success) {
        _startTimer();
      } else {
        _errorKey = response.errorKey ?? LocaleKeys.auth_errors_emailSendFailed;
        if (onError != null) {
          onError(
            response.message ??
                'Kod tekrar gönderilemedi. Lütfen biraz bekleyip tekrar deneyin.',
          );
        }
      }
    } catch (e) {
      _errorKey = LocaleKeys.auth_errors_general;
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
    _timer?.cancel();
    for (final c in codeControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
