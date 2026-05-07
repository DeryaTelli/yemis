import 'package:flutter/material.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../services/business/i_business_service.dart';
import '../../viewmodels/business/business_listings_viewmodel.dart';
import '../../widgets/business/business_listing_card.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import 'package:lottie/lottie.dart';
import '../../utils/theme/text_styles_custom.dart';

class BusinessListingsView extends StatelessWidget {
  final ListingType type;
  const BusinessListingsView({super.key, this.type = ListingType.all});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BusinessListingsViewModel(
        businessService: ctx.read<IBusinessService>(),
        type: type,
      )..fetchListings(),
      child: _BusinessListingsBody(type: type),
    );
  }
}

class _BusinessListingsBody extends StatelessWidget {
  final ListingType type;
  const _BusinessListingsBody({required this.type});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessListingsViewModel>();

    String title = LocaleKeys.businessListings_allTitle.tr();
    if (type == ListingType.sold) title = LocaleKeys.businessListings_soldTitle.tr();
    if (type == ListingType.active) title = LocaleKeys.businessListings_activeTitle.tr();
    if (type == ListingType.expired) title = LocaleKeys.businessListings_expiredTitle.tr();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: vm.isLoading,
        moduleType: AppModuleType.business,
        child: vm.listings.isEmpty && !vm.isLoading
            ? _buildEmptyState(type)
            : RefreshIndicator(
                onRefresh: vm.fetchListings,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.listings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = vm.listings[index];
                    return Dismissible(
                      key: Key('listing_${item.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        debugPrint('Listing ${item.id} dismissed from UI');
                      },
                      confirmDismiss: (direction) async {
                        final confirmed = await _showDeleteConfirmation(context);
                        if (confirmed == true) {
                          final success = await vm.deleteListing(item.id);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(LocaleKeys.businessListings_deleteError.tr())),
                            );
                          }
                          return success;
                        }
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.white, size: 28),
                      ),
                      child: BusinessListingCard(
                        listing: item,
                        onEdit: () => vm.editListing(context, item),
                        onTap: () => vm.navigateToDetail(context, item),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(ListingType type) {
    String message = LocaleKeys.businessListings_emptyAll.tr();
    if (type == ListingType.sold) message = LocaleKeys.businessListings_emptySold.tr();
    if (type == ListingType.active) message = LocaleKeys.businessListings_emptyActive.tr();
    if (type == ListingType.expired) message = LocaleKeys.businessListings_emptyExpired.tr();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
                fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFFFDF5F2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Lottie.asset(
                  'assets/lottie/account_delete.json',
                  width: 60,
                  height: 60,
                  repeat: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LocaleKeys.businessListings_deleteDialogTitle.tr(),
                    style: CustomTextStyles.orelegaOne30Primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.businessListings_deleteDialogMessage.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    LocaleKeys.common_no.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    LocaleKeys.common_yes.tr(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
