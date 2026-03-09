import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';

/// Volunteer ilan ekleme ekranının ViewModel'i.
class VolunteerAddListingViewModel extends ChangeNotifier {
  VolunteerAddListingViewModel();

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

  Future<void> pickLocation(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.mapPicker,
      arguments: {
        'accentColor': AppColors.volunteerColor,
        'accentGradient': AppColors.volunteerBackgroundGradient,
      },
    );
    if (result is LatLng) {
      _selectedLatLng = result;
      _locationAddress =
          '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
      notifyListeners();
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
    if (!hasLocation) {
      _errorMessage = 'errorNoLocation';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _isSubmitting = false;
    _isSuccess = true;
    notifyListeners();
    return true;
  }

  void resetSuccess() {
    _isSuccess = false;
    notifyListeners();
  }
}
