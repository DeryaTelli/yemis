import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../utils/constants/app_colors.dart';

class CardDatePickerField extends StatelessWidget {
  const CardDatePickerField({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.compact = false,
    this.borderColor,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool compact;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value != hint;

    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 8 : 12),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.35),
        builder: (sheetContext) => _CardDatePickerSheet(
          title: hint == 'cards.month'.tr()
              ? 'cards.selectMonth'.tr()
              : 'cards.selectYear'.tr(),
          items: items.where((item) => item != hint).toList(),
          selectedValue: hasValue ? value : null,
          onSelect: (selected) {
            onChanged(selected);
            Navigator.pop(sheetContext);
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(compact ? 8 : 12),
          border: Border.all(color: borderColor ?? const Color(0xFFE0E0E0)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 13 : 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: TextStyle(
                  fontSize: compact ? 13 : 14,
                  color: hasValue ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 18 : 20,
              color: hasValue ? AppColors.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardDatePickerSheet extends StatelessWidget {
  const _CardDatePickerSheet({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelect,
  });

  final String title;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.82,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.primaryColor,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == selectedValue;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelect(item),
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withValues(alpha: 0.08)
                                : const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor.withValues(
                                      alpha: 0.5,
                                    )
                                  : const Color(0xFFE8E8E8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : const Color(0xFF444444),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryColor,
                                  size: 21,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
