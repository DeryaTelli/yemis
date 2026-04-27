import 'package:flutter/material.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';

class AddressesViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final UserSession _userSession;

  AddressesViewModel({
    required IAuthService authService,
    required UserSession userSession,
  })  : _authService = authService,
        _userSession = userSession;

  List<AddressModel> _addresses = [];
  List<AddressModel> get addresses => _addresses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _addresses = await _authService.getAddresses();
    } catch (e) {
      debugPrint('Adres çekme hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(int id) async {
    // API'de silme endpoint'i eklenince burası güncellenecek
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
