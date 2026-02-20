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
  static const _fakeToken = 'mock-jwt-token-abc123';

  final Map<String, String> _registeredUsers = {
    _testEmail: _testPassword,
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

    return AuthResponse(
      success: true,
      message: 'Login successful',
      token: _fakeToken,
      user: UserModel(
        id: 'usr_001',
        name: 'Test Kullanıcı',
        email: request.email,
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
      ),
    );
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await _simulateDelay();
  }

  @override
  Future<void> verifyCode(VerifyCodeRequest request) async {
    await _simulateDelay();
    if (request.code != '1234') {
      throw Exception('Invalid code');
    }
  }

  @override
  Future<void> resendCode(String email) async {
    await _simulateDelay();
  }

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 1200));
}
