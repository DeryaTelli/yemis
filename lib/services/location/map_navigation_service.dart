import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

enum NavigationTravelMode { driving, walking }

class MapNavigationService {
  /// Open Google Maps with navigation from origin to destination
  Future<void> openGoogleMaps({
    required double destinationLat,
    required double destinationLng,
    double? originLat,
    double? originLng,
    NavigationTravelMode travelMode = NavigationTravelMode.driving,
  }) async {
    final googleMode = travelMode == NavigationTravelMode.walking
        ? 'walking'
        : 'driving';
    final androidMode = travelMode == NavigationTravelMode.walking ? 'w' : 'd';
    String url;

    if (Platform.isAndroid) {
      url =
          'google.navigation:q=$destinationLat,$destinationLng&mode=$androidMode';
    } else {
      url =
          'comgooglemaps://?daddr=$destinationLat,$destinationLng&directionsmode=$googleMode';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to browser or store
      final origin = originLat != null && originLng != null
          ? '&origin=$originLat,$originLng'
          : '';
      final webUrl =
          'https://www.google.com/maps/dir/?api=1$origin&destination=$destinationLat,$destinationLng&travelmode=$googleMode';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Redirect to Store
        final storeUrl = Platform.isAndroid
            ? 'https://play.google.com/store/apps/details?id=com.google.android.apps.maps'
            : 'https://apps.apple.com/app/google-maps/id585027354';
        await launchUrl(
          Uri.parse(storeUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }

  /// Open Apple Maps (iOS only)
  Future<void> openAppleMaps({
    required double destinationLat,
    required double destinationLng,
    NavigationTravelMode travelMode = NavigationTravelMode.driving,
  }) async {
    if (!Platform.isIOS) return;

    final mode = travelMode == NavigationTravelMode.walking ? 'w' : 'd';
    final url =
        'http://maps.apple.com/?daddr=$destinationLat,$destinationLng&dirflg=$mode';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  /// Open Yandex Maps / Navigator
  Future<void> openYandexMaps({
    required double destinationLat,
    required double destinationLng,
  }) async {
    final url =
        'yandexnavi://build_route_on_map?lat_to=$destinationLat&lon_to=$destinationLng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Redirect to Store
      final storeUrl = Platform.isAndroid
          ? 'https://play.google.com/store/apps/details?id=ru.yandex.yandexnavi'
          : 'https://apps.apple.com/app/yandex-navi-navigation-maps/id474500851';
      await launchUrl(
        Uri.parse(storeUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
