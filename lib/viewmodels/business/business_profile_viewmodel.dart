import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/error_dialog_custom.dart';
import '../../widgets/common/success_dialog_custom.dart';
import 'package:lottie/lottie.dart';
import '../../models/auth/user_model.dart';

class BusinessProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;
  bool _isDisposed = false;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  // ─── Profil Verileri ──────────────────────────────────
  File? _selectedImageFile;
  String? _remoteImageUrl;

  File? get selectedImageFile => _selectedImageFile;
  String? get remoteImageUrl => _remoteImageUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String get fullName => _userSession.currentUser?.name ?? '';
  String get email => _userSession.currentUser?.email ?? '';
  String? get imageUrl => _userSession.currentUser?.imageUrl;

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  int _mealsSaved = 0;
  double _totalRevenue = 0.0;

  int get dailySoldCount => _mealsSaved;
  String get dailyTotalEarnings => "${_totalRevenue.toStringAsFixed(0)} TL";

  BusinessProfileViewModel(this._authService, this._userSession)
    : fullNameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController() {
    _remoteImageUrl = _userSession.currentUser?.imageUrl;
    _resetControllers();
    Future.microtask(() => fetchProfile());
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _authService.getProfile(),
        _authService.getBusinessDashboardStats(),
      ]);

      final user = results[0] as UserModel?;
      if (user != null) {
        _userSession.setUser(user);
        _resetControllers();
      }

      final stats = results[1] as Map<String, dynamic>?;
      if (stats != null && stats['summary'] != null) {
        final summary = stats['summary'];
        _mealsSaved = (summary['meals_saved'] as num?)?.toInt() ?? 0;
        _totalRevenue = (summary['total_revenue'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      debugPrint('Fetch profile/stats error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _resetControllers() {
    fullNameController.text = fullName;
    emailController.text = email;

    // Telefon numarasını temizleyerek göster (maske ile uyumlu olması için)
    String displayPhone = _userSession.currentUser?.phoneNumber ?? '';
    if (displayPhone.startsWith('+90')) {
      displayPhone = displayPhone.substring(3).trim();
    } else if (displayPhone.startsWith('0')) {
      displayPhone = displayPhone.substring(1).trim();
    }
    phoneController.text = displayPhone;
  }

  @override
  void dispose() {
    _isDisposed = true;
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(Duration.zero, () {
        if (!_isDisposed) super.notifyListeners();
      });
    });
    WidgetsBinding.instance.scheduleFrame();
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

    final String newName = fullNameController.text.trim();
    final String newEmail = emailController.text.trim();

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
    if (userId == null) return;

    _isUpdating = true;
    notifyListeners();

    try {
      String? imageUrl = currentUser.imageUrl;
      if (_selectedImageFile != null) {
        final uploadedUrl = await _authService.uploadImage(
          _selectedImageFile!.path,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final Map<String, dynamic> updateData = {
        'name': newName,
        'email': newEmail,
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
              _resetControllers();
              notifyListeners();
              Navigator.pop(context);
            },
          );
        } else {
          ErrorDialogCustom.show(context, message: response.message);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorDialogCustom.show(context, message: e.toString());
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _authService.logout().then<void>(
      (_) {},
      onError: (Object e, StackTrace _) {
        debugPrint('Logout API error: $e');
      },
    );

    _userSession.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    });
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
                children: [
                  Lottie.asset(
                    'assets/lottie/account_delete.json',
                    width: 50,
                    height: 50,
                    repeat: true,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Hesabı Sil',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600, // Semibold
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Hayır',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);

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
                    child: const Text(
                      'Evet',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
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
