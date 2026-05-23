// ignore_for_file: unnecessary_underscores
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../utils/constants/app_colors.dart';
import '../utils/locale_keys.dart';
import '../utils/theme/text_styles_custom.dart';
import '../viewmodels/map_picker_viewmodel.dart';
import '../widgets/common/app_tile_layer.dart';
import '../widgets/map/map_picker_bottom_panel.dart';
import '../utils/theme/app_theme.dart';

class MapPickerView extends StatelessWidget {
  const MapPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final accentColor = args?['accentColor'] as Color?;
    final accentGradient = args?['accentGradient'] as LinearGradient?;
    final section = accentColor == AppColors.volunteerColor ? AppSection.volunteer : AppSection.food;

    return ChangeNotifierProvider(
      create: (_) {
        final vm = MapPickerViewModel();
        WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
        return vm;
      },
      child: Theme(
        data: AppTheme.themeFor(section),
        child: _MapPickerBody(
          accentGradient: accentGradient,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

class _MapPickerBody extends StatefulWidget {
  final LinearGradient? accentGradient;
  final Color? accentColor;

  const _MapPickerBody({this.accentGradient, this.accentColor});

  @override
  State<_MapPickerBody> createState() => _MapPickerBodyState();
}

class _MapPickerBodyState extends State<_MapPickerBody> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  MapPickerViewModel? _vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm = context.read<MapPickerViewModel>();
      _vm!.addListener(_onVmChange);
    });
  }

  void _onVmChange() {
    final vm = _vm;
    if (vm == null) return;
    if (!vm.isLocating) {
      _mapController.move(vm.center, 15);
      vm.removeListener(_onVmChange);
    }
  }

  @override
  void dispose() {
    _vm?.removeListener(_onVmChange);
    _mapController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapPickerViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Harita ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MapPickerViewModel.defaultCenter,
              initialZoom: 13,
              onPositionChanged: (camera, _) {
                context.read<MapPickerViewModel>().updateCenter(camera.center);
              },
            ),
            children: [
              const AppTileLayer(),
            ],
          ),

          // ── Sabit merkez marker ──
          Center(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 48,
                  color: widget.accentColor ?? AppColors.primaryColor,
                ),
              ),
            ),
          ),

          // ── Kapat butonu (sağ üst) ──
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.accentColor ?? AppColors.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Konum bulunuyor göstergesi ──
          if (vm.isLocating)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.accentColor ?? AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleKeys.mapPicker_locating.tr(),
                        style: CustomTextStyles.regular14Grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Alt panel (ayrı widget) ──
          Align(
            alignment: Alignment.bottomCenter,
            child: MapPickerBottomPanel(
              searchController: _searchController,
              searchFocus: _searchFocus,
              vm: vm,
              accentGradient: widget.accentGradient,
              accentColor: widget.accentColor,
              onSelectPlace: (place) {
                final latLng = LatLng(place.lat, place.lon);
                _mapController.move(latLng, 15);
                context.read<MapPickerViewModel>().clearSearch();
                _searchController.clear();
                _searchFocus.unfocus();
              },
              onConfirm: () {
                final currentVm = context.read<MapPickerViewModel>();
                Navigator.pop(context, {
                  'latLng': currentVm.center,
                  'address': currentVm.currentAddress,
                  'city': currentVm.city,
                  'district': currentVm.district,
                  'neighborhood': currentVm.neighborhood,
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
