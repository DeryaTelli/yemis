import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class AppTileLayer extends StatelessWidget {
  const AppTileLayer({super.key, this.vivid = false});

  final bool vivid;

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: vivid
          ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
          : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.yemis.app',
      tileProvider: NetworkTileProvider(),
    );
  }
}
