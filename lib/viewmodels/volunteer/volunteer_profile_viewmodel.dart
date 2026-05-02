import 'package:flutter/material.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';

class VolunteerProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  int _selectedIndex = 4;
  int get selectedIndex => _selectedIndex;

  // ─── Profile Data ──────────────────────────────────
  String get name => _userSession.currentUser?.name.split(' ').first ?? 'Derya';
  String get surname => (_userSession.currentUser?.name.contains(' ') ?? false)
      ? _userSession.currentUser!.name.split(' ').last
      : 'Telli';
  String get email =>
      _userSession.currentUser?.email ?? '2002derya2002@gmail.com';
  String? get remoteImageUrl => _userSession.currentUser?.imageUrl;

  VolunteerProfileViewModel(this._authService, this._userSession);

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
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
