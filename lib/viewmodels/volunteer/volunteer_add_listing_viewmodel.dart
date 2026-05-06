import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';

/// Volunteer ilan ekleme ekranının ViewModel'i.
class VolunteerAddListingViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IVolunteerService _volunteerService;

  VolunteerAddListingViewModel(this._authService, this._volunteerService);

  // ─── İlan Bilgileri ───────────────────────────────────
  String _title = '';
  String get title => _title;

  String _description = '';
  String get description => _description;

  void onTitleChanged(String value) {
    _title = value;
    notifyListeners();
  }

  void onDescriptionChanged(String value) {
    _description = value;
    notifyListeners();
  }

  // ─── Kayıtlı Adresler ─────────────────────────────────
  List<AddressModel> _savedAddresses = [];
  List<AddressModel> get savedAddresses => _savedAddresses;

  Future<void> fetchAddresses() async {
    _savedAddresses = await _authService.getAddresses();
    notifyListeners();
  }

  int? _selectedAddressId;
  int? get selectedAddressId => _selectedAddressId;

  void selectAddress(AddressModel address) {
    _selectedAddressId = address.id;
    _selectedLatLng = LatLng(address.latitude, address.longitude);
    _locationAddress = address.addressLine;
    // Eğer etiket varsa onu da ekleyebiliriz (Figma'daki gibi)
    if (address.label.isNotEmpty) {
      _locationAddress = '${address.label}: ${address.addressLine}';
    }
    notifyListeners();
  }

  // ─── Nav State ────────────────────────────────────────

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

  /// Kameradan fotoğraf çeker.
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

  /// Galeriden fotoğraf seçer.
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

  bool get hasLocation => _selectedLatLng != null;

  void setLocationAddress(String address) {
    _locationAddress = address;
    _selectedLatLng =
        null; // Manuel adres girildiyse koordinatı sıfırla (veya sonradan ekle)
    notifyListeners();
  }

  Future<void> pickLocation(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.mapPicker,
      arguments: {
        'accentColor': AppColors.volunteerColor,
        'accentGradient': AppColors.volunteerBackgroundGradient,
      },
    );
    if (result is Map<String, dynamic>) {
      final latLng = result['latLng'] as LatLng?;
      final address = result['address'] as String?;
      if (latLng != null) {
        _selectedLatLng = latLng;
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
      AppRoutes.volunteerAddAddress,
    );
    if (result != null && result is String) {
      setLocationAddress(result);
    }
  }

  // ─── Fiyat ────────────────────────────────────────────

  final bool isFree = true;

  // ─── Gönderme ─────────────────────────────────────────

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  Future<bool> submit() async {
    _errorMessage = null;
    if (_title.isEmpty || _description.isEmpty) {
      _errorMessage = 'Lütfen başlık ve açıklama giriniz.';
      notifyListeners();
      return false;
    }
    if (!hasLocation) {
      _errorMessage = 'errorNoLocation';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    notifyListeners();

    try {
      // 1. Resim varsa yükle
      String? imageUrl;
      if (_selectedImage != null) {
        debugPrint('--- [DEBUG] Uploading image: ${_selectedImage!.path} ---');
        imageUrl = await _authService.uploadImage(_selectedImage!.path);
        debugPrint('--- [DEBUG] Image upload result: $imageUrl ---');
      }

      // Saat hesaplama
      int hour = _selectedHour;
      if (!_isAm && hour < 12) hour += 12;
      if (_isAm && hour == 12) hour = 0;

      final now = DateTime.now();
      final pickupEndTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        _selectedMinute,
      );

      // Eğer seçilen saat şu andan önceyse yarına ayarla
      final finalPickupEndTime = pickupEndTime.isBefore(now)
          ? pickupEndTime.add(const Duration(days: 1))
          : pickupEndTime;

      final data = {
        'title': _title,
        'description': _description,
        'address_id': _selectedAddressId,
        'address_line': _locationAddress,
        'latitude': _selectedLatLng?.latitude,
        'longitude': _selectedLatLng?.longitude,
        if (imageUrl != null) 'image_url': imageUrl,
        'pickup_start_time': now.toUtc().toIso8601String(),
        'pickup_end_time': finalPickupEndTime.toUtc().toIso8601String(),
        'is_available': true,
        'delivery_status': 'active',
      };

      if (kDebugMode) {
        print('--- [DEBUG] VOLUNTEER LISTING PAYLOAD ---');
        print(const JsonEncoder.withIndent('  ').convert(data));
        print('-----------------------------------------');
      }

      final success = await _volunteerService.createMeal(data);

      if (success) {
        _isSuccess = true;
        resetFields();
      } else {
        _errorMessage =
            'İlan oluşturulurken bir hata oluştu. Lütfen bilgileri kontrol edip tekrar deneyin.';
        debugPrint('Submit failed: createMeal returned false');
      }
    } catch (e) {
      _errorMessage = 'Sistemsel bir hata oluştu: $e';
      debugPrint('Submit error: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return _isSuccess;
  }

  void resetFields() {
    _title = '';
    _description = '';
    _selectedImage = null;
    _locationAddress = '';
    _selectedLatLng = null;
    notifyListeners();
  }

  void resetSuccess() {
    _isSuccess = false;
    notifyListeners();
  }
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
