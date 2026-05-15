import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import 'package:yemis/viewmodels/home/volunteer_home_viewmodel.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import 'package:yemis/widgets/volunteer/volunteer_cancel_dialog.dart';
import '../../viewmodels/volunteer/volunteer_listing_detail_viewmodel.dart';

class VolunteerTaskTrackingCard extends StatelessWidget {
  const VolunteerTaskTrackingCard({
    super.key,
    required this.task,
    this.isOwner = false,
  });

  final VolunteerListing task;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VolunteerHomeViewModel>();
    final status = task.deliveryStatus;
    final isCompleted = status == DeliveryStatus.completed;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header ──────────────────────────────────────────
          _buildHeader(context, status),

          const SizedBox(height: 12),

          // ── Progress Stepper ────────────────────────────────
          _buildStepper(status),

          const SizedBox(height: 12),

          // ── Message & Action Box ────────────────────────────
          _buildActionBox(context, vm, status),

          // ── Volunteer Review (Only if completed) ──────────
          if (status == DeliveryStatus.completed &&
              task.volunteerComment != null) ...[
            const SizedBox(height: 16),
            _buildVolunteerReviewBox(),
          ],
        ],
      ),
    );
  }

  Widget _buildVolunteerReviewBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.volunteerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.taskTracking_volunteerComment.tr(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.volunteerColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"${task.volunteerComment}"',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DeliveryStatus status) {
    String headerIcon;
    switch (status) {
      case DeliveryStatus.completed:
        headerIcon = 'assets/volunteerIcon/home2.png';
        break;
      case DeliveryStatus.goingToPickUp:
      case DeliveryStatus.goingToShelter:
        headerIcon = 'assets/volunteerIcon/car.png';
        break;
      case DeliveryStatus.pickedUp:
        headerIcon = 'assets/volunteerIcon/car.png';
        break;
      default:
        headerIcon = 'assets/volunteerIcon/home1.png';
    }

    final String displayName = isOwner
        ? (task.assignedVolunteerName ?? LocaleKeys.taskTracking_assignedVolunteer.tr())
        : task.title;
    final String? displayAvatar = isOwner ? task.assignedVolunteerAvatar : null;
    final String displaySubTitle = isOwner ? LocaleKeys.taskTracking_volunteer.tr() : task.location;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: task.imageUrl.isEmpty
                ? Center(
                    child: Image.asset(
                      headerIcon,
                      width: 32,
                      height: 32,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.home_rounded, color: Colors.grey),
                    ),
                  )
                : (task.imageUrl.startsWith('http')
                      ? Image.network(
                          task.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Center(
                            child: Image.asset(
                              headerIcon,
                              width: 32,
                              height: 32,
                            ),
                          ),
                        )
                      : Image.asset(
                          task.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Center(
                            child: Image.asset(
                              headerIcon,
                              width: 32,
                              height: 32,
                            ),
                          ),
                        )),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      displaySubTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.regular14Grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(DeliveryStatus status) {
    if (status == DeliveryStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.volunteerColor),
            const SizedBox(width: 4),
            Text(
              LocaleKeys.taskTracking_deliveredExclamation.tr(),
              style: const TextStyle(
                color: AppColors.volunteerColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Mock "Kalan süre" logic
    String remainingTime = "2sa 15dk";
    if (task.pickupEndTime != null) {
      final diff = task.pickupEndTime!.difference(DateTime.now());
      if (diff.isNegative) {
        remainingTime = "Süre Doldu";
      } else {
        remainingTime = "${diff.inHours}sa ${diff.inMinutes % 60}dk";
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 14,
            color: Color(0xFFE65100),
          ),
          const SizedBox(width: 4),
          Text(
            remainingTime,
            style: const TextStyle(
              color: Color(0xFFE65100),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(DeliveryStatus status) {
    if (isOwner) {
      return _buildOwnerStepper(status);
    }
    return _buildVolunteerStepper(status);
  }

  Widget _buildOwnerStepper(DeliveryStatus status) {
    final steps = [
      LocaleKeys.taskTracking_waitingApproval.tr(),
      LocaleKeys.taskTracking_stepApproved.tr(),
      LocaleKeys.taskTracking_given.tr(),
      LocaleKeys.taskTracking_delivering.tr(),
      LocaleKeys.taskTracking_stepCompleted.tr(),
      LocaleKeys.taskTracking_stepReview.tr(),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Bağlayıcı çizgi
          final stepIndex = index ~/ 2;
          bool isActive = false;
          switch (stepIndex) {
            case 0:
              isActive =
                  status.index > DeliveryStatus.pendingOwnerApproval.index;
              break;
            case 1:
              isActive = status.index > DeliveryStatus.goingToPickUp.index;
              break;
            case 2:
              isActive = status.index > DeliveryStatus.ownerHandedOver.index;
              break;
            case 3:
              isActive = status.index > DeliveryStatus.goingToShelter.index;
              break;
            case 4:
              isActive = status == DeliveryStatus.completed;
              break;
          }
          return Expanded(child: _buildConnector(isActive));
        } else {
          // Çember
          final stepIndex = index ~/ 2;
          bool isCompleted = false;
          bool isCurrent = false;

          switch (stepIndex) {
            case 0:
              isCurrent = status == DeliveryStatus.pendingOwnerApproval;
              isCompleted =
                  status.index > DeliveryStatus.pendingOwnerApproval.index;
              break;
            case 1:
              isCurrent =
                  status == DeliveryStatus.accepted ||
                  status == DeliveryStatus.goingToPickUp;
              isCompleted = status.index > DeliveryStatus.goingToPickUp.index;
              break;
            case 2:
              isCurrent = status == DeliveryStatus.ownerHandedOver;
              isCompleted = status.index > DeliveryStatus.ownerHandedOver.index;
              break;
            case 3:
              isCurrent =
                  status == DeliveryStatus.goingToShelter ||
                  status == DeliveryStatus.pickedUp;
              isCompleted = status.index > DeliveryStatus.goingToShelter.index;
              break;
            case 4:
              isCurrent = status == DeliveryStatus.deliveredPendingReview;
              isCompleted = status == DeliveryStatus.completed;
              break;
            case 5:
              isCurrent = status == DeliveryStatus.completed;
              isCompleted = status == DeliveryStatus.completed;
              break;
          }
          return _buildStepCircle(
            stepIndex + 1,
            isCompleted,
            isCurrent,
            steps[stepIndex],
          );
        }
      }),
    );
  }

  Widget _buildVolunteerStepper(DeliveryStatus status) {
    final steps = [
      LocaleKeys.taskTracking_stepApproval.tr(), 
      LocaleKeys.taskTracking_stepPickup.tr(), 
      LocaleKeys.taskTracking_stepDelivery.tr(), 
      LocaleKeys.taskTracking_stepResult.tr()
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Bağlayıcı çizgi
          final stepIndex = index ~/ 2;
          bool isActive = false;
          switch (stepIndex) {
            case 0:
              isActive = status.index >= DeliveryStatus.goingToPickUp.index;
              break;
            case 1:
              isActive = status.index >= DeliveryStatus.pickedUp.index;
              break;
            case 2:
              isActive =
                  status.index >= DeliveryStatus.deliveredPendingReview.index;
              break;
          }
          return Expanded(child: _buildConnector(isActive));
        } else {
          // Çember
          final stepIndex = index ~/ 2;
          bool isCompleted = false;
          bool isCurrent = false;

          switch (stepIndex) {
            case 0:
              isCurrent =
                  status == DeliveryStatus.pendingOwnerApproval ||
                  status == DeliveryStatus.accepted;
              isCompleted = status.index >= DeliveryStatus.goingToPickUp.index;
              break;
            case 1:
              isCurrent =
                  status == DeliveryStatus.goingToPickUp ||
                  status == DeliveryStatus.ownerHandedOver;
              isCompleted = status.index >= DeliveryStatus.pickedUp.index;
              break;
            case 2:
              isCurrent = status == DeliveryStatus.goingToShelter;
              isCompleted =
                  status.index >= DeliveryStatus.deliveredPendingReview.index;
              break;
            case 3:
              isCurrent = status == DeliveryStatus.deliveredPendingReview;
              isCompleted = status == DeliveryStatus.completed;
              break;
          }
          return _buildStepCircle(
            stepIndex + 1,
            isCompleted,
            isCurrent,
            steps[stepIndex],
          );
        }
      }),
    );
  }

  Widget _buildStepCircle(
    int step,
    bool isCompleted,
    bool isCurrent,
    String label,
  ) {
    return SizedBox(
      width: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppColors.volunteerColor
                  : Colors.white,
              shape: BoxShape.circle,
              border: !isCompleted && !isCurrent
                  ? Border.all(color: Colors.grey.shade300, width: 1.5)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: isCompleted || isCurrent
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isCompleted || isCurrent
                  ? AppColors.volunteerColor
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int step,
    required String label,
    required String subLabel,
    required Color statusColor,
    required bool isCompleted,
    bool isCurrent = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent ? statusColor : Colors.white,
              shape: BoxShape.circle,
              border: !isCompleted && !isCurrent
                  ? Border.all(color: Colors.grey.shade300, width: 1.5)
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : Text(
                      '$step',
                      style: TextStyle(
                        fontFamily: "Nunito",
                        color: isCurrent ? Colors.white : Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 11,
              height: 1.1,
              fontWeight: isCompleted || isCurrent
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: isCompleted || isCurrent
                  ? const Color(0xFF2E7D32)
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subLabel,
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      height: 1.5,
      margin: const EdgeInsets.only(
        top: 14,
      ), // Align with center of 28px circle
      color: isActive
          ? AppColors.volunteerColor
          : const Color.fromARGB(255, 179, 179, 179),
    );
  }

  Widget _buildActionBox(
    BuildContext context,
    VolunteerHomeViewModel vm,
    DeliveryStatus status,
  ) {
    String iconPath = 'assets/volunteerIcon/home1.png';
    String message = '';

    switch (status) {
      case DeliveryStatus.completed:
        iconPath = 'assets/volunteerIcon/kalp.png';
        message = isOwner
            ? LocaleKeys.taskTracking_completedOwner.tr()
            : LocaleKeys.taskTracking_completedVolunteer.tr();
        break;
      case DeliveryStatus.deliveredPendingReview:
        iconPath = 'assets/volunteerIcon/paket.png';
        message = isOwner
            ? LocaleKeys.taskTracking_deliveredPendingReviewOwner.tr()
            : LocaleKeys.taskTracking_deliveredPendingReviewVolunteer.tr();
        break;
      case DeliveryStatus.goingToShelter:
        iconPath = 'assets/volunteerIcon/lokasyon.png';
        message = isOwner
            ? LocaleKeys.taskTracking_goingToShelterOwner.tr()
            : LocaleKeys.taskTracking_goingToShelterVolunteer.tr();
        break;
      case DeliveryStatus.pickedUp:
        iconPath = 'assets/volunteerIcon/paket.png';
        message = isOwner
            ? LocaleKeys.taskTracking_pickedUpOwner.tr()
            : LocaleKeys.taskTracking_pickedUpVolunteer.tr();
        break;
      case DeliveryStatus.ownerHandedOver:
        iconPath = 'assets/volunteerIcon/paket.png';
        message = isOwner
            ? LocaleKeys.taskTracking_ownerHandedOverOwner.tr()
            : LocaleKeys.taskTracking_ownerHandedOverVolunteer.tr();
        break;
      case DeliveryStatus.goingToPickUp:
        iconPath = 'assets/volunteerIcon/car.png';
        message = isOwner
            ? LocaleKeys.taskTracking_goingToPickUpOwner.tr()
            : LocaleKeys.taskTracking_goingToPickUpVolunteer.tr();
        break;
      case DeliveryStatus.accepted:
        iconPath = 'assets/volunteerIcon/home1.png';
        message = isOwner
            ? LocaleKeys.taskTracking_acceptedOwner.tr()
            : LocaleKeys.taskTracking_acceptedVolunteer.tr();
        break;
      case DeliveryStatus.pendingOwnerApproval:
        iconPath = 'assets/volunteerIcon/home1.png';
        message = isOwner
            ? LocaleKeys.taskTracking_pendingOwner.tr()
            : LocaleKeys.taskTracking_pendingVolunteer.tr();
        break;
      default:
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => const Icon(Icons.info_outline),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 126, 126, 126),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          _buildPrimaryAction(context, vm, status),
        ],
      ),
    );
  }

  Widget _buildPrimaryAction(
    BuildContext context,
    VolunteerHomeViewModel vm,
    DeliveryStatus status,
  ) {
    if (status == DeliveryStatus.completed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.volunteerDetail,
                arguments: task,
              ).then((_) {
                vm.onReviewSubmitted();
              });
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 12),
            label: Text(LocaleKeys.taskTracking_btnLeaveReview.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.volunteerColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              minimumSize: const Size(100, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: CustomTextStyles.semiBold13White,
            ),
          ),
        ],
      );
    }

    Widget? advanceBtn;

    if (isOwner) {
      final detailVm = context.read<VolunteerListingDetailViewModel>();
      if (status == DeliveryStatus.pendingOwnerApproval) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => detailVm.rejectVolunteer(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(80, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(LocaleKeys.taskTracking_btnReject.tr(), style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            _buildAdvanceButton(
              label: LocaleKeys.taskTracking_btnApprove.tr(),
              onPressed: () => detailVm.acceptVolunteer(),
            ),
          ],
        );
      } else if (status == DeliveryStatus.goingToPickUp) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildAdvanceButton(
              label: LocaleKeys.taskTracking_btnHandover.tr(),
              onPressed: () => detailVm.ownerHandover(),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    if (status == DeliveryStatus.accepted) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnGoPickup.tr(),
        onPressed: () => vm.startPickup(task.taskId!),
      );
    } else if (status == DeliveryStatus.ownerHandedOver) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnPickedUp.tr(),
        onPressed: () => vm.confirmPickedUp(task.taskId!),
      );
    } else if (status == DeliveryStatus.pickedUp) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnGoShelter.tr(),
        onPressed: () => vm.startDelivery(task.taskId!),
      );
    } else if (status == DeliveryStatus.goingToShelter) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnComplete.tr(),
        onPressed: () => vm.completeVolunteerTask(task.taskId!),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (advanceBtn != null) ...[advanceBtn, const SizedBox(width: 8)],
        OutlinedButton.icon(
          onPressed: () => _showCancelDialog(context, vm, task),
          icon: const Icon(Icons.close, size: 12, color: Colors.red),
          label: Text(LocaleKeys.taskTracking_btnCancel.tr()),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red, width: 1),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            minimumSize: const Size(100, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: CustomTextStyles.semiBold13White.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvanceButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.volunteerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        minimumSize: const Size(100, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: CustomTextStyles.semiBold13White,
      ),
      child: Text(label),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    VolunteerHomeViewModel vm,
    VolunteerListing task,
  ) {
    VolunteerCancelDialog.show(
      context,
      onConfirm: () {
        vm.cancelVolunteerTask(task.taskId!);
      },
    );
  }
}
