import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:yemis/services/volunteer/i_volunteer_service.dart';
import '../../models/auth/address_model.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/auth/i_auth_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';

/// Volunteer ilan düzenleme ekranının ViewModel'i.
class VolunteerEditListingViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IVolunteerService _volunteerService;
  final VolunteerListing initialListing;

  VolunteerEditListingViewModel(
    this._authService,
    this._volunteerService,
    this.initialListing,
  ) {
    _initData();
  }

  void _initData() {
    _title = initialListing.title;
    _description = initialListing.description ?? '';
    _locationAddress = initialListing.location;
    if (initialListing.latitude != null && initialListing.longitude != null) {
      _selectedLatLng = LatLng(
        initialListing.latitude!,
        initialListing.longitude!,
      );
    }
    _existingImageUrl = initialListing.imageUrl;

    // Zaman ayarları (Basitçe parse edelim veya varsayılan bırakalım)
    // initialListing.timeRange: "Bugün Al 15.30-19.00" gibi gelebiliyor mockta.
    // Gerçek API'da ISO string gelirse daha kolay olur.
    // Şimdilik varsayılan bırakalım veya basit bir kontrol yapalım.
  }

  // ─── İlan Bilgileri ───────────────────────────────────
  String _title = '';
  String get title => _title;

  String _description = '';
  String get description => _description;

  String? _existingImageUrl;
  String? get existingImageUrl => _existingImageUrl;

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
    if (address.label.isNotEmpty) {
      _locationAddress = '${address.label}: ${address.addressLine}';
    }
    notifyListeners();
  }

  // ─── Fotoğraf ─────────────────────────────────────────

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;
  bool get hasNewImage => _selectedImage != null;

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
        _existingImageUrl = null;
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
        _existingImageUrl = null;
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

  bool get hasLocation => _selectedLatLng != null;

  void setLocationAddress(String address) {
    _locationAddress = address;
    _selectedLatLng = null;
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

  // ─── Gönderme ─────────────────────────────────────────

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  Future<bool> update() async {
    _errorMessage = null;
    if (_title.isEmpty || _description.isEmpty) {
      _errorMessage = 'Lütfen başlık ve açıklama giriniz.';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    notifyListeners();

    try {
      String? imageUrl = _existingImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _authService.uploadImage(_selectedImage!.path);
      }

      int hour = _selectedHour;

      final now = DateTime.now();
      final pickupEndTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        _selectedMinute,
      );
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
        'image_url': imageUrl ?? '',
        'pickup_start_time': now.toIso8601String(),
        'pickup_end_time': finalPickupEndTime.toIso8601String(),
        'is_available': true,
        'delivery_status': 'active',
      };

      final success = await _volunteerService.updateMeal(
        int.parse(initialListing.id),
        data,
      );

      if (success) {
        _isSuccess = true;
      } else {
        _errorMessage = 'İlan güncellenirken bir hata oluştu.';
      }
    } catch (e) {
      _errorMessage = 'Sistemsel bir hata oluştu: $e';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
    return _isSuccess;
  }
}
