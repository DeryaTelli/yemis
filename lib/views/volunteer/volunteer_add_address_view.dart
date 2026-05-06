import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_add_address_viewmodel.dart';
import '../../services/location/i_location_data_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/location_picker_bottom_sheet.dart';

/// Gönüllü tarafı için yeni adres ekleme ekranı.
/// Volunteer teması otomatik uygulanır.
class VolunteerAddAddressView extends StatelessWidget {
  const VolunteerAddAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerAddAddressViewModel(
          locationService: context.read<ILocationDataService>(),
        ),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerAddAddressViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.addresses_addAddress.tr()),
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
            // ── İl ───────────────────────────────────────────────────────────
            _fieldLabel(LocaleKeys.addresses_city.tr()),
            _SelectionField(
              hint: LocaleKeys.addresses_select.tr(),
              value: vm.selectedIl,
              items: vm.iller,
              onTap: (context) =>
                  _showPicker(context, '${LocaleKeys.addresses_city.tr()} ${LocaleKeys.addresses_select.tr()}', vm.iller, vm.selectIl),
            ),
            const SizedBox(height: 16),

            // ── İlçe ─────────────────────────────────────────────────────────
            _fieldLabel(LocaleKeys.addresses_district.tr()),
            _SelectionField(
              hint: vm.selectedIl == null ? LocaleKeys.addresses_selectCityFirst.tr() : LocaleKeys.addresses_select.tr(),
              value: vm.selectedIlce,
              items: vm.ilceler,
              enabled: vm.selectedIl != null,
              onTap: vm.selectedIl == null
                  ? null
                  : (context) => _showPicker(
                      context,
                      '${LocaleKeys.addresses_district.tr()} ${LocaleKeys.addresses_select.tr()}',
                      vm.ilceler,
                      vm.selectIlce,
                    ),
            ),
            const SizedBox(height: 16),

            // ── Mahalle ───────────────────────────────────────────────────────
            _fieldLabel(LocaleKeys.addresses_neighborhood.tr()),
            _SelectionField(
              hint: vm.selectedIlce == null ? LocaleKeys.addresses_selectDistrictFirst.tr() : LocaleKeys.addresses_select.tr(),
              value: vm.selectedMahalle,
              items: vm.mahalleler,
              enabled: vm.selectedIlce != null,
              onTap: vm.selectedIlce == null
                  ? null
                  : (context) => _showPicker(
                      context,
                      '${LocaleKeys.addresses_neighborhood.tr()} ${LocaleKeys.addresses_select.tr()}',
                      vm.mahalleler,
                      vm.selectMahalle,
                    ),
            ),
            const SizedBox(height: 24),

            // ── Açık Adres ────────────────────────────────────────────────────
            _fieldLabel(LocaleKeys.addresses_addressLine.tr()),
            CustomTextField(
              controller: vm.adresController,
              hintText: LocaleKeys.addresses_enterAddressInfo.tr(),
              maxLines: 3,
              borderColor: const Color(0xFFE0E0E0),
              fillColor: const Color(0xFFF9F9F9),
            ),
            const SizedBox(height: 16),

            // ── Adres Başlığı ─────────────────────────────────────────────────
            _fieldLabel(LocaleKeys.addresses_addressTitle.tr()),
            CustomTextField(
              controller: vm.baslikController,
              hintText: LocaleKeys.addresses_enterAddressTitle.tr(),
              borderColor: const Color(0xFFE0E0E0),
              fillColor: const Color(0xFFF9F9F9),
            ),
            const SizedBox(height: 32),

            // ── Kaydet Butonu ─────────────────────────────────────────────────
            CustomButton(
              text: LocaleKeys.common_save.tr(),
              gradient: AppColors.volunteerBackgroundGradient,
              width: double.infinity,
              height: 54,
              borderRadius: 14,
              onPressed: () => Navigator.pop(context, vm.formattedAddress),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryTextColor,
    ),
  );

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryTextColor,
      ),
    ),
  );

  void _showPicker(
    BuildContext context,
    String title,
    List<String> items,
    void Function(String?) onSelect,
  ) {
    LocationPickerBottomSheet.show(
      context: context,
      title: title,
      items: items,
      onSelect: (selected) => onSelect(selected),
      themeColor: AppColors.volunteerColor,
    );
  }
}

/// Dropdown-gibi görünen seçim alanı.
class _SelectionField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final bool enabled;
  final void Function(BuildContext)? onTap;

  const _SelectionField({
    required this.hint,
    required this.value,
    required this.items,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF9F9F9) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppColors.volunteerColor.withValues(alpha: 0.5)
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
                  ? (value != null
                        ? AppColors.volunteerColor
                        : AppColors.hintTextColor)
                  : AppColors.hintTextColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
