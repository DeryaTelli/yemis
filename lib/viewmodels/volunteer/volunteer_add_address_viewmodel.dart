import 'package:flutter/material.dart';
import '../../models/location/location_model.dart';
import '../../services/location/i_location_data_service.dart';

/// İl → İlçe → Mahalle hiyerarşik adres ViewModel'i.
class VolunteerAddAddressViewModel extends ChangeNotifier {
  final ILocationDataService _locationService;

  VolunteerAddAddressViewModel({
    required ILocationDataService locationService,
  }) : _locationService = locationService {
    _initLocations();
  }
  // ─── Controllers ────────────────────────────────
  final TextEditingController adresController = TextEditingController();
  final TextEditingController baslikController = TextEditingController();

  // ─── Seçili değerler ────────────────────────────
  String? selectedIl;
  String? selectedIlce;
  String? selectedMahalle;

  // ─── Veri ───────────────────────────────────────
  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _neighborhoods = [];

  /// İl listesi
  List<String> get iller => _provinces.map((e) => e.name).toList()..sort();

  /// Seçili ile göre ilçeler
  List<String> get ilceler => _districts.map((e) => e.name).toList()..sort();

  /// Seçili ilçeye göre mahalleler
  List<String> get mahalleler => _neighborhoods.map((e) => e.name).toList()..sort();

  Future<void> _initLocations() async {
    _provinces = await _locationService.getProvinces();
    notifyListeners();
  }

  // ─── Seçim işlemleri ────────────────────────────

  Future<void> selectIl(String? il) async {
    if (selectedIl == il) return;
    selectedIl = il;
    selectedIlce = null;
    selectedMahalle = null;
    _districts = [];
    _neighborhoods = [];
    notifyListeners();

    if (il != null) {
      final province = _provinces.firstWhere((p) => p.name == il, orElse: () => LocationModel(id: 0, name: ''));
      if (province.id != 0) {
        _districts = await _locationService.getDistricts(province.id);
        notifyListeners();
      }
    }
  }

  Future<void> selectIlce(String? ilce) async {
    if (selectedIlce == ilce) return;
    selectedIlce = ilce;
    selectedMahalle = null;
    _neighborhoods = [];
    notifyListeners();

    if (ilce != null) {
      final district = _districts.firstWhere((d) => d.name == ilce, orElse: () => LocationModel(id: 0, name: ''));
      if (district.id != 0) {
        _neighborhoods = await _locationService.getNeighborhoods(district.id);
        notifyListeners();
      }
    }
  }

  void selectMahalle(String? mahalle) {
    if (selectedMahalle == mahalle) return;
    selectedMahalle = mahalle;
    notifyListeners();
  }

  /// Form çıktısı: "İstanbul / Kadıköy / Moda Mah. — Açık Adres"
  String get formattedAddress {
    final parts = [
      if (selectedIl != null) selectedIl!,
      if (selectedIlce != null) selectedIlce!,
      if (selectedMahalle != null) selectedMahalle!,
      if (adresController.text.trim().isNotEmpty) adresController.text.trim(),
    ];
    return parts.join(' / ');
  }

  bool get isValid =>
      selectedIl != null &&
      selectedIlce != null &&
      selectedMahalle != null &&
      adresController.text.trim().isNotEmpty;

  @override
  void dispose() {
    adresController.dispose();
    baslikController.dispose();
    super.dispose();
  }
}
