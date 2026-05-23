import 'package:flutter/material.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/error_dialog_custom.dart';
import '../../widgets/common/success_dialog_custom.dart';
import 'package:lottie/lottie.dart';

class VolunteerProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;
  bool _isDisposed = false;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Profile Data ──────────────────────────────────
  String get fullName => _userSession.currentUser?.name ?? '';
  String get email =>
      _userSession.currentUser?.email ?? '';
  String? get remoteImageUrl => _userSession.currentUser?.imageUrl;

  VolunteerProfileViewModel(this._authService, this._userSession) {
    Future.microtask(() => fetchProfile());
  }

  @override
  void dispose() {
    _isDisposed = true;
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

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _userSession.setUser(user);
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    // API çağrısını arka planda başlatıyoruz, cevabı beklemiyoruz (yavaşlığı engellemek için)
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
}
