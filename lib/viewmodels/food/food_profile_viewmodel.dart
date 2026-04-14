import 'package:flutter/material.dart';
import '../../utils/routes/app_routes.dart';

class FoodProfileViewModel extends ChangeNotifier {
  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  // ─── Profil Verileri ──────────────────────────────────
  String _name = 'Derya';
  String _surname = 'Telli';
  String _email = '2002derya2002@gmail.com';
  bool _isEditing = false;

  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  bool get isEditing => _isEditing;

  late final TextEditingController nameController;
  late final TextEditingController surnameController;
  late final TextEditingController emailController;

  FoodProfileViewModel() {
    nameController = TextEditingController(text: _name);
    surnameController = TextEditingController(text: _surname);
    emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    if (_isEditing) {
      nameController.text = _name;
      surnameController.text = _surname;
      emailController.text = _email;
    }
    notifyListeners();
  }

  void saveProfile() {
    _name = nameController.text;
    _surname = surnameController.text;
    _email = emailController.text;
    _isEditing = false;
    notifyListeners();
  }

  void updateAccount() {
    _name = nameController.text;
    _surname = surnameController.text;
    _email = emailController.text;
    // Burada API çağrısı yapılabilir.
    notifyListeners();
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void logout(BuildContext context) {
    // Burada gerçek çıkış mantığı (Token temizleme vs.) yapılır.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void deleteAccount(BuildContext context) {
    // Hesap silme onay mantığı
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
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
