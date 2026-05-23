import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class AppTileLayer extends StatelessWidget {
  const AppTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate:
          'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.yemis.app',
      tileProvider: NetworkTileProvider(),
    );
  }
}
