import 'package:flutter/material.dart';
import '../../models/volunteer/volunteer_sort_type.dart';
import '../../utils/constants/app_colors.dart';

/// Gönüllü arama sayfası için filtre/sıralama bottom sheet'i.
class VolunteerFilterBottomSheet extends StatelessWidget {
  const VolunteerFilterBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  final VolunteerSortType currentSort;
  final void Function(VolunteerSortType) onSortSelected;

  static const _sortOptions = [
    _SortOption(
      type: VolunteerSortType.ratingAsc,
      label: 'Derecelendirme',
      subLabel: 'Düşükten yükseğe',
      icon: Icons.star_outline_rounded,
    ),
    _SortOption(
      type: VolunteerSortType.distanceAsc,
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
                  if (currentSort != VolunteerSortType.none)
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
                          color: AppColors.volunteerColor,
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

class _SortOption {
  const _SortOption({
    required this.type,
    required this.label,
    required this.subLabel,
    required this.icon,
  });

  final VolunteerSortType type;
  final String label;
  final String subLabel;
  final IconData icon;
}

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
          color: AppColors.volunteerColor.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          option.icon,
          color: AppColors.volunteerColor,
          size: 20,
        ),
      ),
      title: Text(
        option.label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected
              ? AppColors.volunteerColor
              : AppColors.primaryTextColor,
        ),
      ),
      subtitle: Text(
        option.subLabel,
        style: TextStyle(
          fontSize: 12,
          color: isSelected
              ? AppColors.volunteerColor.withValues(alpha: 0.7)
              : AppColors.hintTextColor,
        ),
      ),
      trailing: Radio<VolunteerSortType>(
        value: option.type,
        groupValue: isSelected ? option.type : null,
        activeColor: AppColors.volunteerColor,
        onChanged: (_) => onTap(),
      ),
    );
  }
}
