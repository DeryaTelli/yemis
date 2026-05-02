import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';

class BusinessProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  // ─── Profil Verileri ──────────────────────────────────
  File? _selectedImageFile;
  String? _remoteImageUrl;

  File? get selectedImageFile => _selectedImageFile;
  String? get remoteImageUrl => _remoteImageUrl;

  String get name => _userSession.currentUser?.name ?? 'İşletme Adı';
  String get email => _userSession.currentUser?.email ?? 'isletme@mail.com';
  String? get imageUrl => _userSession.currentUser?.imageUrl;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  BusinessProfileViewModel(this._authService, this._userSession)
    : nameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController() {
    _remoteImageUrl = _userSession.currentUser?.imageUrl;
    _resetControllers();
  }

  void _resetControllers() {
    nameController.text = name;
    emailController.text = email;
    phoneController.text = _userSession.currentUser?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ── Daily stats ──────────────────────────────
  int get dailySoldCount => 10;
  String get dailyTotalEarnings => '%25';

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
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
    if (userId == null) return;

    String? imageUrl = _userSession.currentUser?.imageUrl;
    if (_selectedImageFile != null) {
      final uploadedUrl = await _authService.uploadImage(
        _selectedImageFile!.path,
      );
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    final Map<String, dynamic> updateData = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      if (imageUrl != null) 'image_url': imageUrl,
    };

    final response = await _authService.updateProfile(userId, updateData);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      if (response.success) {
        if (response.user != null) {
          _userSession.setUser(response.user!);
          _remoteImageUrl = response.user!.imageUrl;
        }
        _selectedImageFile = null;
        _resetControllers();
        notifyListeners();
        Navigator.pop(context);
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    _authService.logout().catchError((e) {
      debugPrint('Logout API error: $e');
    });

    _userSession.clear();

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
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hayır', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
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

  /// 0=BusinessHome, 1=Rezervasyon Onaylama, 2=Home(merkez), 3=Sipariş Ekle, 4=Profil
  String? getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return AppRoutes.businessHome;
      case 1:
        return AppRoutes.businessApprovals;
      case 2:
        return AppRoutes.home;
      case 3:
        return AppRoutes.businessAddOrder;
      case 4:
        return AppRoutes.businessProfile;
      default:
        return null;
    }
  }
}
