import 'package:flutter/material.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';

class FoodProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  // ─── Profil Verileri ──────────────────────────────────
  String _name = 'Derya';
  String _surname = 'Telli';
  String _email = '2002derya2002@gmail.com';
  String _phoneNumber = '';
  bool _isEditing = false;

  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  bool get isEditing => _isEditing;

  late final TextEditingController nameController;
  late final TextEditingController surnameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  FoodProfileViewModel(this._authService, this._userSession) {
    _name = _userSession.currentUser?.name.split(' ').first ?? _name;
    _surname = (_userSession.currentUser?.name.contains(' ') ?? false)
        ? _userSession.currentUser!.name.split(' ').last
        : _surname;
    _email = _userSession.currentUser?.email ?? _email;
    _phoneNumber = _userSession.currentUser?.phoneNumber ?? '';

    // Düzenleme ekranı için +90 veya 0 kısmını temizle
    String displayPhone = _phoneNumber;
    if (displayPhone.startsWith('+90')) {
      displayPhone = displayPhone.substring(3).trim();
    } else if (displayPhone.startsWith('0')) {
      displayPhone = displayPhone.substring(1).trim();
    }

    nameController = TextEditingController(text: _name);
    surnameController = TextEditingController(text: _surname);
    emailController = TextEditingController(text: _email);
    phoneController = TextEditingController(text: displayPhone);
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    if (_isEditing) {
      nameController.text = _name;
      surnameController.text = _surname;
      emailController.text = _email;
      phoneController.text = _phoneNumber;
    }
    notifyListeners();
  }

  void saveProfile() {
    _name = nameController.text;
    _surname = surnameController.text;
    _email = emailController.text;
    _phoneNumber = phoneController.text;
    _isEditing = false;
    notifyListeners();
  }

  void updateAccount() {
    _name = nameController.text;
    _surname = surnameController.text;
    _email = emailController.text;
    _phoneNumber = phoneController.text;
    // Burada API çağrısı yapılabilir.
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    // API çağrısını arka planda başlatıyoruz, cevabı beklemiyoruz
    _authService.logout().catchError((e) {
      debugPrint('Logout API error: $e');
    });

    // Yerel verileri anında temizliyoruz
    _userSession.clear();

    // Kullanıcıyı hemen giriş ekranına yönlendiriyoruz
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hayır', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialogu kapat
              // Hesap silme onay mantığı
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text('Evet', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// MVVM: Alt navigasyon rotalarını ViewModel sağlar
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.foodHome;
      case 1:
        return AppRoutes.foodSearch;
      case 2:
        return AppRoutes.home;
      case 3:
        return AppRoutes.foodFavorites;
      case 4:
        return AppRoutes.foodProfile;
      default:
        return null;
    }
  }
}
