import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/volunteer/volunteer_listing.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import 'package:yemis/viewmodels/home/volunteer_home_viewmodel.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import 'package:yemis/widgets/volunteer/volunteer_cancel_dialog.dart';

class VolunteerTaskTrackingCard extends StatelessWidget {
  const VolunteerTaskTrackingCard({super.key, required this.task});

  final VolunteerListing task;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          _buildHeader(context, status),

          const SizedBox(height: 12),

          // ── Progress Stepper ────────────────────────────────
          _buildStepper(status),

          const SizedBox(height: 12),

          // ── Message & Action Box ────────────────────────────
          _buildActionBox(context, vm, status),

          // ── Footer Info (Only if completed) ─────────────────
          if (isCompleted) ...[const SizedBox(height: 12)],
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
      case DeliveryStatus.onTheWay:
        headerIcon = 'assets/volunteerIcon/car.png';
        break;
      case DeliveryStatus.pickedUp:
        headerIcon = 'assets/volunteerIcon/car.png';
        break;
      default:
        headerIcon = 'assets/volunteerIcon/home1.png';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Image.asset(
              headerIcon,
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) => const Icon(Icons.home_rounded),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
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
                      task.location,
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: AppColors.volunteerColor),
            SizedBox(width: 4),
            Text(
              'Teslim edildi!',
              style: TextStyle(
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepItem(
          step: 1,
          label: 'Almaya gidiyorum',
          subLabel: status.index > DeliveryStatus.onTheWayToPickUp.index
              ? 'Tamamlandı'
              : (status == DeliveryStatus.onTheWayToPickUp
                    ? 'Devam ediyor'
                    : 'Bekliyor'),
          statusColor: status.index >= DeliveryStatus.onTheWayToPickUp.index
              ? AppColors.volunteerColor
              : Colors.grey.shade300,
          isCompleted: status.index > DeliveryStatus.onTheWayToPickUp.index,
          isCurrent: status == DeliveryStatus.onTheWayToPickUp,
        ),
        _buildConnector(status.index >= DeliveryStatus.onTheWayToPickUp.index),
        _buildStepItem(
          step: 2,
          label: 'İlanı aldım',
          subLabel: status.index > DeliveryStatus.pickedUp.index
              ? 'Tamamlandı'
              : (status == DeliveryStatus.pickedUp
                    ? 'Devam ediyor'
                    : 'Bekliyor'),
          statusColor: status.index >= DeliveryStatus.pickedUp.index
              ? AppColors.volunteerColor
              : Colors.grey.shade300,
          isCompleted: status.index > DeliveryStatus.pickedUp.index,
          isCurrent: status == DeliveryStatus.pickedUp,
        ),
        _buildConnector(status.index >= DeliveryStatus.pickedUp.index),
        _buildStepItem(
          step: 3,
          label: 'Barınağa götürüyorum',
          subLabel: status.index > DeliveryStatus.onTheWay.index
              ? 'Tamamlandı'
              : (status == DeliveryStatus.onTheWay
                    ? 'Devam ediyor'
                    : 'Bekliyor'),
          statusColor: status.index >= DeliveryStatus.onTheWay.index
              ? AppColors.volunteerColor
              : Colors.grey.shade300,
          isCompleted: status.index > DeliveryStatus.onTheWay.index,
          isCurrent: status == DeliveryStatus.onTheWay,
        ),
        _buildConnector(status.index >= DeliveryStatus.onTheWay.index),
        _buildStepItem(
          step: 4,
          label: 'Tamamlandı',
          subLabel: status == DeliveryStatus.completed
              ? 'Tamamlandı'
              : 'Bekliyor',
          statusColor: status == DeliveryStatus.completed
              ? AppColors.volunteerColor
              : Colors.grey.shade300,
          isCompleted: status == DeliveryStatus.completed,
        ),
      ],
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
      width: 28,
      height: 1,
      margin: const EdgeInsets.only(top: 16), // Center with 32px height circle
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
    String iconPath;
    String message;

    switch (status) {
      case DeliveryStatus.completed:
        iconPath = 'assets/volunteerIcon/kalp.png';
        message =
            'Görevi başarıyla tamamladın! 🥳 Deneyimini paylaşarak başkalarına ilham verebilirsin.';
        break;
      case DeliveryStatus.onTheWay:
        iconPath = 'assets/volunteerIcon/lokasyon.png';
        message =
            'Yemeği barınağa götürüyorsunuz. Teslim ettikten sonra görevi tamamlayabilirsiniz.';
        break;
      case DeliveryStatus.pickedUp:
        iconPath = 'assets/volunteerIcon/paket.png';
        message =
            'Yemeği ilanın sahibinden aldınız. Şimdi barınağa doğru yola çıkabilirsiniz.';
        break;
      case DeliveryStatus.onTheWayToPickUp:
        iconPath = 'assets/volunteerIcon/car.png';
        message =
            'Yemeği teslim almak için yola çıktınız. İlan sahibine ulaştığınızda bildirin.';
        break;
      default:
        iconPath = 'assets/volunteerIcon/home1.png';
        message =
            'Görevi kabul ettiniz. Yemeği teslim almak için yola çıkabilirsiniz.';
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
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
            label: const Text('Yorum Yap'),
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
    if (status == DeliveryStatus.pending) {
      advanceBtn = _buildAdvanceButton(
        label: 'Almaya Git',
        onPressed: () =>
            vm.updateTaskStatus(task.taskId!, DeliveryStatus.onTheWayToPickUp),
      );
    } else if (status == DeliveryStatus.onTheWayToPickUp) {
      advanceBtn = _buildAdvanceButton(
        label: 'İlanı Aldım',
        onPressed: () =>
            vm.updateTaskStatus(task.taskId!, DeliveryStatus.pickedUp),
      );
    } else if (status == DeliveryStatus.pickedUp) {
      advanceBtn = _buildAdvanceButton(
        label: 'Yola Çık',
        onPressed: () =>
            vm.updateTaskStatus(task.taskId!, DeliveryStatus.onTheWay),
      );
    } else if (status == DeliveryStatus.onTheWay) {
      advanceBtn = _buildAdvanceButton(
        label: 'Teslim Et',
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
          label: const Text('İptal Et'),
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
