import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../models/auth/address_model.dart';
import '../../models/business/business_listing_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../models/app_module_type.dart';

class BusinessEditOrderViewModel extends ChangeNotifier {
  final IAuthService? _authService;
  final IBusinessService? _businessService;
  final BusinessListingModel initialListing;

  BusinessEditOrderViewModel({
    IAuthService? authService,
    IBusinessService? businessService,
    required this.initialListing,
  }) : _authService = authService,
       _businessService = businessService {
    _initFromInitial();
  }

  void _initFromInitial() {
    _title = initialListing.title;
    _description = initialListing.description ?? '';
    _price = initialListing.originalPrice.toString();
    _discountPrice = initialListing.discountedPrice.toString();
    _quantity = initialListing.totalQuantity;
    _allergens = initialListing.allergens ?? '';
    _locationAddress = initialListing.address ?? '';
    _selectedAddressId = initialListing.addressId;
    _selectedCategory = initialListing.category;

    // Zamanları ayır
    if (initialListing.pickupEndTime != null) {
      final endTime = initialListing.pickupEndTime!;
      _selectedHour = endTime.hour;
      _selectedMinute = endTime.minute;
    }

    if (initialListing.latitude != null && initialListing.longitude != null) {
      _selectedLatLng = LatLng(initialListing.latitude!, initialListing.longitude!);
    }

    notifyListeners();
  }

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

  // ─── Fotoğraf ─────────────────────────────────────────
  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;
  bool get hasImage =>
      _selectedImage != null || initialListing.imageUrl != null;

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
  int _selectedHour = 12;
  int get selectedHour => _selectedHour;
  int _selectedMinute = 0;
  int get selectedMinute => _selectedMinute;

  void onHourChanged(int index) {
    _selectedHour = index;
    notifyListeners();
  }

  void onMinuteChanged(int index) {
    _selectedMinute = index;
    notifyListeners();
  }

  void setAmPm(int index) {
    // 24h format.
  }

  // ─── Konum ────────────────────────────────────────────
  LatLng? _selectedLatLng;
  LatLng? get selectedLatLng => _selectedLatLng;
  String _locationAddress = '';
  String get locationAddress => _locationAddress;
  bool get hasLocation =>
      _selectedLatLng != null ||
      _selectedAddressId != null ||
      _locationAddress.isNotEmpty;

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
        _selectedAddressId = null;
        _locationAddress =
            address ??
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

  String _discountPrice = '';
  String get discountPrice => _discountPrice;
  void onDiscountPriceChanged(String value) {
    _discountPrice = value;
    notifyListeners();
  }

  // ─── Başlık/Detay ─────────────────────────────────────
  String _title = '';
  String get title => _title;
  void onTitleChanged(String value) {
    _title = value;
    notifyListeners();
  }

  String _allergens = '';
  String get allergens => _allergens;
  void onAllergensChanged(String value) {
    _allergens = value;
    notifyListeners();
  }

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
    if (!hasLocation) {
      _errorMessage = 'Lütfen konum seçin.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    // --- Geocode Fallback ---
    // Eğer koordinatlar yoksa veya (0,0) ise adresten bulmaya çalış
    bool needsGeocode = _selectedLatLng == null || (_selectedLatLng!.latitude == 0 && _selectedLatLng!.longitude == 0);
    // Eğer başlangıç koordinatları da (0,0) ise geocode yap
    if (needsGeocode && (initialListing.latitude == null || initialListing.latitude == 0)) {
      try {
        debugPrint('🔍 [BusinessEditOrder] Koordinat eksik, geocode deneniyor: $_locationAddress');
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
            debugPrint('✅ [BusinessEditOrder] Geocode başarılı: $_selectedLatLng');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [BusinessEditOrder] Geocode hatası: $e');
      }
    }

    try {
      String? imageUrl = initialListing.imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _authService!.uploadImage(_selectedImage!.path);
      }

      final now = DateTime.now();
      int hour = _selectedHour;
      final pickupEndTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        _selectedMinute,
      ).toIso8601String();

      final bagData = {
        'title': _title,
        'description': _description,
        'address_id': _selectedAddressId,
        'address': _locationAddress,
        'latitude': _selectedLatLng?.latitude ?? initialListing.latitude,
        'longitude': _selectedLatLng?.longitude ?? initialListing.longitude,
        'original_price': double.tryParse(_price) ?? 0.0,
        'discounted_price': double.tryParse(_discountPrice) ?? 0.0,
        'pickup_start_time': initialListing.pickupStartTime?.toIso8601String() ?? now.toIso8601String(),
        'pickup_end_time': pickupEndTime,
        'total_quantity': _quantity,
        'available_quantity': _quantity,
        'image_url': imageUrl ?? '',
        'allergens': _allergens,
        'category': _selectedCategory,
      };

      final success = await _businessService!.updateBag(
        initialListing.id,
        bagData,
      );
      if (success) {
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Güncelleme sırasında hata oluştu.';
      }
    } catch (e) {
      _errorMessage = 'Hata: $e';
    }
    _isSubmitting = false;
    notifyListeners();
    return false;
  }
}
