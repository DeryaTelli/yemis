import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import 'package:yemis/viewmodels/home/volunteer_home_viewmodel.dart';
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
    final vm = _readHomeViewModel(context);
    final status = task.deliveryStatus;

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

          if (_shouldShowPendingCancel(status)) ...[
            const SizedBox(height: 10),
            _buildPersistentCancelButton(context, vm),
          ],

          // ── Volunteer Review (Only if completed) ──────────
          if (task.volunteerComment != null &&
              task.volunteerComment!.trim().isNotEmpty) ...[
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
        color: AppColors.volunteerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.volunteerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child:
                      (task.volunteerAvatar != null &&
                          task.volunteerAvatar!.isNotEmpty)
                      ? (task.volunteerAvatar!.startsWith('http')
                            ? Image.network(
                                task.volunteerAvatar!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                task.volunteerAvatar!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ))
                      : const Icon(
                          Icons.person,
                          color: AppColors.volunteerColor,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task.volunteerName ?? task.userName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        Text(
                          task.reviewCreatedAt ?? 'Bugün, 09:12',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _StarRow(rating: task.volunteerRating),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.volunteerComment!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryTextColor,
              height: 1.5,
            ),
          ),
          if (task.reviewImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: task.reviewImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      task.reviewImages[index],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
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

    final String displayName = task.title;

    final String displaySubTitle = isOwner
        ? (task.assignedVolunteerName?.trim().isNotEmpty == true
              ? '${LocaleKeys.taskTracking_volunteer.tr()}: ${task.assignedVolunteerName!}'
              : LocaleKeys.taskTracking_assignedVolunteer.tr())
        : task.location;

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
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.volunteerColor,
            ),
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
    final progress = _progressForSide;
    if (progress != null && progress.steps.isNotEmpty) {
      return _buildBackendStepper(progress.steps);
    }

    if (isOwner) {
      return _buildOwnerStepper(status);
    }
    return _buildVolunteerStepper(status);
  }

  VolunteerTaskProgress? get _progressForSide {
    return isOwner ? task.ownerProgress : task.volunteerProgress;
  }

  Widget _buildBackendStepper(List<VolunteerProgressStep> steps) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final previousStep = steps[index ~/ 2];
          return Expanded(
            child: _buildConnector(_isBackendStepCompleted(previousStep)),
          );
        }

        final stepIndex = index ~/ 2;
        final step = steps[stepIndex];
        return _buildStepCircle(
          step.index > 0 ? step.index : stepIndex + 1,
          _isBackendStepCompleted(step),
          _isBackendStepCurrent(step),
          step.label,
        );
      }),
    );
  }

  bool _isBackendStepCompleted(VolunteerProgressStep step) {
    final state = step.state.toLowerCase();
    return state == 'completed' || state == 'done' || state == 'passed';
  }

  bool _isBackendStepCurrent(VolunteerProgressStep step) {
    final state = step.state.toLowerCase();
    return state == 'current' || state == 'active';
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
    final currentStep = _ownerStepIndex(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          return Expanded(child: _buildConnector(currentStep > stepIndex));
        } else {
          final stepIndex = index ~/ 2;
          return _buildStepCircle(
            stepIndex + 1,
            currentStep > stepIndex,
            currentStep == stepIndex,
            steps[stepIndex],
          );
        }
      }),
    );
  }

  int _ownerStepIndex(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pendingOwnerApproval:
        return 0;
      case DeliveryStatus.accepted:
      case DeliveryStatus.goingToPickUp:
        return 1;
      case DeliveryStatus.ownerHandedOver:
      case DeliveryStatus.pickedUp:
        return 2;
      case DeliveryStatus.goingToShelter:
        return 3;
      case DeliveryStatus.deliveredPendingReview:
        return 4;
      case DeliveryStatus.completed:
        return 5;
      case DeliveryStatus.cancelled:
        return 0;
    }
  }

  Widget _buildVolunteerStepper(DeliveryStatus status) {
    final steps = [
      LocaleKeys.taskTracking_stepApproval.tr(),
      LocaleKeys.taskTracking_stepPickup.tr(),
      LocaleKeys.taskTracking_stepDelivery.tr(),
      LocaleKeys.taskTracking_stepResult.tr(),
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
    VolunteerHomeViewModel? vm,
    DeliveryStatus status,
  ) {
    String iconPath = 'assets/volunteerIcon/home1.png';
    String message = '';
    final backendMessage = _progressForSide?.message;

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
    if (backendMessage != null && backendMessage.trim().isNotEmpty) {
      message = backendMessage;
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
    VolunteerHomeViewModel? vm,
    DeliveryStatus status,
  ) {
    if (!isOwner && status == DeliveryStatus.pendingOwnerApproval) {
      return const SizedBox.shrink();
    }

    final progress = _progressForSide;
    if (progress != null && progress.availableActions.isNotEmpty) {
      return _buildBackendActions(context, vm, progress.availableActions);
    }

    if (status == DeliveryStatus.completed) {
      return const SizedBox.shrink();
    }

    if (!isOwner && status == DeliveryStatus.deliveredPendingReview) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: task.taskId == null
                ? null
                : vm == null
                ? null
                : () => _showVolunteerReviewDialog(context, vm, task),
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
      if (status == DeliveryStatus.pendingOwnerApproval) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _rejectOwnerTask(context, vm),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(80, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                LocaleKeys.taskTracking_btnReject.tr(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            _buildAdvanceButton(
              label: LocaleKeys.taskTracking_btnApprove.tr(),
              onPressed: () => _approveOwnerTask(context, vm),
            ),
          ],
        );
      } else if (status == DeliveryStatus.goingToPickUp) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildAdvanceButton(
              label: LocaleKeys.taskTracking_btnHandover.tr(),
              onPressed: () => _handOverOwnerTask(context, vm),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    if (task.taskId == null) {
      return const SizedBox.shrink();
    }

    if (status == DeliveryStatus.accepted) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnGoPickup.tr(),
        onPressed: vm == null ? () {} : () => vm.startPickup(task.taskId!),
      );
    } else if (status == DeliveryStatus.ownerHandedOver) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnPickedUp.tr(),
        onPressed: vm == null ? () {} : () => vm.confirmPickedUp(task.taskId!),
      );
    } else if (status == DeliveryStatus.pickedUp) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnGoShelter.tr(),
        onPressed: vm == null ? () {} : () => vm.startDelivery(task.taskId!),
      );
    } else if (status == DeliveryStatus.goingToShelter) {
      advanceBtn = _buildAdvanceButton(
        label: LocaleKeys.taskTracking_btnComplete.tr(),
        onPressed: vm == null
            ? () {}
            : () => vm.completeVolunteerTask(task.taskId!),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (advanceBtn != null) ...[advanceBtn, const SizedBox(width: 8)],
        OutlinedButton.icon(
          onPressed: vm == null
              ? null
              : () => _showCancelDialog(context, vm, task),
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

  Widget _buildBackendActions(
    BuildContext context,
    VolunteerHomeViewModel? vm,
    List<String> actions,
  ) {
    final normalizedActions = actions.map((e) => e.toLowerCase()).toSet();
    if (task.taskId == null) return const SizedBox.shrink();

    if (isOwner) {
      final buttons = <Widget>[];

      if (normalizedActions.contains('reject')) {
        buttons.add(
          OutlinedButton(
            onPressed: () => _rejectOwnerTask(context, vm),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(80, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              LocaleKeys.taskTracking_btnReject.tr(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }

      if (normalizedActions.contains('approve')) {
        buttons.add(
          _buildAdvanceButton(
            label: LocaleKeys.taskTracking_btnApprove.tr(),
            onPressed: () => _approveOwnerTask(context, vm),
          ),
        );
      }

      if (normalizedActions.contains('mark_handed_over') ||
          normalizedActions.contains('hand_over') ||
          normalizedActions.contains('handover')) {
        buttons.add(
          _buildAdvanceButton(
            label: LocaleKeys.taskTracking_btnHandover.tr(),
            onPressed: () => _handOverOwnerTask(context, vm),
          ),
        );
      }

      return _buildActionRow(buttons);
    }

    final buttons = <Widget>[];
    if (vm == null) return const SizedBox.shrink();

    if (normalizedActions.contains('start_pickup')) {
      buttons.add(
        _buildAdvanceButton(
          label: LocaleKeys.taskTracking_btnGoPickup.tr(),
          onPressed: () => vm.startPickup(task.taskId!),
        ),
      );
    }
    if (normalizedActions.contains('mark_picked_up')) {
      buttons.add(
        _buildAdvanceButton(
          label: LocaleKeys.taskTracking_btnPickedUp.tr(),
          onPressed: () => vm.confirmPickedUp(task.taskId!),
        ),
      );
    }
    if (normalizedActions.contains('start_delivery')) {
      buttons.add(
        _buildAdvanceButton(
          label: LocaleKeys.taskTracking_btnGoShelter.tr(),
          onPressed: () => vm.startDelivery(task.taskId!),
        ),
      );
    }
    if (normalizedActions.contains('complete')) {
      buttons.add(
        _buildAdvanceButton(
          label: LocaleKeys.taskTracking_btnComplete.tr(),
          onPressed: () => vm.completeVolunteerTask(task.taskId!),
        ),
      );
    }
    if (normalizedActions.contains('review')) {
      buttons.add(
        _buildAdvanceButton(
          label: LocaleKeys.taskTracking_btnLeaveReview.tr(),
          onPressed: () => _showVolunteerReviewDialog(context, vm, task),
        ),
      );
    }
    if (normalizedActions.contains('cancel')) {
      buttons.add(
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
      );
    }

    return _buildActionRow(buttons);
  }

  Widget _buildActionRow(List<Widget> buttons) {
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Flexible(child: buttons[i]),
        ],
      ],
    );
  }

  bool _shouldShowPendingCancel(DeliveryStatus status) {
    return !isOwner && status == DeliveryStatus.pendingOwnerApproval;
  }

  Widget _buildPersistentCancelButton(
    BuildContext context,
    VolunteerHomeViewModel? vm,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: OutlinedButton.icon(
        onPressed: vm == null
            ? null
            : () => _showCancelDialog(context, vm, task),
        icon: const Icon(Icons.close_rounded, size: 14),
        label: Text(LocaleKeys.taskTracking_btnCancel.tr()),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade200, width: 1.1),
          backgroundColor: const Color(0xFFFFF7F7),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          minimumSize: const Size(0, 34),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
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

  VolunteerHomeViewModel? _readHomeViewModel(BuildContext context) {
    try {
      return context.read<VolunteerHomeViewModel>();
    } catch (_) {
      return null;
    }
  }

  VolunteerListingDetailViewModel? _readDetailViewModel(BuildContext context) {
    try {
      return context.read<VolunteerListingDetailViewModel>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _approveOwnerTask(
    BuildContext context,
    VolunteerHomeViewModel? homeVm,
  ) async {
    final taskId = task.taskId;
    if (taskId == null) return;
    final detailVm = _readDetailViewModel(context);
    final messenger = ScaffoldMessenger.of(context);
    bool success = false;
    if (detailVm != null) {
      success = await detailVm.acceptVolunteer();
    } else {
      success = await homeVm?.approveOwnerTask(taskId) ?? false;
    }
    _showOwnerActionFeedback(
      messenger,
      success: success,
      successMessage: 'Gonullu onaylandi.',
      failureMessage: 'Gonullu onaylanamadi.',
    );
  }

  Future<void> _rejectOwnerTask(
    BuildContext context,
    VolunteerHomeViewModel? homeVm,
  ) async {
    final taskId = task.taskId;
    if (taskId == null) return;
    final detailVm = _readDetailViewModel(context);
    final messenger = ScaffoldMessenger.of(context);
    bool success = false;
    if (detailVm != null) {
      success = await detailVm.rejectVolunteer();
    } else {
      success = await homeVm?.rejectOwnerTask(taskId) ?? false;
    }
    _showOwnerActionFeedback(
      messenger,
      success: success,
      successMessage: 'Gonullu talebi reddedildi.',
      failureMessage: 'Gonullu reddedilemedi.',
    );
  }

  Future<void> _handOverOwnerTask(
    BuildContext context,
    VolunteerHomeViewModel? homeVm,
  ) async {
    final taskId = task.taskId;
    if (taskId == null) return;
    final detailVm = _readDetailViewModel(context);
    final messenger = ScaffoldMessenger.of(context);
    bool success = false;
    if (detailVm != null) {
      success = await detailVm.ownerHandover();
    } else {
      success = await homeVm?.handOverOwnerTask(taskId) ?? false;
    }
    _showOwnerActionFeedback(
      messenger,
      success: success,
      successMessage: 'Ilan gonulluye teslim edildi olarak isaretlendi.',
      failureMessage: 'Teslim bilgisi gonderilemedi.',
    );
  }

  void _showOwnerActionFeedback(
    ScaffoldMessengerState messenger, {
    required bool success,
    required String successMessage,
    required String failureMessage,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : failureMessage),
        backgroundColor: success ? AppColors.volunteerColor : Colors.red,
      ),
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
        vm.cancelVolunteerTask(task.taskId ?? task.id);
      },
    );
  }

  void _showVolunteerReviewDialog(
    BuildContext context,
    VolunteerHomeViewModel vm,
    VolunteerListing task,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _VolunteerReviewDialog(vm: vm, task: task),
    );
  }
}

class _VolunteerReviewDialog extends StatefulWidget {
  const _VolunteerReviewDialog({required this.vm, required this.task});

  final VolunteerHomeViewModel vm;
  final VolunteerListing task;

  @override
  State<_VolunteerReviewDialog> createState() => _VolunteerReviewDialogState();
}

class _VolunteerReviewDialogState extends State<_VolunteerReviewDialog> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  int _rating = 5;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickReviewImage(ImageSource source) async {
    if (_selectedImages.length >= 3 || _isSubmitting) return;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedImages.add(picked);
      _errorText = null;
    });
  }

  Future<void> _submit() async {
    final comment = _controller.text.trim();
    if (comment.isEmpty) {
      setState(() {
        _errorText = LocaleKeys.taskTracking_volunteerComment.tr();
      });
      return;
    }
    if (comment.length < 15) {
      setState(() {
        _errorText = 'Yorum en az 15 karakter olmali.';
      });
      return;
    }
    if (_selectedImages.isEmpty) {
      setState(() {
        _errorText = 'En az 1 foto eklemelisin.';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await widget.vm.submitVolunteerReview(
      widget.task.taskId!,
      rating: _rating,
      comment: comment,
      imagePaths: _selectedImages.map((image) => image.path).toList(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorText = 'Yorum gonderilemedi.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.taskTracking_btnLeaveReview.tr(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 2,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() => _rating = value),
                    icon: Icon(
                      value <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              TextField(
                controller: _controller,
                enabled: !_isSubmitting,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: LocaleKeys.taskTracking_volunteerComment.tr(),
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _pickReviewImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Foto Ekle'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _pickReviewImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Kamera'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_selectedImages.length, (index) {
                    final image = _selectedImages[index];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(image.path),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: _isSubmitting
                                ? null
                                : () => setState(() {
                                    _selectedImages.removeAt(index);
                                  }),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              const SizedBox(height: 6),
              Text(
                _selectedImages.isEmpty
                    ? 'En az 1 foto zorunlu.'
                    : '${_selectedImages.length}/3 foto secildi',
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedImages.isEmpty
                      ? Colors.red.shade400
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(LocaleKeys.common_cancel.tr()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(LocaleKeys.common_save.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFC107),
            size: 16,
          );
        } else if (i < rating) {
          return const Icon(
            Icons.star_half_rounded,
            color: Color(0xFFFFC107),
            size: 16,
          );
        } else {
          return const Icon(
            Icons.star_outline_rounded,
            color: Color(0xFFFFC107),
            size: 16,
          );
        }
      }),
    );
  }
}
