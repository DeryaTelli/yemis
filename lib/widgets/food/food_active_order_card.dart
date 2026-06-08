import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../models/food/food_listing.dart';
import '../../models/food/order_model.dart';
import '../../services/food/i_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../views/food/food_pickup_qr_view.dart';
import '../../views/location/navigation_view.dart';

class FoodActiveOrderCard extends StatefulWidget {
  const FoodActiveOrderCard({
    super.key,
    required this.orders,
    required this.onCancel,
    required this.onRefresh,
  });

  final List<OrderModel> orders;
  final Future<bool> Function(OrderModel order) onCancel;
  final Future<void> Function() onRefresh;

  @override
  State<FoodActiveOrderCard> createState() => _FoodActiveOrderCardState();
}

class _FoodActiveOrderCardState extends State<FoodActiveOrderCard> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void didUpdateWidget(covariant FoodActiveOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.orders.length) {
      _selectedIndex = widget.orders.isEmpty ? 0 : widget.orders.length - 1;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order =
        widget.orders[_selectedIndex.clamp(0, widget.orders.length - 1)];
    final bag = order.bag;
    final pickupTime = bag == null
        ? DateFormat(
            'dd MMMM HH:mm',
            context.locale.languageCode,
          ).format(order.orderTime)
        : '${DateFormat('dd MMMM', context.locale.languageCode).format(bag.pickupStartTime)} '
              '${DateFormat('HH:mm').format(bag.pickupStartTime)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE2C2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _Header(pickupTime: pickupTime),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: PageView.builder(
              itemCount: widget.orders.length,
              padEnds: false,
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              itemBuilder: (context, index) {
                final itemOrder = widget.orders[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 94,
                        child: _Product(
                          order: itemOrder,
                          onCancel: () =>
                              _confirmCancellation(context, itemOrder),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DetailsRow(
                        onTap: () => _openListingDetail(context, itemOrder),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 9,
                            child: _ActionButton(
                              icon: Icons.near_me_outlined,
                              label: 'foodDetail.goToLocation'.tr(),
                              filled: true,
                              onTap: () => _goToLocation(context, itemOrder),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 11,
                            child: _ActionButton(
                              icon: Icons.qr_code_2_rounded,
                              label: 'activeOrder.showQr'.tr(),
                              onTap: () => _showQr(context, itemOrder),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (widget.orders.length > 1) ...[
            const SizedBox(height: 7),
            _PageIndicator(
              count: widget.orders.length,
              selectedIndex: _selectedIndex,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    OrderModel order,
  ) async {
    final amount = (order.bag?.discountedPrice ?? 0) * order.quantityReserved;
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'activeOrder.cancelReservation'.tr(),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, _, _) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2727),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'activeOrder.cancelReservation'.tr(),
                      style: CustomTextStyles.orelegaOne28DarkGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'activeOrder.cancelConfirm'.tr(),
                      style: CustomTextStyles.regular14GreyHeight,
                    ),

                    Text(
                      amount > 0
                          ? 'activeOrder.refundAmount'.tr(
                              namedArgs: {'amount': amount.toStringAsFixed(0)},
                            )
                          : 'activeOrder.refund'.tr(),
                      style: CustomTextStyles.regular14GreyHeight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      'common.cancel'.tr(),
                      style: const TextStyle(color: AppColors.primaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(
                      'common.yes'.tr(),
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (_, animation, _, child) => Transform.scale(
        scale: animation.value,
        child: Opacity(opacity: animation.value, child: child),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await widget.onCancel(order);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'activeOrder.cancelSuccess'.tr()
              : 'activeOrder.cancelError'.tr(),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _openListingDetail(
    BuildContext context,
    OrderModel order,
  ) async {
    try {
      final listing = await context.read<IFoodService>().getFoodDetail(
        order.bagId.toString(),
      );
      if (!context.mounted) return;

      await Navigator.pushNamed(
        context,
        AppRoutes.foodDetail,
        arguments: listing,
      );
      await widget.onRefresh();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('activeOrder.detailError'.tr())));
    }
  }

  Future<void> _goToLocation(BuildContext context, OrderModel order) async {
    final bag = order.bag;
    FoodListing? listing;

    try {
      listing = await context.read<IFoodService>().getFoodDetail(
        order.bagId.toString(),
      );
    } catch (_) {
      // Sipariş yanıtındaki konum varsa detay isteği başarısız olsa da kullanılır.
    }

    if (!context.mounted) return;

    final latitude = listing?.latitude ?? bag?.latitude;
    final longitude = listing?.longitude ?? bag?.longitude;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('activeOrder.locationError'.tr())));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NavigationView(
          latitude: latitude,
          longitude: longitude,
          businessName: listing?.shopName ?? bag?.shopName ?? bag?.title ?? '',
          address:
              listing?.fullAddress ?? listing?.location ?? bag?.address ?? '',
        ),
      ),
    );
    await widget.onRefresh();
  }

  Future<void> _showQr(BuildContext context, OrderModel order) async {
    final token = order.pickupQrToken;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            order.pickupCode == null
                ? 'activeOrder.qrPreparing'.tr()
                : 'activeOrder.pickupCode'.tr(
                    namedArgs: {'code': order.pickupCode ?? ''},
                  ),
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            FoodPickupQrView(qrToken: token, pickupCode: order.pickupCode),
      ),
    );
    await widget.onRefresh();
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: index == selectedIndex ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: index == selectedIndex
                ? AppColors.primaryColor
                : const Color(0xFFFFD9AF),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.pickupTime});

  final String pickupTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFF7ED),
            border: Border.all(color: const Color(0xFFFFD4A5)),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'activeOrder.reserved'.tr(),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'activeOrder.preparingDescription'.tr(),
                style: const TextStyle(
                  color: AppColors.hintTextColor,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

class _Product extends StatelessWidget {
  const _Product({required this.order, required this.onCancel});

  final OrderModel order;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bag = order.bag;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE1BF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child: bag?.imageUrl != null && bag!.imageUrl!.isNotEmpty
                  ? Image.network(
                      bag.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _ProductPlaceholder(),
                    )
                  : const _ProductPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bag?.title ?? 'home.surpriseBox'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bag?.shopName ?? 'review.business'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.hintTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'activeOrder.quantity'.tr(
                        namedArgs: {
                          'quantity': order.quantityReserved.toString(),
                        },
                      ),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        minimumSize: const Size(68, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text('common.cancel'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  const _ProductPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF1E1),
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.primaryColor,
        size: 30,
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8EF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'activeOrder.detailTitle'.tr(),
                      style: const TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'activeOrder.detailDescription'.tr(),
                      style: const TextStyle(
                        color: AppColors.hintTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.primaryButtonGradient : null,
            color: filled ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: AppColors.primaryColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: filled ? Colors.white : AppColors.primaryColor,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled ? Colors.white : AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
