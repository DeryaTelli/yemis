import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../utils/constants/app_colors.dart';
import '../common/custom_text_field.dart';

/// Arama sayfası için özelleştirilmiş AppBar.
///
/// İçerir:
/// - Arama çubuğu ve Filtre butonu
/// - Liste / Harita geçiş anahtarı (Altı çizili stil - FoodDetail ile aynı)
class SearchAppBarCustom extends StatelessWidget
    implements PreferredSizeWidget {
  final TextEditingController searchController;
  final void Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final bool isMapView;
  final void Function(bool) onViewModeChanged;
  final Color accentColor;

  const SearchAppBarCustom({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.isMapView,
    required this.onViewModeChanged,
    this.accentColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // Arka plan artık beyaz
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Arama Çubuğu + Filtre Butonu ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: CustomTextField(
                        controller: searchController,
                        hintText: LocaleKeys.common_searchHint.tr(),
                        hintStyle: CustomTextStyles.semiBold16Grey,
                        onChanged: onSearchChanged,
                        fillColor: Colors.white,
                        borderColor: accentColor, // Modül renginde çerçeve
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: accentColor,
                          size: 22,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor,
                        ), // Filtre butonu çerçevesi
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Liste / Harita Toggle (Altı Çizili Stil - FoodDetail ile aynı) ──
            _buildUnderlineToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderlineToggle() {
    return Row(
      children: [
        _TabItem(
          title: LocaleKeys.common_list.tr(),
          isSelected: !isMapView,
          accentColor: accentColor,
          onTap: () => onViewModeChanged(false),
        ),
        _TabItem(
          title: LocaleKeys.common_map.tr(),
          isSelected: isMapView,
          accentColor: accentColor,
          onTap: () => onViewModeChanged(true),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(130); // Daha da küçüldü
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? accentColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: isSelected
                ? CustomTextStyles.semiBold16Primary.copyWith(
                    color: accentColor,
                  )
                : CustomTextStyles.semiBold16Grey,
          ),
        ),
      ),
    );
  }
}
