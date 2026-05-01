import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/auth/auth_response_models.dart';
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

  // ─── Profil Fotoğrafı ─────────────────────────────────
  File? _selectedImageFile;   // Kullanıcının yerel seçtiği dosya
  String? _remoteImageUrl;    // API'den gelen mevcut fotoğraf URL'i

  File? get selectedImageFile => _selectedImageFile;
  String? get remoteImageUrl => _remoteImageUrl;

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
    _remoteImageUrl = _userSession.currentUser?.imageUrl;

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

  // ─── Fotoğraf Seçme ──────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      _selectedImageFile = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> updateAccount(BuildContext context) async {
    final currentUser = _userSession.currentUser;
    if (currentUser == null) return;

    final int? userId = int.tryParse(currentUser.id);
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı ID geçersiz.')),
        );
      }
      return;
    }

    // Seçilen fotoğrafı base64'e çevir
    String? imageUrl = _remoteImageUrl; // Mevcut URL'i koru (değişmemişse)
    if (_selectedImageFile != null) {
      try {
        final bytes = await _selectedImageFile!.readAsBytes();
        final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        imageUrl = base64Str;
        debugPrint('--- [DEBUG] Image encoded, size: ${bytes.length} bytes ---');
      } catch (e) {
        debugPrint('--- [DEBUG] Image encoding failed: $e ---');
      }
    }

    final Map<String, dynamic> updateData = {
      'name': '${nameController.text} ${surnameController.text}'.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      if (imageUrl != null) 'image_url': imageUrl,
    };

    final response = await _authService.updateProfile(userId, updateData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
      if (response.success) {
        // API'den dönen güncel kullanıcıyı session'a yaz
        if (response.user != null) {
          _userSession.setUser(response.user!);
          _remoteImageUrl = response.user!.imageUrl;
        }

        _name = nameController.text;
        _surname = surnameController.text;
        _email = emailController.text;
        _phoneNumber = phoneController.text;
        notifyListeners();
        Navigator.pop(context);
      }
    }
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
      return AuthResponse(success: false, message: e.toString());
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
