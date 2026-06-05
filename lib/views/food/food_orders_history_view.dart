import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/food/order_model.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/food/food_orders_history_viewmodel.dart';

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
      appBar: AppBar(
        title: const Text(
          'Geçmiş Rezervasyonlarım',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.primaryTextColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Bir hata oluştu:\n${vm.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.fetchOrders(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tekrar Dene', style: TextStyle(color: Colors.white)),
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
                color: AppColors.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 44,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Henüz Rezervasyonunuz Yok',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aldığınız sürpriz kutular ve rezervasyonlar\nburada listelenecektir.',
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
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = vm.orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final bag = order.bag;
    final shopName = bag?.shopName ?? 'Bilinmeyen İşletme';
    final bagTitle = bag?.title ?? 'Sürpriz Kutu';
    final formattedDate = DateFormat('dd.MM.yyyy, HH:mm').format(order.orderTime);
    final status = order.orderStatus.toLowerCase();

    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFFF9800); // Turuncu
        statusText = 'Onay Bekliyor';
        break;
      case 'arrived':
        statusColor = const Color(0xFF2196F3); // Mavi
        statusText = 'Hedefte';
        break;
      case 'picked_up':
        statusColor = const Color(0xFF4CAF50); // Yeşil
        statusText = 'Teslim Alındı';
        break;
      case 'cancelled':
      case 'canceled':
        statusColor = Colors.red;
        statusText = 'İptal Edildi';
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
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
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    backgroundImage: bag?.shopLogoUrl != null && bag!.shopLogoUrl!.startsWith('http')
                        ? NetworkImage(bag.shopLogoUrl!)
                        : null,
                    child: bag?.shopLogoUrl == null
                        ? const Icon(Icons.storefront_rounded, color: AppColors.primaryColor, size: 20)
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
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
                              ? Image.network(bag.imageUrl!, fit: BoxFit.cover)
                              : Image.asset(bag.imageUrl!, fit: BoxFit.cover))
                          : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
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
                          'Adet: ${order.quantityReserved}',
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Teslim Alım Kodu:',
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
                          const Text(
                            'Hazırlanıyor',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (order.pickupQrToken != null)
                          IconButton(
                            icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryColor),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showQrDialog(order),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQrDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QR Kod ile Teslim Al',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (order.pickupQrToken != null)
                QrImageView(
                  data: order.pickupQrToken!,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primaryTextColor,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primaryColor,
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Bu QR kodu teslimat noktasında işletmeye okutarak siparişinizi teslim alabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.hintTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              if (order.pickupCode != null) ...[
                const Text(
                  'Alternatif Kod:',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.hintTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.pickupCode!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
