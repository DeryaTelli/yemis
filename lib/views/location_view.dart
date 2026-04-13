import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/auth/user_session.dart';
import '../utils/locale_keys.dart';
import '../utils/routes/app_routes.dart';
import '../utils/theme/text_styles_custom.dart';
import '../viewmodels/location_viewmodel.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/error_banner.dart';

class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final userSession = context.read<UserSession>();
    return ChangeNotifierProvider(
      create: (_) => LocationViewModel(userSession: userSession)..init(),
      child: const _LocationBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WidgetsBindingObserver: Kullanıcı ayarlardan döndüğünde onAppResumed tetiklenir
// ─────────────────────────────────────────────────────────────────────────────
class _LocationBody extends StatefulWidget {
  const _LocationBody();

  @override
  State<_LocationBody> createState() => _LocationBodyState();
}

class _LocationBodyState extends State<_LocationBody>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!mounted) return;

    final vm = context.read<LocationViewModel>();
    vm.onAppResumed(
      onShareSuccess: (lat, lng) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      onPickNavigate: () async {
        if (!mounted) return;
        final result = await Navigator.pushNamed(context, AppRoutes.mapPicker);
        if (!mounted) return;
        if (result != null && result is LatLng) {
          await vm.onLocationPicked(result.latitude, result.longitude, () {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.location_title.tr()),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ── İllüstrasyon ──
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/foodIcon/locationPoint.png',
                        width: 120,
                        height: 120,
                      ),
                      if (!vm.hasPermission &&
                          vm.permissionState !=
                              LocationPermissionState.unknown) ...[
                        const SizedBox(height: 16),
                        Text(
                          LocaleKeys.location_permissionDenied.tr(),
                          style: CustomTextStyles.regular14Grey,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Hata banner'ı ──
              if (vm.errorKey != null) ...[
                ErrorBanner(
                  message: vm.errorKey!.tr(),
                  onDismiss: vm.clearError,
                ),
                const SizedBox(height: 12),
              ],

              // ── Başlık & Açıklama ──
              Text(
                LocaleKeys.location_shareTitle.tr(),
                style: CustomTextStyles.semiBold16Primary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                LocaleKeys.location_shareDescription.tr(),
                style: CustomTextStyles.regular14Grey,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── "Paylaş" butonu ──
              CustomButton(
                text: LocaleKeys.location_buttonShare.tr(),
                isLoading: vm.isLoading,
                width: double.infinity,
                height: 52,
                onPressed: () => vm.shareLocation(
                  onOpenSettings: openAppSettings,
                  onSuccess: (lat, lng) {
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // ── "Konum Seç" butonu ──
              CustomButton(
                text: LocaleKeys.location_buttonPick.tr(),
                isOutlined: true,
                width: double.infinity,
                height: 52,
                onPressed: () => vm.pickOnMap(
                  onOpenSettings: openAppSettings,
                  onNavigate: () async {
                    if (!mounted) return;
                    final result = await Navigator.pushNamed(
                        context, AppRoutes.mapPicker);
                    if (!mounted) return;
                    if (result != null && result is LatLng) {
                      await vm.onLocationPicked(result.latitude, result.longitude, () {
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.home);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
