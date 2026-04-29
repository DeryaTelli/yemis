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
    debugPrint('🗑️ [AddressesViewModel] Adres silme işlemi başlatıldı. ID: $id');
    
    // Dismissible hatasını önlemek için önce yerel listeden hemen çıkarıyoruz
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final removedAddress = _addresses.removeAt(index);
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.deleteAddress(id);
      if (success) {
        debugPrint('✅ [AddressesViewModel] Adres başarıyla silindi: ${removedAddress.label}');
      } else {
        debugPrint('❌ [AddressesViewModel] Adres silme başarısız (API hatası). Geri ekleniyor...');
        // Hata durumunda (opsiyonel) listeye geri ekleyebilirsiniz:
        // _addresses.insert(index, removedAddress);
      }
    } catch (e) {
      debugPrint('❌ [AddressesViewModel] Adres silme sırasında istisna oluştu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
