import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/business/business_listing_model.dart';
import '../../services/business/i_business_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/business/business_listing_detail_viewmodel.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import '../../widgets/food/order_location_map.dart';
import '../location/navigation_view.dart';

class BusinessListingDetailView extends StatelessWidget {
  final BusinessListingModel listing;

  const BusinessListingDetailView({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BusinessListingDetailViewModel(
        businessService: ctx.read<IBusinessService>(),
        listing: listing,
      ),
      child: const _BusinessListingDetailBody(),
    );
  }
}

class _BusinessListingDetailBody extends StatelessWidget {
  const _BusinessListingDetailBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessListingDetailViewModel>();
    final item = vm.listing;
    final theme = Theme.of(context);

    final LatLng displayLocation =
        (item.latitude != null && item.longitude != null)
        ? LatLng(item.latitude!, item.longitude!)
        : const LatLng(41.0082, 28.9784);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: vm.isLoading,
        moduleType: AppModuleType.business,
        child: CustomScrollView(
          slivers: [
            // ── AppBar & Hero Image ────────────────
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryTextColor,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'listing_${item.id}',
                      child: item.imageUrl != null
                          ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 30,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[100],
                              backgroundImage: item.businessLogoUrl != null
                                  ? NetworkImage(item.businessLogoUrl!)
                                  : null,
                              child: item.businessLogoUrl == null
                                  ? const Icon(
                                      Icons.storefront_rounded,
                                      color: AppColors.primaryColor,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.businessName ?? 'İşletme Adı',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black45,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBorderColor
                                        .withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ONAYLI İŞLETME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.discountedPrice.toStringAsFixed(0)} TL',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            if (item.originalPrice > item.discountedPrice)
                              Text(
                                '${item.originalPrice.toStringAsFixed(0)} TL',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Oluşturulma:',
                      _formatDate(item.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.timer_outlined,
                      'Son Alım Saati:',
                      _formatDate(item.pickupEndTime),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Konum'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: OrderLocationMap(
                          businessLocation: displayLocation,
                          height: 200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Adres:',
                      item.address ?? 'Konum Belirtilmedi',
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('İçerik'),
                    const SizedBox(height: 8),
                    _contentBox(
                      item.description ??
                          'Bu ilan için henüz bir içerik detayı girilmemiş.',
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('Alerjenler'),
                    const SizedBox(height: 8),
                    _contentBox(item.allergens ?? 'Belirtilmemiş'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(item),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryTextColor,
      ),
    );
  }

  Widget _contentBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BusinessListingModel item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol Taraf: Stok Durumu (Yeni Yer)
          const Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primaryColor,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Stok Durumu',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          // Sağ Taraf: Kalan Adet (Yeni Yer)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Kalan Adet',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.availableQuantity} / ${item.totalQuantity}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belirtilmedi';
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }
}
