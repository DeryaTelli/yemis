import 'package:flutter/material.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/i_auth_service.dart';

class FoodAddAddressViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final AddressModel? initialAddress;

  FoodAddAddressViewModel({
    required IAuthService authService,
    this.initialAddress,
    String? defaultPhone,
  }) : _authService = authService {
    if (initialAddress != null) {
      // Düzenleme modu: Mevcut bilgileri yükle
      baslikController.text = initialAddress!.label;
      // Adres satırını parçalamak zor olabilir (İl/İlçe/Mahalle formatında değilse)
      // Şimdilik sadece açık adres kısmına yazıyoruz veya manuel giriyoruz
      adresController.text = initialAddress!.addressLine;
      phoneController.text = defaultPhone ?? '';
    } else {
      // Yeni adres modu: Telefonu default set et
      phoneController.text = defaultPhone ?? '';
    }
  }

  final TextEditingController adresController = TextEditingController();
  final TextEditingController baslikController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedIl;
  String? selectedIlce;
  String? selectedMahalle;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isEditMode => initialAddress != null;

  List<String> get iller => _data.keys.toList()..sort();

  List<String> get ilceler {
    if (selectedIl == null) return [];
    return _data[selectedIl]?.keys.toList() ?? []..sort();
  }

  List<String> get mahalleler {
    if (selectedIl == null || selectedIlce == null) return [];
    return _data[selectedIl]?[selectedIlce]?.toList() ?? []..sort();
  }

  void selectIl(String? il) {
    if (selectedIl == il) return;
    selectedIl = il;
    selectedIlce = null;
    selectedMahalle = null;
    notifyListeners();
  }

  void selectIlce(String? ilce) {
    if (selectedIlce == ilce) return;
    selectedIlce = ilce;
    selectedMahalle = null;
    notifyListeners();
  }

  void selectMahalle(String? mahalle) {
    if (selectedMahalle == mahalle) return;
    selectedMahalle = mahalle;
    notifyListeners();
  }

  String get formattedAddress {
    final parts = [
      if (selectedIl != null) selectedIl!,
      if (selectedIlce != null) selectedIlce!,
      if (selectedMahalle != null) selectedMahalle!,
      if (adresController.text.trim().isNotEmpty) adresController.text.trim(),
    ];
    // Eğer düzenleme modundaysa ve il seçilmemişse direkt controller'dakini kullan
    if (isEditMode && selectedIl == null) return adresController.text;
    
    return parts.join(' / ');
  }

  Future<bool> saveAddress() async {
    if (adresController.text.isEmpty || phoneController.text.isEmpty) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final addressData = AddressModel(
        id: initialAddress?.id ?? 0,
        userId: initialAddress?.userId ?? 0,
        label: baslikController.text.isEmpty ? 'Ev' : baslikController.text,
        addressLine: formattedAddress,
        latitude: initialAddress?.latitude ?? 0,
        longitude: initialAddress?.longitude ?? 0,
        isDefault: initialAddress?.isDefault ?? true,
      );

      if (isEditMode) {
        // API'de UPDATE endpoint'i varsa o çağrılacak. 
        // Şimdilik tekrar create ederek güncellediğini varsayıyoruz veya mock'luyoruz.
        return await _authService.createAddress(addressData);
      } else {
        return await _authService.createAddress(addressData);
      }
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    adresController.dispose();
    baslikController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  static const Map<String, Map<String, List<String>>> _data = {
    'İstanbul': {
      'Kadıköy': ['Moda Mah.', 'Caferağa Mah.', 'Fenerbahçe Mah.'],
      'Beşiktaş': ['Sinanpaşa Mah.', 'Etiler Mah.', 'Levent Mah.'],
    },
    'Ankara': {
      'Çankaya': ['Kavaklıdere Mah.', 'Kızılay Mah.', 'Çukurambar Mah.'],
      'Keçiören': ['Etlik Mah.', 'Kalaba Mah.'],
    },
    'Karabük': {
      'Merkez': ['Yenişehir Mah.', 'Cumhuriyet Mah.', 'Beşpınar Mah.'],
      'Safranbolu': ['Çarşı Mah.', 'Bağlar Mah.'],
    },
  };
}
