import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/location_service.dart';
import '../../services/location/map_navigation_service.dart';

class NavigationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final MapNavigationService _mapNavigationService = MapNavigationService();

  final double destinationLat;
  final double destinationLng;
  final String businessName;
  final String address;

  NavigationViewModel({
    required this.destinationLat,
    required this.destinationLng,
    required this.businessName,
    required this.address,
  });

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LatLng get destination => LatLng(destinationLat, destinationLng);
  LatLng? get userLocation => _currentPosition != null 
      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude) 
      : null;

  double? _distanceInMeters;
  String get distanceText {
    if (_distanceInMeters == null) return "...";
    if (_distanceInMeters! < 1000) {
      return "${_distanceInMeters!.toStringAsFixed(0)} m";
    } else {
      return "${(_distanceInMeters! / 1000).toStringAsFixed(1)} km";
    }
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Check permission
    _hasPermission = await _locationService.checkAndRequestPermission();
    
    if (_hasPermission) {
      await _fetchLocation();
    } else {
      _errorMessage = "Yol tarifi almak için konum izni vermeniz gerekiyor.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      if (_currentPosition != null) {
        _calculateDistance();
      }
    } catch (e) {
      _errorMessage = "Konum alınamadı.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateDistance() {
    if (_currentPosition != null) {
      _distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        destinationLat,
        destinationLng,
      );
    }
  }

  Future<void> openSettings() async {
    await _locationService.openSettings();
    // After returning from settings, we might want to check again
    await init();
  }

  Future<void> launchGoogleMaps() async {
    await _mapNavigationService.openGoogleMaps(
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }

  Future<void> launchAppleMaps() async {
    await _mapNavigationService.openAppleMaps(
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }

  Future<void> launchYandexMaps() async {
    await _mapNavigationService.openYandexMaps(
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }

  final MapController mapController = MapController();

  void moveToDestination() {
    mapController.move(destination, 15.0);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
