// ignore_for_file: unnecessary_underscores
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/map_picker_viewmodel.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

/// Harita ekranının alt paneli: arama alanı + Konumu Seç butonu.
/// Ayrı bir widget olarak tutularak [MapPickerView]'dan bağımsız test edilebilir.
class MapPickerBottomPanel extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final MapPickerViewModel vm;
  final void Function(PlaceResult) onSelectPlace;
  final VoidCallback onConfirm;
  final LinearGradient? accentGradient;
  final Color? accentColor;

  const MapPickerBottomPanel({
    super.key,
    required this.searchController,
    required this.searchFocus,
    required this.vm,
    required this.onSelectPlace,
    required this.onConfirm,
    this.accentGradient,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Sürükleme çubuğu ──
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Arama alanı ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextField(
                controller: searchController,
                hintText: LocaleKeys.mapPicker_searchHint.tr(),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.hintTextColor,
                  size: 20,
                ),
                suffixIcon: vm.isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accentColor ?? AppColors.primaryColor,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.mic_outlined,
                        color: AppColors.hintTextColor,
                        size: 20,
                      ),
                onChanged: vm.onSearchChanged,
                fillColor: const Color(0xFFF5F5F5),
                borderColor: const Color(0xFFE0E0E0),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            // ── Arama sonuçları ──
            if (vm.searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  itemCount: vm.searchResults.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final place = vm.searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: accentColor ?? AppColors.primaryColor,
                        size: 18,
                      ),
                      title: Text(
                        place.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () => onSelectPlace(place),
                    );
                  },
                ),
              ),

            // ── Seçili Konum Bilgisi ──
            if (vm.currentAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: (accentColor ?? AppColors.primaryColor).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (accentColor ?? AppColors.primaryColor).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: accentColor ?? AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vm.currentAddress,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ── Konumu Seç butonu ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: LocaleKeys.mapPicker_confirmButton.tr(),
                gradient: accentGradient,
                backgroundColor: accentColor,
                onPressed: onConfirm,
                height: 52,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
