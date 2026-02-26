import 'package:flutter/material.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
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
      onTap:
          onLocationTap ??
          () => Navigator.pushNamed(context, AppRoutes.location),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_pin_circle_rounded,
              color: backgroundColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: CustomTextStyles.orelegaOne32White,
              overflow: TextOverflow.ellipsis,
            ),
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
