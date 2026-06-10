import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'map_navigation_service.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
}

class RoutingService {
  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    required NavigationTravelMode travelMode,
  }) async {
    final profile = travelMode == NavigationTravelMode.walking
        ? 'routed-foot'
        : 'routed-car';
    final uri =
        Uri.parse(
          'https://routing.openstreetmap.de/$profile/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
        ).replace(
          queryParameters: const {
            'overview': 'full',
            'geometries': 'geojson',
            'steps': 'false',
          },
        );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Route request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) throw Exception('No route found');

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final points = coordinates.map((coordinate) {
      final values = coordinate as List<dynamic>;
      return LatLng(
        (values[1] as num).toDouble(),
        (values[0] as num).toDouble(),
      );
    }).toList();

    return RouteResult(
      points: points,
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }
}
