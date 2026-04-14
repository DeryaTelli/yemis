import 'package:flutter/material.dart';
import '../../models/food/food_sort_type.dart';
import '../../utils/constants/app_colors.dart';

/// Yemek arama sayfası için filtre/sıralama bottom sheet'i.
///
/// Volunteer ekranındaki resim seçici ile aynı ListTile stilini kullanır:
/// daire arka planlı ikon + başlık + sağ ok + seçim işareti.
class FoodFilterBottomSheet extends StatelessWidget {
  const FoodFilterBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  final FoodSortType currentSort;
  final void Function(FoodSortType) onSortSelected;

  // ─── Filtre seçeneklerinin tanımı ───────────────────────────────────────

  static const _sortOptions = [
    _SortOption(
      type: FoodSortType.ratingAsc,
      label: 'Derecelendirme',
      subLabel: 'Düşükten yükseğe',
      icon: Icons.star_outline_rounded,
    ),
    _SortOption(
      type: FoodSortType.priceAsc,
      label: 'Fiyat',
      subLabel: 'Düşükten yükseğe',
      icon: Icons.attach_money_rounded,
    ),
    _SortOption(
      type: FoodSortType.distanceAsc,
      label: 'Mesafe',
      subLabel: 'Yakından uzağa',
      icon: Icons.near_me_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Sürükleme Çubuğu ──────────────────────────────────
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Başlık ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Sıralama',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  if (currentSort != FoodSortType.none)
                    GestureDetector(
                      onTap: () {
                        onSortSelected(currentSort); // toggle → none
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Temizle',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Sıralama Seçenekleri ───────────────────────────────
            ...List.generate(_sortOptions.length, (i) {
              final opt = _sortOptions[i];
              final isSelected = currentSort == opt.type;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SortTile(
                    option: opt,
                    isSelected: isSelected,
                    onTap: () {
                      onSortSelected(opt.type);
                      Navigator.pop(context);
                    },
                  ),
                  if (i < _sortOptions.length - 1)
                    const Divider(height: 1, indent: 72, endIndent: 20),
                ],
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Yardımcı Veri Sınıfı ─────────────────────────────────────────────────────

class _SortOption {
  const _SortOption({
    required this.type,
    required this.label,
    required this.subLabel,
    required this.icon,
  });

  final FoodSortType type;
  final String label;
  final String subLabel;
  final IconData icon;
}

// ─── Tek Sıralama Satırı ──────────────────────────────────────────────────────

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _SortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          option.icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        option.label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.primaryTextColor,
        ),
      ),
      subtitle: Text(
        option.subLabel,
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.7)
              : AppColors.hintTextColor,
        ),
      ),
      trailing: Radio<FoodSortType>(
        value: option.type,
        groupValue: isSelected ? option.type : null,
        activeColor: AppColors.primaryColor,
        onChanged: (_) => onTap(),
      ),
    );
  }
}
