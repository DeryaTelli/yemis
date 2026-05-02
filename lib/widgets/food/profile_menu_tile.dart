import 'package:flutter/material.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.showTrailing = true,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final bool isDestructive;
  final bool showTrailing;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final color = isDestructive ? const Color(0xFFE53935) : (iconColor ?? themeColor);
    final textColor = isDestructive ? const Color(0xFFE53935) : const Color(0xFF555555);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (showTrailing)
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: iconColor ?? themeColor,
              ),
          ],
        ),
      ),
    );
  }
}
