import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../models/app_module_type.dart';

/// Business sipariş ekleme ekranının ViewModel'i.
class BusinessAddOrderViewModel extends ChangeNotifier {
  final IAuthService? _authService;
  final IBusinessService? _businessService;

  BusinessAddOrderViewModel({
    IAuthService? authService,
    IBusinessService? businessService,
  })  : _authService = authService,
        _businessService = businessService;

  // ─── Kayıtlı Adresler ─────────────────────────────────
  List<AddressModel> _savedAddresses = [];
  List<AddressModel> get savedAddresses => _savedAddresses;

  int? _selectedAddressId;
  int? get selectedAddressId => _selectedAddressId;

  Future<void> fetchAddresses() async {
    if (_authService == null) return;
    _savedAddresses = await _authService!.getAddresses();
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _selectedAddressId = address.id;
    _selectedLatLng = LatLng(address.latitude, address.longitude);
    _locationAddress = address.addressLine;
    if (address.label.isNotEmpty) {
      _locationAddress = '${address.label}: ${address.addressLine}';
    }
    notifyListeners();
  }

  void setLocationAddress(String address) {
    _locationAddress = address;
    _selectedLatLng = null;
    _selectedAddressId = null;
    notifyListeners();
  }

  // ─── Nav ──────────────────────────────────────────────
  int _selectedIndex = 3;
  int get selectedIndex => _selectedIndex;

  void onTabSelected(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  // ─── Fotoğraf ─────────────────────────────────────────
  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;
  bool get hasImage => _selectedImage != null;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickFromCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  // ─── Bitiş Saati ──────────────────────────────────────
  int _selectedHour = 5;
  int get selectedHour => _selectedHour;

  int _selectedMinute = 41;
  int get selectedMinute => _selectedMinute;

  bool _isAm = true;
  bool get isAm => _isAm;

  void onHourChanged(int index) {
    _selectedHour = index + 1;
    notifyListeners();
  }

  void onMinuteChanged(int index) {
    _selectedMinute = index;
    notifyListeners();
  }

  void setAmPm(int index) {
    final newIsAm = index == 0;
    if (_isAm != newIsAm) {
      _isAm = newIsAm;
      notifyListeners();
    }
  }

  // ─── Konum ────────────────────────────────────────────
  LatLng? _selectedLatLng;
  LatLng? get selectedLatLng => _selectedLatLng;

  String _locationAddress = '';
  String get locationAddress => _locationAddress;

  bool get hasLocation => _selectedLatLng != null || _selectedAddressId != null;

  Future<void> pickLocation(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.mapPicker,
      arguments: {
        'accentColor': AppColors.primaryColor,
        'accentGradient': AppColors.primaryButtonGradient,
      },
    );
    if (result is Map<String, dynamic>) {
      final latLng = result['latLng'] as LatLng?;
      final address = result['address'] as String?;
      if (latLng != null) {
        _selectedLatLng = latLng;
        _selectedAddressId = null; // Manuel seçimde addressId null olur (veya yeni adres oluşturulmalı)
        _locationAddress = address ??
            '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        notifyListeners();
      }
    }
  }

