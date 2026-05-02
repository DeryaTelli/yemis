import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/business/i_business_service.dart';
import '../../viewmodels/business/business_listings_viewmodel.dart';
import '../../widgets/business/business_listing_card.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

class BusinessListingsView extends StatelessWidget {
  const BusinessListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BusinessListingsViewModel(
        businessService: ctx.read<IBusinessService>(),
      )..fetchListings(),
      child: const _BusinessListingsBody(),
    );
  }
}

class _BusinessListingsBody extends StatelessWidget {
  const _BusinessListingsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessListingsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('İlanlarım'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: vm.isLoading,
        moduleType: AppModuleType.business,
        child: vm.listings.isEmpty && !vm.isLoading
            ? _buildEmptyState()
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
                              const SnackBar(content: Text('İlan silinirken bir hata oluştu.')),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Henüz bir ilanınız bulunmuyor.',
            style: TextStyle(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('İlanı Sil'),
        content: const Text('Bu ilanı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
