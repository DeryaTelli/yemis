import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/location_service.dart';
import '../../services/location/map_navigation_service.dart';
import '../../services/location/routing_service.dart';

class NavigationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final MapNavigationService _mapNavigationService = MapNavigationService();
  final RoutingService _routingService = RoutingService();

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
  LatLng? _origin;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NavigationTravelMode _travelMode = NavigationTravelMode.driving;
  NavigationTravelMode get travelMode => _travelMode;

  bool _isRouteLoading = false;
  bool get isRouteLoading => _isRouteLoading;

  RouteResult? _route;
  List<LatLng> get routePoints => _route?.points ?? const [];
  bool get hasRoute => routePoints.isNotEmpty;

  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _lastRouteOrigin;
  bool _isRerouting = false;

  LatLng get destination => LatLng(destinationLat, destinationLng);
  LatLng? get userLocation => _origin;

  double? _distanceInMeters;
  String get distanceText {
    final distance = _route?.distanceMeters ?? _distanceInMeters;
    if (distance == null) return "...";
    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} m";
    } else {
      return "${(distance / 1000).toStringAsFixed(1)} km";
    }
  }

  String get durationText {
    final seconds = _route?.durationSeconds;
    if (seconds == null) return '-- dk';
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return '$minutes dk';
    return '${minutes ~/ 60}s ${minutes % 60}dk';
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
        _origin = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        _calculateDistance();
        _startPositionTracking();
      }
    } catch (e) {
      _errorMessage = "Konum alınamadı.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateDistance() {
    if (_origin != null) {
      _distanceInMeters = Geolocator.distanceBetween(
        _origin!.latitude,
        _origin!.longitude,
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
      originLat: userLocation?.latitude,
      originLng: userLocation?.longitude,
    );
  }

  Future<void> startNavigation(NavigationTravelMode travelMode) async {
    await _mapNavigationService.openGoogleMaps(
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      originLat: userLocation?.latitude,
      originLng: userLocation?.longitude,
      travelMode: travelMode,
    );
  }

  Future<void> showRoute([
    NavigationTravelMode? travelMode,
    bool startGuidance = false,
  ]) async {
    if (userLocation == null) return;
    _travelMode = travelMode ?? _travelMode;
    _isRouteLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _route = await _routingService.getRoute(
        origin: userLocation!,
        destination: destination,
        travelMode: _travelMode,
      );
      _lastRouteOrigin = userLocation;
      if (routePoints.isNotEmpty) {
        if (startGuidance) {
          _isNavigating = true;
          mapController.move(userLocation!, 17.5);
          _startPositionTracking();
        } else if (!_isNavigating) {
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(routePoints),
              padding: const EdgeInsets.fromLTRB(40, 100, 40, 300),
            ),
          );
        }
      }
    } catch (_) {
      _errorMessage = 'Rota oluşturulamadı.';
    } finally {
      _isRouteLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTravelMode(NavigationTravelMode travelMode) async {
    _travelMode = travelMode;
    if (hasRoute) {
      await showRoute(travelMode, _isNavigating);
    } else {
      notifyListeners();
    }
  }

  Future<void> startGuidance() => showRoute(_travelMode, true);

  void _startPositionTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen(_handlePositionUpdate);
  }

  Future<void> _handlePositionUpdate(Position position) async {
    if (userLocation == null) return;

    final liveLocation = LatLng(position.latitude, position.longitude);
    if (_lastRouteOrigin != null) {
      final distanceFromRoute = Geolocator.distanceBetween(
        _lastRouteOrigin!.latitude,
        _lastRouteOrigin!.longitude,
        liveLocation.latitude,
        liveLocation.longitude,
      );
      if (distanceFromRoute > 20000) return;
    }

    _currentPosition = position;
    _origin = liveLocation;
    _calculateDistance();
    if (_isNavigating) {
      mapController.move(liveLocation, 17.5);
    }
    notifyListeners();

    if (!_isNavigating || _isRerouting || _lastRouteOrigin == null) return;
    final distanceSinceLastRoute = Geolocator.distanceBetween(
      _lastRouteOrigin!.latitude,
      _lastRouteOrigin!.longitude,
      liveLocation.latitude,
      liveLocation.longitude,
    );
    if (distanceSinceLastRoute < 40) return;

    _isRerouting = true;
    try {
      _route = await _routingService.getRoute(
        origin: liveLocation,
        destination: destination,
        travelMode: _travelMode,
      );
      _lastRouteOrigin = liveLocation;
      notifyListeners();
    } catch (_) {
      // Keep the last valid route while waiting for the next GPS update.
    } finally {
      _isRerouting = false;
    }
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

  @override
  void dispose() {
    _positionSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }
}
