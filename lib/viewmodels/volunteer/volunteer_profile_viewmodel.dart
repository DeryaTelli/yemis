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
  String _name = 'Derya';
  String _surname = 'Telli';
  String _email = '2002derya2002@gmail.com';

  String get name => _name;
  String get surname => _surname;
  String get email => _email;

  VolunteerProfileViewModel(this._authService, this._userSession) {
    _name = _userSession.currentUser?.name.split(' ').first ?? _name;
    _surname = (_userSession.currentUser?.name.contains(' ') ?? false)
        ? _userSession.currentUser!.name.split(' ').last
        : _surname;
    _email = _userSession.currentUser?.email ?? _email;
  }

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logout();
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
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
