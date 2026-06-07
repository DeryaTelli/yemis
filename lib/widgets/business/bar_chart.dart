import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class BarChart extends StatelessWidget {
  final List<double> data;
  final List<String> days;

  const BarChart({super.key, required this.data, required this.days});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty ? 0.0 : data.reduce(max);
    return LayoutBuilder(
      builder: (context, constraints) {
        final barAreaWidth = constraints.maxWidth / data.length;
        final barWidth = barAreaWidth * 0.45;
        final chartHeight = constraints.maxHeight - 24; // reserve label space

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (i) {
                  final fraction = maxVal > 0 ? data[i] / maxVal : 0.0;
                  final percentage = (fraction * 100).round();
                  return Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: chartHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: barWidth,
                              height: (chartHeight - 18) * fraction,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryButtonGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                days.length,
                (i) => Expanded(
                  child: Center(
                    child: Text(
                      days[i],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
