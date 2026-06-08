import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food/order_model.dart';
import '../../models/review/review_model.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/food/food_orders_history_viewmodel.dart';
import 'food_pickup_qr_view.dart';

class FoodOrdersHistoryView extends StatelessWidget {
  const FoodOrdersHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FoodOrdersHistoryBody();
  }
}

class _FoodOrdersHistoryBody extends StatefulWidget {
  const _FoodOrdersHistoryBody();

  @override
  State<_FoodOrdersHistoryBody> createState() => _FoodOrdersHistoryBodyState();
}

class _FoodOrdersHistoryBodyState extends State<_FoodOrdersHistoryBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodOrdersHistoryViewModel>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodOrdersHistoryViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text('ordersHistory.title'.tr())),
      body: RefreshIndicator(
        onRefresh: () => vm.fetchOrders(),
        color: AppColors.primaryColor,
        child: _buildBody(vm),
      ),
    );
  }

  Widget _buildBody(FoodOrdersHistoryViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'ordersHistory.error'.tr(
                  namedArgs: {'message': vm.errorMessage ?? ''},
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.fetchOrders(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ordersHistory.retry'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 44,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ordersHistory.emptyTitle'.tr(),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ordersHistory.emptyDescription'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.hintTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = vm.orders[index];
        return _buildOrderCard(order, vm.reviewForOrder(order.id));
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, ReviewModel? review) {
    final bag = order.bag;
    final shopName = bag?.shopName ?? 'ordersHistory.unknownBusiness'.tr();
    final bagTitle = bag?.title ?? 'home.surpriseBox'.tr();
    final formattedDate = DateFormat(
      'dd.MM.yyyy, HH:mm',
    ).format(order.orderTime);
    final status = order.orderStatus.toLowerCase();

    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFFF9800); // Turuncu
        statusText = 'ordersHistory.status.pending'.tr();
        break;
      case 'arrived':
        statusColor = const Color(0xFF2196F3); // Mavi
        statusText = 'ordersHistory.status.arrived'.tr();
        break;
      case 'picked_up':
        statusColor = const Color(0xFF4CAF50); // Yeşil
        statusText = 'ordersHistory.status.pickedUp'.tr();
        break;
      case 'cancelled':
      case 'canceled':
        statusColor = Colors.red;
        statusText = 'ordersHistory.status.cancelled'.tr();
        break;
      default:
        statusColor = Colors.grey;
        statusText = order.orderStatus;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım: Mağaza Logosu, İsmi ve Durum
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage:
                        bag?.shopLogoUrl != null &&
                            bag!.shopLogoUrl!.startsWith('http')
                        ? NetworkImage(bag.shopLogoUrl!)
                        : null,
                    child: bag?.shopLogoUrl == null
                        ? const Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F1F1)),

            // Orta Kısım: Ürün Detayları ve Fiyat
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: bag?.imageUrl != null && bag!.imageUrl!.isNotEmpty
                          ? (bag.imageUrl!.startsWith('http')
                                ? Image.network(
                                    bag.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(bag.imageUrl!, fit: BoxFit.cover))
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bagTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ordersHistory.quantity'.tr(
                            namedArgs: {
                              'quantity': order.quantityReserved.toString(),
                            },
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (bag != null) ...[
                        Text(
                          '${(bag.originalPrice * order.quantityReserved).toInt()} TL',
                          style: const TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(bag.discountedPrice * order.quantityReserved).toInt()} TL',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Alt Kısım: Teslim alma butonları (Sadece pending ve arrived durumları için)
            if (status == 'pending' || status == 'arrived') ...[
              const Divider(height: 1, color: Color(0xFFF1F1F1)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ordersHistory.pickupCode'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                    Row(
                      children: [
                        if (order.pickupCode != null)
                          Text(
                            order.pickupCode!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                              letterSpacing: 1,
                            ),
                          )
                        else
                          Text(
                            'ordersHistory.preparing'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (order.pickupQrToken != null)
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code_2_rounded,
                              color: AppColors.primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _openQrPage(order),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (review != null) ...[
              const Divider(height: 1, color: Color(0xFFF1F1F1)),
              _OrderReviewCard(review: review),
            ],
          ],
        ),
      ),
    );
  }

  void _openQrPage(OrderModel order) {
    final token = order.pickupQrToken;
    if (token == null || token.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            FoodPickupQrView(qrToken: token, pickupCode: order.pickupCode),
      ),
    );
  }
}

class _OrderReviewCard extends StatelessWidget {
  const _OrderReviewCard({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final rating = review.rating.round().clamp(0, 5);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.09),
            AppColors.primaryColor.withValues(alpha: 0.025),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rate_review_rounded,
                  color: AppColors.primaryColor,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'ordersHistory.yourReview'.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                DateFormat('dd.MM.yyyy').format(review.date),
                style: const TextStyle(
                  color: AppColors.hintTextColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 19,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 11),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final imageSize = (constraints.maxWidth - spacing * 2) / 3;

                return Row(
                  children: List.generate(review.imageUrls.length, (index) {
                    final imageUrl = review.imageUrls[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == review.imageUrls.length - 1
                            ? 0
                            : spacing,
                      ),
                      child: GestureDetector(
                        onTap: () => _showReviewImage(context, imageUrl),
                        child: Hero(
                          tag: 'review-${review.id}-$index',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox.square(
                              dimension: imageSize,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showReviewImage(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
