import 'package:flutter/material.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';
import 'wheel_column.dart';

class TimeWheelSection extends StatelessWidget {
  const TimeWheelSection({super.key, required this.vm});
  final BusinessAddOrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Row(
            children: [
              WheelColumn(
                count: 12,
                initialItem: vm.selectedHour - 1,
                labelBuilder: (i) => '${i + 1}',
                onChanged: vm.onHourChanged,
              ),
              WheelColumn(
                count: 60,
                initialItem: vm.selectedMinute,
                labelBuilder: (i) => i.toString().padLeft(2, '0'),
                onChanged: vm.onMinuteChanged,
              ),
              WheelColumn(
                count: 2,
                initialItem: vm.isAm ? 0 : 1,
                labelBuilder: (i) => i == 0 ? 'AM' : 'PM',
                onChanged: vm.setAmPm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
