import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class WheelColumn extends StatelessWidget {
  const WheelColumn({
    super.key,
    required this.count,
    required this.initialItem,
    required this.labelBuilder,
    required this.onChanged,
  });

  final int count;
  final int initialItem;
  final String Function(int) labelBuilder;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 40,
        diameterRatio: 1.4,
        selectionOverlay: const SizedBox.shrink(),
        onSelectedItemChanged: onChanged,
        children: List.generate(
          count,
          (i) => Center(
            child: Text(
              labelBuilder(i),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
