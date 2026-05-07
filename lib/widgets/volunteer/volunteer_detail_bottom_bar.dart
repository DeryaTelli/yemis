import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
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
          Text(
            LocaleKeys.volunteerDetail_freeLabel.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTextColor,
            ),
          ),
          const Spacer(),

          // Gönüllü Ol
          GestureDetector(
            onTap: vm.isVolunteering
                ? null
                : () async {
                    final success = await vm.becomeVolunteer();
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            LocaleKeys.volunteerDetail_volunteerSuccess.tr(
                              namedArgs: {'title': listing.title},
                            ),
                          ),
                          backgroundColor: AppColors.volunteerColor,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else if (vm.volunteerError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(vm.volunteerError!),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: vm.isVolunteering
                    ? null
                    : AppColors.volunteerBackgroundGradient,
                color: vm.isVolunteering
                    ? AppColors.volunteerColor.withValues(alpha: 0.4)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: vm.isVolunteering
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      LocaleKeys.volunteerDetail_becomeButton.tr(),
                      style: const TextStyle(
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
