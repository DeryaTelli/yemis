import 'package:flutter/material.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../utils/routes/app_routes.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool isLocationTitle;
  final VoidCallback? onLocationTap;
  final AppModuleType moduleType;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.isLocationTitle = false,
    this.onLocationTap,
    this.moduleType = AppModuleType.food,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleTextStyle: CustomTextStyles.orelegaOne32White,
      title: isLocationTitle ? _buildLocationTitle(context) : Text(title),
    );
  }

  Widget _buildLocationTitle(BuildContext context) {
    return GestureDetector(
      onTap:
          onLocationTap ??
          () => Navigator.pushNamed(
            context,
            AppRoutes.location,
            arguments: {'returnToSender': true, 'moduleType': moduleType},
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lokasyon ikonu (beyaz daire içinde)
          Container(
            width: 28,
            height: 28,
            child: Image.asset('assets/foodIcon/locationSelect.png'),
          ),
          const SizedBox(width: 6),
          // "Lokasyon Seç" + şehir adı
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasyon Seç',
                  style: CustomTextStyles.extraBold16DarkGrey,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title.split('/').first.trim(),
                    style: CustomTextStyles.semiBold16Grey,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF4F4F4F),
            size: 24,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
