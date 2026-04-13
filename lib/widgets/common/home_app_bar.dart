import 'package:flutter/material.dart';
import '../../utils/routes/app_routes.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool isLocationTitle;
  final VoidCallback? onLocationTap;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.isLocationTitle = false,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: isLocationTitle
          ? _buildLocationTitle(context)
          : Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildLocationTitle(BuildContext context) {
    return GestureDetector(
      onTap: onLocationTap ??
          () => Navigator.pushNamed(context, AppRoutes.location),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lokasyon ikonu (beyaz daire içinde)
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_pin_circle_rounded,
              color: backgroundColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 6),

          // "Lokasyon Seç" + şehir adı
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lokasyon Seç',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  height: 1.0,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
