import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    this.unselectedColor = const Color(0xFF4F4F4F),
  });

  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
