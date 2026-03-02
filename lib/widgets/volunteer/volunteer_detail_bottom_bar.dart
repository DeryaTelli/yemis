import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/volunteer/volunteer_detail_viewmodel.dart';

class VolunteerDetailBottomBar extends StatelessWidget {
  const VolunteerDetailBottomBar({super.key, required this.vm});

  final VolunteerDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    final listing = vm.listing;
    if (listing == null) return const SizedBox();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ücretsiz text
          const Text(
            'Ücretsiz',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const Spacer(),

          // Gönüllü Ol
          GestureDetector(
            onTap: () async {
              await vm.volunteer();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${listing.title} için gönüllü oldunuz. Teşekkürler!',
                    ),
                    backgroundColor: AppColors.volunteerColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.volunteerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Gönüllü Ol',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
