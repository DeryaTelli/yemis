import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import '../services/auth/i_auth_service.dart';
import '../services/auth/user_session.dart';
import '../utils/locale_keys.dart';
import '../utils/routes/app_routes.dart';
import '../utils/theme/text_styles_custom.dart';
import '../viewmodels/location_viewmodel.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/error_banner.dart';
import '../widgets/common/loading_overlay.dart';
import '../models/app_module_type.dart';
import '../utils/theme/app_theme.dart';

class LocationView extends StatelessWidget {
  final bool returnToSender;
  final AppModuleType moduleType;
  const LocationView({
    super.key,
    this.returnToSender = false,
    this.moduleType = AppModuleType.food,
  });

  @override
  Widget build(BuildContext context) {
    final userSession = context.read<UserSession>();
    final authService = context.read<IAuthService>();
    final themeColor = (moduleType == AppModuleType.food || moduleType == AppModuleType.business)
        ? AppColors.primaryColor
        : AppColors.volunteerColor;

    return ChangeNotifierProvider(
      create: (_) {
        final vm = LocationViewModel(
          userSession: userSession,
          authService: authService,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => vm.init());
        return vm;
      },
      child: _LocationBody(
        returnToSender: returnToSender,
        moduleType: moduleType,
        themeColor: themeColor,
      ),
    );
  }
}

class _LocationBody extends StatefulWidget {
  final bool returnToSender;
  final AppModuleType moduleType;
  final Color themeColor;

  const _LocationBody({
    required this.returnToSender,
    required this.moduleType,
    required this.themeColor,
  });

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
        if (widget.returnToSender) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      },
      onPickNavigate: () async {
        if (!mounted) return;
        final section = (widget.moduleType == AppModuleType.food || widget.moduleType == AppModuleType.business)
            ? AppSection.food
            : AppSection.volunteer;
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.mapPicker,
          arguments: {
            'accentColor': widget.themeColor,
            'accentGradient': (widget.moduleType == AppModuleType.food || widget.moduleType == AppModuleType.business)
                ? AppColors.primaryButtonGradient
                : AppColors.volunteerBackgroundGradient,
          },
        );
        if (!mounted) return;
        if (result is Map<String, dynamic>) {
          final latLng = result['latLng'] as LatLng?;
          if (latLng != null) {
            await vm.onLocationPicked(
              latLng.latitude,
              latLng.longitude,
              () {
                if (!mounted) return;
                if (widget.returnToSender) {
                  Navigator.pop(context, true);
                } else {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }
              },
              address: result['address'] as String?,
              city: result['city'] as String?,
              district: result['district'] as String?,
              neighborhood: result['neighborhood'] as String?,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationViewModel>();
    final section = (widget.moduleType == AppModuleType.food || widget.moduleType == AppModuleType.business)
        ? AppSection.food
        : AppSection.volunteer;

    return Theme(
      data: AppTheme.themeFor(section),
      child: LoadingOverlay(
        isLoading: vm.isLoading,
        moduleType: widget.moduleType,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(LocaleKeys.location_title.tr()),
            leading: widget.returnToSender
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
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
                          Lottie.asset(
                            'assets/lottie/location.json',
                            height: 360,
                            fit: BoxFit.contain,
                          ),
                          if (!vm.hasPermission &&
                              vm.permissionState !=
                                  LocationPermissionState.unknown) ...[
                            const SizedBox(height: 16),
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
                    style: CustomTextStyles.semiBold16Primary.copyWith(
                      color: widget.themeColor,
                    ),
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
                    width: double.infinity,
                    backgroundColor: widget.themeColor,
                    height: 52,
                    onPressed: () => vm.shareLocation(
                      onOpenSettings: openAppSettings,
                      onSuccess: (lat, lng) {
                        if (!mounted) return;
                        if (widget.returnToSender) {
                          Navigator.pop(context, true);
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── "Konum Seç" butonu ──
                  CustomButton(
                    text: LocaleKeys.location_buttonPick.tr(),
                    isOutlined: true,
                    width: double.infinity,
                    backgroundColor: widget.themeColor,
                    height: 52,
                    onPressed: () => vm.pickOnMap(
                      onOpenSettings: openAppSettings,
                      onNavigate: () async {
                        if (!mounted) return;
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.mapPicker,
                          arguments: {
                            'accentColor': widget.themeColor,
                            'accentGradient':
                                (widget.moduleType == AppModuleType.food || widget.moduleType == AppModuleType.business)
                                ? AppColors.primaryButtonGradient
                                : AppColors.volunteerBackgroundGradient,
                          },
                        );
                        if (!mounted) return;
                        if (result is Map<String, dynamic>) {
                          final latLng = result['latLng'] as LatLng?;
                          if (latLng != null) {
                            await vm.onLocationPicked(
                              latLng.latitude,
                              latLng.longitude,
                              () {
                                if (!mounted) return;
                                if (widget.returnToSender) {
                                  Navigator.pop(context, true);
                                } else {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.home,
                                  );
                                }
                              },
                              address: result['address'] as String?,
                              city: result['city'] as String?,
                              district: result['district'] as String?,
                              neighborhood: result['neighborhood'] as String?,
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
