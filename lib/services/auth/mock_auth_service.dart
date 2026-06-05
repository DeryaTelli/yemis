import '../../models/auth/address_model.dart';
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

  final List<Map<String, dynamic>> _mockCards = [
    {
      "id": 1,
      "card_holder_name": "BANKKART kartım",
      "card_number_masked": "434528******7936",
      "expiry_date": "12/29",
      "card_type": "VISA",
      "is_default": false,
      "user_id": 1
    },
    {
      "id": 2,
      "card_holder_name": "BANKKART COMBO kartım",
      "card_number_masked": "523529******0082",
      "expiry_date": "06/32",
      "card_type": "MasterCard",
      "is_default": true,
      "user_id": 1
    },
    {
      "id": 3,
      "card_holder_name": "İş Bankası kartım",
      "card_number_masked": "403998******6621",
      "expiry_date": "09/30",
      "card_type": "VISA",
      "is_default": false,
      "user_id": 1
    },
    {
      "id": 4,
      "card_holder_name": "Ziraat Bankası kartım",
      "card_number_masked": "476619******6029",
      "expiry_date": "04/31",
      "card_type": "VISA",
      "is_default": false,
      "user_id": 1
    }
  ];

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
    return const AuthResponse(
      success: true,
      message: 'Password reset successful',
    );
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    return [];
  }

  @override
  Future<bool> createAddress(AddressModel address) async {
    return true;
  }

  @override
  Future<bool> updateAddress(int id, AddressModel address) async {
    await _simulateDelay();
    return true;
  }

  @override
  Future<bool> deleteAddress(int id) async {
    await _simulateDelay();
    return true;
  }

  @override
  Future<AuthResponse> logout() async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Logout successful');
  }

  @override
  Future<UserModel?> getProfile() async {
    await _simulateDelay();
    return const UserModel(
      id: 'usr_001',
      name: 'Test Kullanıcı',
      email: _testEmail,
      userType: UserType.food,
    );
  }

  @override
  Future<AuthResponse> updateProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Profile updated');
  }

  @override
  Future<AuthResponse> deleteAccount() async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Account deleted');
  }

  @override
  Future<String?> uploadImage(String filePath) async {
    await _simulateDelay();
    return "https://i.pravatar.cc/300"; // Mock URL
  }

  @override
  Future<AuthResponse> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    await _simulateDelay();
    return const AuthResponse(success: true, message: 'Password changed');
  }

  @override
  Future<Map<String, dynamic>?> getBusinessDashboardStats() async {
    await _simulateDelay();
    return {
      "weekly_sales": [],
      "summary": {
        "sold_out_bags": 2,
        "total_revenue": 150.0,
        "meals_saved": 10,
        "sell_through_rate": 75.0
      }
    };
  }

  @override
  Future<List<Map<String, dynamic>>?> getCards() async {
    await _simulateDelay();
    return _mockCards;
  }

  @override
  Future<AuthResponse> addCard(Map<String, dynamic> cardData) async {
    await _simulateDelay();
    final newCard = {
      ...cardData,
      "id": _mockCards.length + 1,
      "user_id": 1,
      "created_at": DateTime.now().toIso8601String(),
    };
    _mockCards.add(newCard);
    return const AuthResponse(success: true, message: 'Card added successfully');
  }

  @override
  Future<AuthResponse> deleteCard(int cardId) async {
    await _simulateDelay();
    final previousLength = _mockCards.length;
    _mockCards.removeWhere((card) => card['id'] == cardId);
    final removed = previousLength != _mockCards.length;
    return AuthResponse(
      success: removed,
      message: removed ? 'Card deleted successfully' : 'Card not found',
    );
  }

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 1200));
}
