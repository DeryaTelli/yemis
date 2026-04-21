import '../../models/auth/auth_request_models.dart';
import '../../models/auth/auth_response_models.dart';
import '../../models/auth/user_model.dart';
import '../../utils/locale_keys.dart';
import 'i_auth_service.dart';

/// Geliştirme aşamasında kullanılan sahte (mock) auth servisi.
/// Gerçek API'ye geçince MockAuthService → ApiAuthService ile değiştirilir.
class MockAuthService implements IAuthService {
  static const _testEmail = 'test@yemis.app';
  static const _testPassword = '123456';
  static const _businessEmail = 'business@yemis.app';
  static const _businessPassword = '123456';
  static const _fakeToken = 'mock-jwt-token-abc123';

  final Map<String, String> _registeredUsers = {
    _testEmail: _testPassword,
    _businessEmail: _businessPassword,
  };

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    await _simulateDelay();

    final storedPassword = _registeredUsers[request.email];
    if (storedPassword == null || storedPassword != request.password) {
      return const AuthResponse(
        success: false,
        message: 'Invalid credentials',
        errorKey: LocaleKeys.auth_errors_invalidCredentials,
      );
    }

    final isBusiness = request.email == _businessEmail;

    return AuthResponse(
      success: true,
      message: 'Login successful',
      token: _fakeToken,
      user: UserModel(
        id: isBusiness ? 'usr_bus_001' : 'usr_001',
        name: isBusiness ? 'Test İşletme' : 'Test Kullanıcı',
        email: request.email,
        userType: isBusiness ? UserType.business : UserType.food,
      ),
    );
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    await _simulateDelay();

    if (_registeredUsers.containsKey(request.email)) {
      return const AuthResponse(
        success: false,
        message: 'Email already registered',
        errorKey: LocaleKeys.auth_errors_emailAlreadyRegistered,
      );
    }

    _registeredUsers[request.email] = request.password;

    return AuthResponse(
      success: true,
      message: 'Registration successful',
      token: _fakeToken,
      user: UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: request.name,
        email: request.email,
        userType: request.userType,
      ),
    );
  }

  @override
  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'OTP sent');
  }

  @override
  Future<AuthResponse> verifyCode(VerifyCodeRequest request) async {
    await _simulateDelay();
    if (request.code != '1234') {
      return const AuthResponse(
        success: false,
        message: 'Invalid code',
        errorKey: LocaleKeys.auth_errors_codeInvalid,
      );
    }
    return const AuthResponse(success: true, message: 'Code verified');
  }

  @override
  Future<AuthResponse> resendCode(String email) async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Code resent');
  }

  @override
  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Password reset successful');
  }

  @override
  Future<AuthResponse> logout() async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Logout successful');
  }

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 1200));
}
