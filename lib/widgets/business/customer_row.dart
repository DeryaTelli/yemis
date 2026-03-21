import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/business/reservation_model.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import 'status_chip.dart';
import 'action_btn.dart';

class CustomerRow extends StatelessWidget {
  final ReservationModel reservation;
  final bool isApproved;
  final bool isRejected;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const CustomerRow({
    super.key,
    required this.reservation,
    required this.isApproved,
    required this.isRejected,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: const Color(0xFFFFF3E0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          // İsim
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: reservation.customerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  TextSpan(
                    text: ' ${LocaleKeys.businessApprovals_reservedBy.tr()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Butonlar
          if (isApproved)
            StatusChip(label: LocaleKeys.businessApprovals_approved.tr(), color: Colors.green)
          else if (isRejected)
            StatusChip(label: LocaleKeys.businessApprovals_rejected.tr(), color: Colors.red)
          else ...[
            ActionBtn(
              label: LocaleKeys.businessApprovals_approveButton.tr(),
              filled: true,
              onTap: onApprove,
            ),
            const SizedBox(width: 8),
            ActionBtn(
              label: LocaleKeys.businessApprovals_rejectButton.tr(),
              filled: false,
              onTap: onReject,
            ),
          ],
        ],
      ),
    );
  }
}
