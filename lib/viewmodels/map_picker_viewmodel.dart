// ignore_for_file: unnecessary_underscores
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────
// Nominatim arama sonucu modeli
// ─────────────────────────────────────────────
class PlaceResult {
  final String displayName;
  final double lat;
  final double lon;

  const PlaceResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) => PlaceResult(
        displayName: json['display_name'] as String,
        lat: double.parse(json['lat'] as String),
        lon: double.parse(json['lon'] as String),
      );
}

// ─────────────────────────────────────────────
// MapPickerViewModel
// ─────────────────────────────────────────────
class MapPickerViewModel extends ChangeNotifier {
  // Varsayılan konum: İstanbul
  static const LatLng defaultCenter = LatLng(41.015137, 28.979530);

  // ─── State ───────────────────────────────────────

  LatLng _center = defaultCenter;
  LatLng get center => _center;

  bool _isLocating = true;
  bool get isLocating => _isLocating;

  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  List<PlaceResult> _searchResults = [];
  List<PlaceResult> get searchResults => List.unmodifiable(_searchResults);

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // ─── Init ─────────────────────────────────────────
  Future<void> init() async {
    final latLng = await _moveToCurrentLocation();
    if (latLng != null) {
      _reverseGeocode(latLng);
    }
  }

  // ─── Harita merkezi güncelleme ────────────────────
  void updateCenter(LatLng newCenter) {
    _center = newCenter;
    // Debounced reverse geocoding
    _addressDebounce?.cancel();
    _addressDebounce = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocode(newCenter);
    });
  }

  // ─── GPS ─────────────────────────────────────────
  Future<LatLng?> _moveToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      _center = latLng;
      _isLocating = false;
      notifyListeners();
      return latLng;
    } catch (_) {
      _isLocating = false;
      notifyListeners();
      return null;
    }
  }

  // ─── Nominatim Arama ─────────────────────────────
  Timer? _debounce;
  Timer? _addressDebounce;

  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _debounce =
        Timer(const Duration(milliseconds: 600), () => _search(query));
  }

  Future<void> _search(String query) async {
    _isSearching = true;
    notifyListeners();
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '5',
        'accept-language': 'tr',
      });
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'YemisApp/1.0'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        _searchResults = data
            .map((e) => PlaceResult.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // sessizce geç
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latLng.latitude.toString(),
        'lon': latLng.longitude.toString(),
        'format': 'json',
        'accept-language': 'tr',
      });
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'YemisApp/1.0'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _currentAddress = data['display_name'] as String? ?? '';
        notifyListeners();
      }
    } catch (_) {
      // sessizce geç
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchResults = [];
    notifyListeners();
  }

  // ─── Dispose ─────────────────────────────────────
  @override
  void dispose() {
    _debounce?.cancel();
    _addressDebounce?.cancel();
    super.dispose();
  }
}
