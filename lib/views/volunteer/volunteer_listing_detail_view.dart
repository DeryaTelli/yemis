import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import '../../models/volunteer/volunteer_listing.dart';
import '../../services/volunteer/i_volunteer_service.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/volunteer/volunteer_listing_detail_viewmodel.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import '../../widgets/food/order_location_map.dart';

class VolunteerListingDetailView extends StatelessWidget {
  final VolunteerListing listing;
  final bool isEditable;

  const VolunteerListingDetailView({
    super.key,
    required this.listing,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => VolunteerListingDetailViewModel(
        volunteerService: ctx.read<IVolunteerService>(),
        listing: listing,
      ),
      child: _VolunteerListingDetailBody(isEditable: isEditable),
    );
  }
}

class _VolunteerListingDetailBody extends StatelessWidget {
  final bool isEditable;
  const _VolunteerListingDetailBody({required this.isEditable});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerListingDetailViewModel>();
    final item = vm.listing;
    final theme = Theme.of(context);

    final LatLng displayLocation =
        (item.latitude != null && item.longitude != null)
        ? LatLng(item.latitude!, item.longitude!)
        : const LatLng(41.2048, 32.6218);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: vm.isLoading,
        moduleType: AppModuleType.volunteer,
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
              actions: [
                if (isEditable)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.volunteerColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () async {
                        final result =
                            await Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRoutes.volunteerEditListing,
                              arguments: item,
                            );
                        if (result == true && context.mounted) {
                          // Detay sayfasını kapatıp listeyi yeniletelim
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'listing_${item.id}',
                      child: item.imageUrl.isNotEmpty
                          ? (item.imageUrl.startsWith('http')
                                ? Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(item.imageUrl, fit: BoxFit.cover))
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
                              backgroundColor: const Color(0xFFD1F1DB),
                              backgroundImage: item.userLogoUrl != null
                                  ? NetworkImage(item.userLogoUrl!)
                                  : null,
                              child: item.userLogoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors.volunteerColor,
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
                                  item.userName,
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
                                    color: AppColors.volunteerColor.withOpacity(
                                      0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'AKTİF İLAN',
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.volunteerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ÜCRETSİZ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.volunteerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      Icons.timer_outlined,
                      'Teslimat Aralığı:',
                      item.timeRange,
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Konum'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.volunteerColor.withValues(
                            alpha: 0.25,
                          ),
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
                      item.location,
                    ),
                    const SizedBox(height: 16),
                    _sectionTitle('Açıklama'),
                    const SizedBox(height: 8),
                    _contentBox(
                      item.description ??
                          'Bu ilan için henüz bir içerik detayı girilmemiş.',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.volunteerColor),
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
        color: AppColors.volunteerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.volunteerColor.withValues(alpha: 0.3),
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
}