  Future<void> addNewAddress(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.foodAddAddress,
      arguments: {'moduleType': AppModuleType.business},
    );
    if (result != null && result is AddressModel) {
      selectAddress(result);
    }
  }

  // ─── İlan Sayısı ──────────────────────────────────────
  int _quantity = 1;
  int get quantity => _quantity;

  void incrementQuantity() {
    _quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  // ─── Fiyat ────────────────────────────────────────────
  String _price = '';
  String get price => _price;

  void onPriceChanged(String value) {
    _price = value;
    notifyListeners();
  }

  // ─── İndirim Fiyatı ───────────────────────────────────
  String _discountPrice = '';
  String get discountPrice => _discountPrice;

  void onDiscountPriceChanged(String value) {
    _discountPrice = value;
    notifyListeners();
  }

  // ─── Başlık ───────────────────────────────────────────
  String _title = '';
  String get title => _title;

  void onTitleChanged(String value) {
    _title = value;
    notifyListeners();
  }

  // ─── Alerjenler ───────────────────────────────────────
  String _allergens = '';
  String get allergens => _allergens;

  void onAllergensChanged(String value) {
    _allergens = value;
    notifyListeners();
  }

  // ─── Açıklama ─────────────────────────────────────────
  String _description = '';
  String get description => _description;

  void onDescriptionChanged(String value) {
    _description = value;
    notifyListeners();
  }

  // ─── Kategori ─────────────────────────────────────────
  final List<String> _categories = ['yemek', 'patiseri', 'market'];
  List<String> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  void onCategoryChanged(String? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  // ─── Gönderme ─────────────────────────────────────────
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit() async {
    _errorMessage = null;
    
    if (_title.trim().isEmpty) {
      _errorMessage = 'Lütfen bir başlık girin.';
      notifyListeners();
      return false;
    }

    if (_selectedCategory == null) {
      _errorMessage = 'Lütfen bir kategori seçin.';
      notifyListeners();
      return false;
    }

    if (!hasLocation) {
      _errorMessage = 'errorNoLocation';
      notifyListeners();
      return false;
    }

    if (_businessService == null || _authService == null) {
      _errorMessage = 'Servis bağlantısı kurulamadı.';
      notifyListeners();
      return false;
    }
    
    _isSubmitting = true;
    notifyListeners();

    // --- Geocode Fallback ---
    // Eğer koordinatlar yoksa veya (0,0) ise adresten bulmaya çalış
    if (_selectedLatLng == null || (_selectedLatLng!.latitude == 0 && _selectedLatLng!.longitude == 0)) {
      try {
        debugPrint('🔍 [BusinessAddOrder] Koordinat eksik, geocode deneniyor: $_locationAddress');
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': _locationAddress,
          'format': 'json',
          'limit': '1',
          'accept-language': 'tr',
        });
        final res = await http.get(uri, headers: {'User-Agent': 'YemisApp/1.0'});
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          if (data.isNotEmpty) {
            _selectedLatLng = LatLng(
              double.parse(data[0]['lat']),
              double.parse(data[0]['lon']),
            );
            debugPrint('✅ [BusinessAddOrder] Geocode başarılı: $_selectedLatLng');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [BusinessAddOrder] Geocode hatası: $e');
      }
    }

    try {
      // 1. Fotoğraf varsa yükle
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _authService!.uploadImage(_selectedImage!.path);
      }

      // 2. Zamanları ayarla
      final now = DateTime.now();
      final pickupStartTime = now.toIso8601String();
      
      // Bitiş saati için bugünün tarihini ve seçilen saati kullan
      int hour = _isAm ? (_selectedHour == 12 ? 0 : _selectedHour) : (_selectedHour == 12 ? 12 : _selectedHour + 12);
      final pickupEndTime = DateTime(now.year, now.month, now.day, hour, _selectedMinute).toIso8601String();

      // 3. Veriyi hazırla
      final bagData = {
        'title': _title,
        'description': _description,
        'address_id': _selectedAddressId,
        'address': _locationAddress,
        'latitude': _selectedLatLng?.latitude,
        'longitude': _selectedLatLng?.longitude,
        'original_price': double.tryParse(_price) ?? 0.0,
        'discounted_price': double.tryParse(_discountPrice) ?? 0.0,
        'pickup_start_time': pickupStartTime,
        'pickup_end_time': pickupEndTime,
        'total_quantity': _quantity,
        'available_quantity': _quantity,
        'image_url': imageUrl ?? '',
        'allergens': _allergens,
        'category': _selectedCategory,
      };

      // 4. API isteği
      final success = await _businessService!.createBag(bagData);
      
      if (success) {
        debugPrint('✅ [BusinessAddOrder] Sipariş başarıyla yüklendi!');
        clearForm();
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sipariş eklenirken bir hata oluştu.';
      }
    } catch (e) {
      _errorMessage = 'Beklenmedik bir hata oluştu: $e';
    }
    
    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  void clearForm() {
    _title = '';
    _selectedImage = null;
    _selectedHour = 5;
    _selectedMinute = 41;
    _isAm = true;
    _selectedLatLng = null;
    _selectedAddressId = null;
    _locationAddress = '';
    _quantity = 1;
    _price = '';
    _discountPrice = '';
    _description = '';
    _allergens = '';
    _selectedCategory = null;
    _errorMessage = null;
  }
}
