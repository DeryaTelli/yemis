import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/food/food_listing.dart';
import '../../models/food/order_model.dart';
import '../../services/food/i_food_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/routes/app_routes.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../views/food/food_pickup_qr_view.dart';
import '../../views/location/navigation_view.dart';

class FoodActiveOrderCard extends StatelessWidget {
  const FoodActiveOrderCard({
    super.key,
    required this.order,
    required this.onCancel,
  });

  final OrderModel order;
  final Future<bool> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final bag = order.bag;
    final pickupTime = bag == null
        ? DateFormat('dd MMMM HH:mm', 'tr').format(order.orderTime)
        : '${DateFormat('dd MMMM', 'tr').format(bag.pickupStartTime)} '
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
          _Product(order: order, onCancel: () => _confirmCancellation(context)),
          const SizedBox(height: 8),
          _DetailsRow(onTap: () => _openListingDetail(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.near_me_outlined,
                  label: 'Konuma Git',
                  filled: true,
                  onTap: () => _goToLocation(context, bag),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.qr_code_2_rounded,
                  label: 'QR Kodunu Göster',
                  onTap: () => _showQr(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancellation(BuildContext context) async {
    final amount = (order.bag?.discountedPrice ?? 0) * order.quantityReserved;
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rezervasyonu iptal et',
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
                      'Rezervasyonu İptal Et',
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
                      'Rezervasyonu iptal etmek istediğinize emin misiniz?',
                      style: CustomTextStyles.regular14GreyHeight,
                    ),

                    Text(
                      amount > 0
                          ? 'İptal edilmesi durumunda rezervasyon işlemi için ödediğiniz ${amount.toStringAsFixed(0)} TL hesabınıza iade edilecektir.'
                          : 'İptal edilmesi durumunda rezervasyon işlemi için ödediğiniz tutar hesabınıza iade edilecektir.',
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
                    child: const Text(
                      'Vazgeç',
                      style: TextStyle(color: AppColors.primaryTextColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text(
                      'Evet',
                      style: TextStyle(color: Colors.redAccent),
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

    final success = await onCancel();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Rezervasyon iptal edildi. İade işleminiz başlatıldı.'
              : 'Rezervasyon iptal edilemedi. Lütfen tekrar deneyin.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _openListingDetail(BuildContext context) async {
    try {
      final listing = await context.read<IFoodService>().getFoodDetail(
        order.bagId.toString(),
      );
      if (!context.mounted) return;

      Navigator.pushNamed(context, AppRoutes.foodDetail, arguments: listing);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('İlan detayı yüklenemedi.')));
    }
  }

  Future<void> _goToLocation(BuildContext context, OrderBagModel? bag) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İlanın konumu bulunamadı.')),
      );
      return;
    }

    Navigator.push(
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
  }

  void _showQr(BuildContext context) {
    final token = order.pickupQrToken;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            order.pickupCode == null
                ? 'QR kodunuz henüz hazırlanıyor.'
                : 'Teslim alım kodunuz: ${order.pickupCode}',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            FoodPickupQrView(qrToken: token, pickupCode: order.pickupCode),
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rezervasyon Yapıldı',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Rezervasyonunuz alındı ve işletme tarafından hazırlanıyor.',
                style: TextStyle(
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
      padding: const EdgeInsets.all(11),
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
                  bag?.title ?? 'Sürpriz Kutu',
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
                  bag?.shopName ?? 'İşletme',
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
                      '${order.quantityReserved} Adet',
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
                      child: const Text('İptal Et'),
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
          child: const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primaryColor,
                size: 22,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rezervasyon Detayı',
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sipariş detayınızı görüntüleyin.',
                      style: TextStyle(
                        color: AppColors.hintTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.primaryColor),
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
