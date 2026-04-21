import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';

/// Business sipariş ekleme ekranının ViewModel'i.
class BusinessAddOrderViewModel extends ChangeNotifier {
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

  bool get hasLocation => _selectedLatLng != null;

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
        _locationAddress = address ??
            '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        notifyListeners();
      }
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
  String _price = '100';
  String get price => _price;

  void onPriceChanged(String value) {
    _price = value;
  }

  // ─── Gönderme ─────────────────────────────────────────
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit() async {
    _errorMessage = null;
    if (!hasLocation) {
      _errorMessage = 'errorNoLocation';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}
