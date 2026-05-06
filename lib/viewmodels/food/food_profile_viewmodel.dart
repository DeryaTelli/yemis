import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../models/auth/auth_response_models.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import 'package:yemis/widgets/common/error_dialog_custom.dart';
import 'package:yemis/widgets/common/success_dialog_custom.dart';
import 'package:lottie/lottie.dart';

class FoodProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  // ─── Profil Verileri ──────────────────────────────────
  String _name = '';
  String _surname = '';
  String _email = '';
  String _phoneNumber = '';
  bool _isEditing = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ─── Profil Fotoğrafı ─────────────────────────────────
  File? _selectedImageFile; // Kullanıcının yerel seçtiği dosya
  String? _remoteImageUrl; // API'den gelen mevcut fotoğraf URL'i

  File? get selectedImageFile => _selectedImageFile;
  String? get remoteImageUrl => _remoteImageUrl;

  String get fullName => _isEditing
      ? fullNameController.text
      : (_userSession.currentUser?.name ?? '');
  String get email => _isEditing
      ? emailController.text
      : (_userSession.currentUser?.email ?? _email);
  String get phoneNumber => _isEditing
      ? phoneController.text
      : (_userSession.currentUser?.phoneNumber ?? _phoneNumber);
  bool get isEditing => _isEditing;

  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  FoodProfileViewModel(this._authService, this._userSession) {
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    // Mevcut verileri hemen göster, sonra API'den tazele
    _initData();
    _resetControllers();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _userSession.setUser(user);
        _initData();
        _resetControllers();
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initData() {
    final user = _userSession.currentUser;
    _name = user?.name.split(' ').first ?? '';
    _surname = (user?.name.contains(' ') ?? false)
        ? user!.name.split(' ').last
        : '';
    _email = user?.email ?? '';
    _phoneNumber = user?.phoneNumber ?? '';
    _remoteImageUrl = user?.imageUrl;
  }

  void _resetControllers() {
    _initData();
    fullNameController.text = _userSession.currentUser?.name ?? '';
    emailController.text = _email;

    // Düzenleme ekranı için +90 veya 0 kısmını temizle
    String displayPhone = _phoneNumber;
    if (displayPhone.startsWith('+90')) {
      displayPhone = displayPhone.substring(3).trim();
    } else if (displayPhone.startsWith('0')) {
      displayPhone = displayPhone.substring(1).trim();
    }
    phoneController.text = displayPhone;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    if (_isEditing) {
      _resetControllers();
    }
    notifyListeners();
  }

  void saveProfile() {
    final fullNameText = fullNameController.text;
    _name = fullNameText.split(' ').first;
    _surname = fullNameText.contains(' ') ? fullNameText.split(' ').last : '';
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

    // --- Değişiklik Kontrolü ---
    final String newName = fullNameController.text.trim();
    final String newEmail = emailController.text.trim();

    // Telefonu temizle
    String cleanPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isNotEmpty && !cleanPhone.startsWith('90')) {
      cleanPhone = '90$cleanPhone';
    }
    if (cleanPhone.isNotEmpty && !cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }

    final bool isNameChanged = newName != (currentUser.name ?? '');
    final bool isEmailChanged = newEmail != (currentUser.email ?? '');

    // Mevcut telefonu da temizleyerek karşılaştır
    String currentPhoneClean = (currentUser.phoneNumber ?? '').replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (currentPhoneClean.isNotEmpty && !currentPhoneClean.startsWith('90')) {
      currentPhoneClean = '90$currentPhoneClean';
    }
    if (currentPhoneClean.isNotEmpty && !currentPhoneClean.startsWith('+')) {
      currentPhoneClean = '+$currentPhoneClean';
    }

    final bool isPhoneChanged = cleanPhone != currentPhoneClean;
    final bool isImageChanged = _selectedImageFile != null;

    if (kDebugMode) {
      print('--- Profile Change Debug ---');
      print(
        'Name: "$newName" vs "${currentUser.name}" (Changed: $isNameChanged)',
      );
      print(
        'Email: "$newEmail" vs "${currentUser.email}" (Changed: $isEmailChanged)',
      );
      print(
        'Phone: "$cleanPhone" vs "$currentPhoneClean" (Changed: $isPhoneChanged)',
      );
      print('Image Changed: $isImageChanged');
      print('----------------------------');
    }

    if (!isNameChanged &&
        !isEmailChanged &&
        !isPhoneChanged &&
        !isImageChanged) {
      if (context.mounted) {
        ErrorDialogCustom.show(
          context,
          title: LocaleKeys.common_warning.tr(),
          message: LocaleKeys.common_profileNoChange.tr(),
        );
      }
      return;
    }

    final int? userId = int.tryParse(currentUser.id);
    if (userId == null) {
      if (context.mounted) {
        ErrorDialogCustom.show(context, message: LocaleKeys.common_invalidUserId.tr());
      }
      return;
    }

    // Seçilen fotoğrafı önce yükle
    String? imageUrl = currentUser.imageUrl;
    if (_selectedImageFile != null) {
      debugPrint('--- [DEBUG] New image selected, uploading to server... ---');
      final uploadedUrl = await _authService.uploadImage(
        _selectedImageFile!.path,
      );

      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
        debugPrint('--- [DEBUG] Image upload success: $imageUrl ---');
      } else {
        debugPrint(
          '--- [DEBUG] Image upload failed, continuing with old image or no image ---',
        );
      }
    }

    final Map<String, dynamic> updateData = {
      'name': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': cleanPhone,
      if (imageUrl != null) 'image_url': imageUrl,
    };

    final response = await _authService.updateProfile(userId, updateData);

    if (context.mounted) {
      if (response.success) {
        SuccessDialogCustom.show(
          context,
          message: response.message,
          onConfirm: () {
            if (response.user != null) {
              _userSession.setUser(response.user!);
              _remoteImageUrl = response.user!.imageUrl;
            }

            _selectedImageFile = null;
            _isEditing = false;
            _resetControllers();
            notifyListeners();
            Navigator.pop(context);
          },
        );
      } else {
        ErrorDialogCustom.show(context, message: response.message);
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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Lottie.asset(
                    'assets/lottie/account_delete.json',
                    width: 80,
                    height: 90,
                    repeat: true,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Hesabı Sil',
                      style: CustomTextStyles.orelegaOne30Primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                style: CustomTextStyles.semiBold16Grey,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Hayır',
                      style: CustomTextStyles.semiBold16Grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx); // Dialogu kapat

                      // API üzerinden hesabı sil
                      final response = await _authService.deleteAccount();

                      if (context.mounted) {
                        if (response.success) {
                          SuccessDialogCustom.show(
                            context,
                            message: response.message,
                            onConfirm: () {
                              _userSession.clear();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            },
                          );
                        } else {
                          ErrorDialogCustom.show(
                            context,
                            message: response.message,
                          );
                        }
                      }
                    },
                    child: Text(
                      'Evet',
                      style: CustomTextStyles.semiBold16Grey.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
