import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/theme/text_styles_custom.dart';

import '../../viewmodels/auth/food_add_address_viewmodel.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/location/i_location_data_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/location_picker_bottom_sheet.dart';
import '../../models/app_module_type.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/user_session.dart';

class FoodAddAddressView extends StatelessWidget {
  final AddressModel? address;
  final AppModuleType moduleType;

  const FoodAddAddressView({
    super.key,
    this.address,
    this.moduleType = AppModuleType.food,
  });

  @override
  Widget build(BuildContext context) {
    final userSession = context.read<UserSession>();
    final themeColor =
        (moduleType == AppModuleType.food ||
            moduleType == AppModuleType.business)
        ? AppColors.primaryColor
        : AppColors.volunteerColor;

    final section =
        (moduleType == AppModuleType.food ||
            moduleType == AppModuleType.business)
        ? AppSection.food
        : AppSection.volunteer;

    return Theme(
      data: AppTheme.themeFor(section),
      child: ChangeNotifierProvider(
        create: (_) => FoodAddAddressViewModel(
          authService: context.read<IAuthService>(),
          locationService: context.read<ILocationDataService>(),
          initialAddress: address,
        ),
        child: _FoodAddAddressBody(themeColor: themeColor),
      ),
    );
  }
}

class _FoodAddAddressBody extends StatefulWidget {
  final Color themeColor;
  const _FoodAddAddressBody({required this.themeColor});

  @override
  State<_FoodAddAddressBody> createState() => _FoodAddAddressBodyState();
}

class _FoodAddAddressBodyState extends State<_FoodAddAddressBody> {
  FoodAddAddressViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ViewModel referansını güvenli bir şekilde sakla
    if (_viewModel == null) {
      _viewModel = context.read<FoodAddAddressViewModel>();
      _viewModel!.addListener(_onVmChanged);
    }
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onVmChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodAddAddressViewModel>();
    final themeColor = widget.themeColor;

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: themeColor == AppColors.volunteerColor
          ? AppModuleType.volunteer
          : AppModuleType.food,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(vm.isEditMode ? 'Adresi Düzenle' : 'Adres Ekle'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('İl'),
              _SelectionField(
                hint: 'Seçiniz',
                value: vm.selectedIl,
                themeColor: themeColor,
                onTap: () => _showPicker(
                  context,
                  'İl Seçiniz',
                  vm.iller,
                  vm.selectIl,
                  themeColor,
                ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('İlçe'),
              _SelectionField(
                hint: vm.selectedIl == null ? 'Önce il seçiniz' : 'Seçiniz',
                value: vm.selectedIlce,
                enabled: vm.selectedIl != null,
                themeColor: themeColor,
                onTap: vm.selectedIl == null
                    ? null
                    : () => _showPicker(
                        context,
                        'İlçe Seçiniz',
                        vm.ilceler,
                        vm.selectIlce,
                        themeColor,
                      ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Mahalle'),
              _SelectionField(
                hint: vm.selectedIlce == null ? 'Önce ilçe seçiniz' : 'Seçiniz',
                value: vm.selectedMahalle,
                enabled: vm.selectedIlce != null,
                themeColor: themeColor,
                onTap: vm.selectedIlce == null
                    ? null
                    : () => _showPicker(
                        context,
                        'Mahalle Seçiniz',
                        vm.mahalleler,
                        vm.selectMahalle,
                        themeColor,
                      ),
              ),
              const SizedBox(height: 24),
              _fieldLabel('Adres'),
              CustomTextField(
                controller: vm.adresController,
                hintText: 'Cadde, mahalle sokak ve diğer bilgileri giriniz.',
                maxLines: 3,
                borderColor: const Color(0xFFE0E0E0),
                fillColor: const Color(0xFFF9F9F9),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Adres Başlığı'),
              CustomTextField(
                controller: vm.baslikController,
                hintText: 'Adres Başlığı Giriniz (Örn: Ev, İş)',
                borderColor: const Color(0xFFE0E0E0),
                fillColor: const Color(0xFFF9F9F9),
              ),
              const SizedBox(height: 16),
              // ── Haritadan Seç ──
              _MapPickerButton(
                themeColor: themeColor,
                hasCoordinates: vm.hasCoordinates,
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/map-picker',
                    arguments: {'accentColor': themeColor},
                  );
                  if (result is Map<String, dynamic>) {
                    final latLng = result['latLng'];
                    if (latLng != null) {
                      vm.updateFromMap(
                        lat: latLng.latitude,
                        lng: latLng.longitude,
                        address: result['address'],
                        city: result['city'],
                        district: result['district'],
                        neighborhood: result['neighborhood'],
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: LocaleKeys.common_save.tr(),
                backgroundColor: themeColor,
                onPressed: () async {
                  final success = await vm.saveAddress();
                  if (success && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                width: double.infinity,
                height: 54,
                borderRadius: 14,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  void _showPicker(
    BuildContext context,
    String title,
    List<String> items,
    void Function(String?) onSelect,
    Color themeColor,
  ) {
    LocationPickerBottomSheet.show(
      context: context,
      title: title,
      items: items,
      onSelect: onSelect,
      themeColor: themeColor,
    );
  }
}

class _SelectionField extends StatelessWidget {
  final String hint;
  final String? value;
  final bool enabled;
  final Color themeColor;
  final VoidCallback? onTap;

  const _SelectionField({
    required this.hint,
    required this.value,
    this.enabled = true,
    required this.themeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF9F9F9) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? themeColor.withOpacity(0.5)
                : const Color(0xFFE0E0E0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: value != null
                    ? CustomTextStyles.regular16DarkGrey
                    : CustomTextStyles.semiBold16Grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled
                  ? (value != null ? themeColor : Colors.grey)
                  : Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPickerButton extends StatelessWidget {
  final Color themeColor;
  final bool hasCoordinates;
  final VoidCallback onTap;

  const _MapPickerButton({
    required this.themeColor,
    required this.hasCoordinates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasCoordinates
              ? themeColor.withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasCoordinates
                ? themeColor.withOpacity(0.3)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasCoordinates ? Icons.location_on : Icons.map_outlined,
              color: hasCoordinates ? themeColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasCoordinates
                    ? 'Konum Haritadan İşaretlendi'
                    : LocaleKeys.common_selectLocationFromMap.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasCoordinates ? themeColor : Colors.grey.shade700,
                ),
              ),
            ),
            if (hasCoordinates)
              Icon(Icons.check_circle, color: themeColor, size: 18)
            else
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
