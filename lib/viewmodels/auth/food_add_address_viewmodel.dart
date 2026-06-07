import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/auth/address_model.dart';
import '../../models/location/location_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/location/i_location_data_service.dart';
import '../../utils/constants/api_constants.dart';

class FoodAddAddressViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final ILocationDataService _locationService;
  final AddressModel? initialAddress;

  bool _isDisposed = false;

  FoodAddAddressViewModel({
    required IAuthService authService,
    required ILocationDataService locationService,
    this.initialAddress,
  })  : _authService = authService,
        _locationService = locationService {
    _init();
  }

  Future<void> _init() async {
    await _initLocations();
    if (initialAddress != null) {
      baslikController.text = initialAddress!.label;

      // Önce API'den gelen yapısal alanları dene
      final hasCityData = (initialAddress!.city?.isNotEmpty ?? false) &&
          (initialAddress!.district?.isNotEmpty ?? false);

      if (hasCityData) {
        await _setFromStructuredFields(
          city: initialAddress!.city!,
          district: initialAddress!.district!,
          neighborhood: initialAddress!.neighborhood,
          addressLine: initialAddress!.addressLine,
        );
      } else {
        // Geriye dönük uyumluluk: addressLine'ı parçala
        await _parseAndSetAddress(initialAddress!.addressLine);
      }
    }
    if (initialAddress != null) {
      _latitude = initialAddress!.latitude;
      _longitude = initialAddress!.longitude;
    }
    notifyListeners();
  }

  /// API'den gelen city/district/neighborhood alanlarını direkt kullanır.
  Future<void> _setFromStructuredFields({
    required String city,
    required String district,
    String? neighborhood,
    required String addressLine,
  }) async {
    // 1. İl seç — ilçe listesi yüklenir
    await selectIl(city);

    // 2. İlçe seç (büyük/küçük harf duyarsız eşleştirme)
    final String matchedIlce = _findInList(ilceler, district);
    if (matchedIlce.isNotEmpty) {
      // selectIlce zaten _neighborhoods'u async yükler ve bekler
      await selectIlce(matchedIlce);
    }

    // 3. Mahalle seç — selectIlce döndükten sonra _neighborhoods doludur
    if (neighborhood != null && neighborhood.isNotEmpty) {
      final String matchedMahalle = _findInList(mahalleler, neighborhood);
      if (matchedMahalle.isNotEmpty) {
        selectMahalle(matchedMahalle);
      } else {
        debugPrint('⚠️ [FoodAddressVM] Mahalle listede bulunamadı: "$neighborhood"');
        debugPrint('   Mevcut mahalleler: ${mahalleler.take(5).toList()}');
      }
    }

    // 4. Serbest adres metnini doldur
    final parts = addressLine.split(' / ');
    final remainder = parts.length >= 3 ? parts.sublist(parts.length > 3 ? 3 : 0).join(' / ') : addressLine;
    adresController.text = remainder.isEmpty ? addressLine : remainder;

    debugPrint('✅ [FoodAddressVM] Form dolduruldu:');
    debugPrint('   İl=$city | İlçe=$district | Mahalle=$neighborhood');
    debugPrint('   Adres=$remainder');
  }

  /// Listede büyük/küçük harf ve Türkçe karakter toleranslı arama.
  String _findInList(List<String> list, String value) {
    if (list.isEmpty || value.isEmpty) return '';
    // 1. Tam eşleşme
    final exact = list.firstWhere(
      (e) => e == value,
      orElse: () => '',
    );
    if (exact.isNotEmpty) return exact;

    // 2. Küçük harf eşleşmesi
    final lower = list.firstWhere(
      (e) => e.toLowerCase() == value.toLowerCase(),
      orElse: () => '',
    );
    if (lower.isNotEmpty) return lower;

    // 3. İçerik tabanlı eşleşme (kısmi)
    return list.firstWhere(
      (e) => e.toLowerCase().contains(value.toLowerCase()) ||
             value.toLowerCase().contains(e.toLowerCase()),
      orElse: () => '',
    );
  }


  Future<void> _parseAndSetAddress(String addressLine) async {
    // Örn: "Adana / Ceyhan / Altıgözbekirli / Bazı Sokaklar..."
    final parts = addressLine.split(' / ');
    
    if (parts.length >= 3) {
      final il = parts[0].trim();
      final ilce = parts[1].trim();
      final mahalle = parts[2].trim();
      final remainder = parts.length > 3 ? parts.sublist(3).join(' / ') : '';

      // İl seç
      await selectIl(il);
      
      // İlçe seç
      if (ilceler.contains(ilce)) {
        await selectIlce(ilce);
        
        // Mahalle seç
        if (mahalleler.contains(mahalle)) {
          selectMahalle(mahalle);
        }
      }
      
      adresController.text = remainder.isEmpty ? addressLine : remainder;
    } else {
      // Format tutmuyorsa direkt açık adrese yaz
      adresController.text = addressLine;
    }
  }

  final TextEditingController adresController = TextEditingController();
  final TextEditingController baslikController = TextEditingController();

  double _latitude = 0;
  double _longitude = 0;

  double get latitude => _latitude;
  double get longitude => _longitude;

  bool get hasCoordinates => _latitude != 0 && _longitude != 0;

  String? selectedIl;
  String? selectedIlce;
  String? selectedMahalle;

  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _neighborhoods = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isEditMode => initialAddress != null;

  List<String> get iller => _provinces.map((e) => e.name).toList()..sort();
  List<String> get ilceler => _districts.map((e) => e.name).toList()..sort();
  List<String> get mahalleler => _neighborhoods.map((e) => e.name).toList()..sort();

  Future<void> _initLocations() async {
    _provinces = await _locationService.getProvinces();
    notifyListeners();
  }

  Future<void> selectIl(String? ilName) async {
    if (selectedIl == ilName) return;
    selectedIl = ilName;
    selectedIlce = null;
    selectedMahalle = null;
    _districts = [];
    _neighborhoods = [];
    notifyListeners();

    if (ilName != null) {
      final province = _provinces.firstWhere((p) => p.name == ilName, orElse: () => LocationModel(id: 0, name: ''));
      if (province.id != 0) {
        _districts = await _locationService.getDistricts(province.id);
        notifyListeners();
      }
    }
  }

  Future<void> selectIlce(String? ilceName) async {
    if (selectedIlce == ilceName) return;
    selectedIlce = ilceName;
    selectedMahalle = null;
    _neighborhoods = [];
    notifyListeners();

    if (ilceName != null) {
      final district = _districts.firstWhere((d) => d.name == ilceName, orElse: () => LocationModel(id: 0, name: ''));
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

  void setCoordinates(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void updateFromMap({
    required double lat,
    required double lng,
    String? address,
    String? city,
    String? district,
    String? neighborhood,
  }) async {
    _latitude = lat;
    _longitude = lng;

    if (city != null) await selectIl(city);
    if (district != null) {
      final matched = _findInList(ilceler, district);
      if (matched.isNotEmpty) await selectIlce(matched);
    }
    if (neighborhood != null) {
      final matched = _findInList(mahalleler, neighborhood);
      if (matched.isNotEmpty) selectMahalle(matched);
    }

    if (address != null) {
      // Sadece sokak/numara kısmını almaya çalış
      final parts = address.split(',');
      if (parts.isNotEmpty) {
        adresController.text = parts[0].trim();
      } else {
        adresController.text = address;
      }
    }
    notifyListeners();
  }

  Future<void> _geocodeAddress() async {
    final queries = <String>[];
    final cleanStreet = adresController.text.trim();
    final cleanMahalle = selectedMahalle?.trim() ?? '';
    final cleanIlce = selectedIlce?.trim() ?? '';
    final cleanIl = selectedIl?.trim() ?? '';

    // En detaylı sorgu (Açık adres + mahalle + ilçe + il + ülke)
    if (cleanStreet.isNotEmpty && cleanMahalle.isNotEmpty && cleanIlce.isNotEmpty && cleanIl.isNotEmpty) {
      queries.add('$cleanStreet, $cleanMahalle, $cleanIlce, $cleanIl, Türkiye');
    }
    
    // Mahalle bazlı sorgu (mahalle + ilçe + il + ülke)
    if (cleanMahalle.isNotEmpty && cleanIlce.isNotEmpty && cleanIl.isNotEmpty) {
      queries.add('$cleanMahalle, $cleanIlce, $cleanIl, Türkiye');
    }
    
    // İlçe bazlı sorgu (ilçe + il + ülke)
    if (cleanIlce.isNotEmpty && cleanIl.isNotEmpty) {
      queries.add('$cleanIlce, $cleanIl, Türkiye');
    }
    
    // İl bazlı sorgu (il + ülke)
    if (cleanIl.isNotEmpty) {
      queries.add('$cleanIl, Türkiye');
    }

    // fallback durumları için
    if (queries.isEmpty && cleanStreet.isNotEmpty) {
      queries.add(cleanStreet);
    }

    for (final q in queries) {
      if (q.trim().isEmpty) continue;
      try {
        debugPrint('🔍 [FoodAddAddressVM] Geocode deneniyor: $q');
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': q,
          'format': 'json',
          'limit': '1',
          'accept-language': 'tr',
        });
        final res = await http
            .get(uri, headers: {'User-Agent': 'YemisApp/1.0'})
            .timeout(ApiConstants.requestTimeout);
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          if (data.isNotEmpty) {
            _latitude = double.parse(data[0]['lat']);
            _longitude = double.parse(data[0]['lon']);
            debugPrint('✅ [FoodAddAddressVM] Koordinatlar bulundu: $_latitude, $_longitude (Sorgu: $q)');
            return; // Başarılı bulduğumuzda aramayı bitir
          }
        }
      } catch (e) {
        debugPrint('⚠️ [FoodAddAddressVM] Geocode hatası ($q): $e');
      }
      
      // Nominatim rate-limit engeli için kısa bir gecikme ekleyelim
      await Future.delayed(const Duration(milliseconds: 300));
    }
    debugPrint('❌ [FoodAddAddressVM] Geocode başarısız oldu, koordinatlar bulunamadı.');
  }

  Future<bool> saveAddress() async {
    _errorMessage = null;
    if (adresController.text.isEmpty) {
      _errorMessage = 'Lütfen adres bilgilerini doldurunuz.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    notifyListeners();

    // Eğer koordinat seçilmemişse geocode etmeye çalış
    if (!hasCoordinates) {
      await _geocodeAddress();
    }

    // Geocode sonrası koordinatlar hala 0 ise işleme izin verme
    if (!hasCoordinates) {
      _isLoading = false;
      _errorMessage = 'Adresin koordinatları tespit edilemedi. Lütfen haritadan konum seçin.';
      notifyListeners();
      return false;
    }

    // Mükerrer adres kontrolü
    try {
      final existingAddresses = await _authService.getAddresses();
      final currentFullAddress = formattedAddress;
      
      final isDuplicate = existingAddresses.any((a) {
        // Düzenleme modundaysak kendisiyle karşılaştırmasın
        if (isEditMode && a.id == initialAddress?.id) return false;
        
        final sameAddressLine = a.addressLine.trim().toLowerCase() == currentFullAddress.trim().toLowerCase();
        final sameCoordinates = hasCoordinates && a.latitude == _latitude && a.longitude == _longitude;
        
        return sameAddressLine || sameCoordinates;
      });

      if (isDuplicate) {
        _isLoading = false;
        _errorMessage = 'Aynı adres tekrar girilemez.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [FoodAddAddressVM] Mükerrer kontrolü sırasında hata: $e');
    }

    try {
      final addressData = AddressModel(
        id: initialAddress?.id ?? 0,
        userId: initialAddress?.userId ?? 0,
        label: baslikController.text.isEmpty ? 'Ev' : baslikController.text,
        addressLine: formattedAddress,
        city: selectedIl,
        district: selectedIlce,
        neighborhood: selectedMahalle,
        latitude: _latitude,
        longitude: _longitude,
        isDefault: initialAddress?.isDefault ?? true,
      );

      debugPrint('💾 [FoodAddAddressViewModel] Adres kaydediliyor...');
      debugPrint('   - Mod: ${isEditMode ? 'DÜZENLEME' : 'YENİ KAYIT'}');
      debugPrint('   - Başlık: ${addressData.label}');
      debugPrint('   - Adres: ${addressData.addressLine}');

      final bool result;
      if (isEditMode && initialAddress!.id > 0) {
        // PUT /api/users/me/addresses/{id}
        result = await _authService.updateAddress(initialAddress!.id, addressData);
      } else {
        // POST /api/users/me/addresses
        result = await _authService.createAddress(addressData);
      }

      if (result) {
        debugPrint('✅ [FoodAddAddressViewModel] Adres başarıyla ${isEditMode ? 'güncellendi' : 'kaydedildi'}.');
      } else {
        debugPrint('❌ [FoodAddAddressViewModel] Adres kaydı API tarafında başarısız oldu.');
      }

      return result;
    } catch (e) {
      debugPrint('❌ [FoodAddAddressViewModel] Hata oluştu: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    adresController.dispose();
    baslikController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
