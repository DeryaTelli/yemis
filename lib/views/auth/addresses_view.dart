import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/addresses_viewmodel.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';

class AddressesView extends StatelessWidget {
  final AppModuleType moduleType;
  const AddressesView({super.key, this.moduleType = AppModuleType.food});

  @override
  Widget build(BuildContext context) {
    final themeColor = moduleType == AppModuleType.food
        ? AppColors.primaryColor
        : AppColors.volunteerColor;

    return ChangeNotifierProvider(
      create: (_) => AddressesViewModel(
        authService: context.read<IAuthService>(),
        userSession: context.read<UserSession>(),
      )..init(),
      child: Consumer<AddressesViewModel>(
        builder: (context, vm, child) {
          return LoadingOverlay(
            isLoading: vm.isLoading,
            moduleType: moduleType,
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Adreslerim',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        _showAddAddressOptions(context, themeColor),
                    child: Text(
                      'Adres Ekle',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAddAddressHeader(context, themeColor),
                  const SizedBox(height: 16),
                  if (vm.addresses.isEmpty && !vm.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Henüz kayıtlı bir adresiniz bulunmuyor.',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...vm.addresses.map(
                      (address) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AddressCard(
                          key: ValueKey(address.id),
                          label: address.label.isEmpty ? 'Ev' : address.label,
                          name:
                              context.read<UserSession>().currentUser?.name ??
                              '',
                          phone:
                              context
                                  .read<UserSession>()
                                  .currentUser
                                  ?.phoneNumber ??
                              '',
                          addressLine: address.addressLine,
                          themeColor: themeColor,
                          onEdit: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              AppRoutes.foodAddAddress,
                              arguments: {
                                'address': address,
                                'moduleType': moduleType,
                              },
                            );
                            if (result == true && context.mounted) {
                              context
                                  .read<AddressesViewModel>()
                                  .fetchAddresses();
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddAddressHeader(BuildContext context, Color themeColor) {
    return GestureDetector(
      onTap: () => _showAddAddressOptions(context, themeColor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: themeColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              'Yeni Adres Ekle',
              style: TextStyle(
                color: themeColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: themeColor),
          ],
        ),
      ),
    );
  }

  void _showAddAddressOptions(BuildContext context, Color themeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _OptionTile(
              icon: Icons.my_location_rounded,
              title: 'Lokasyondan Seç',
              themeColor: themeColor,
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.location,
                );
                // Eğer konum seçildiyse listeyi yenile
                if (context.mounted) {
                  context.read<AddressesViewModel>().fetchAddresses();
                }
              },
            ),
            const Divider(height: 1),
            _OptionTile(
              icon: Icons.edit_location_alt_rounded,
              title: 'Adres Gir',
              themeColor: themeColor,
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.foodAddAddress,
                  arguments: {'moduleType': moduleType},
                );
                if (result == true && context.mounted) {
                  context.read<AddressesViewModel>().fetchAddresses();
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color themeColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: themeColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(Icons.chevron_right, color: themeColor),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String label;
  final String name;
  final String phone;
  final String addressLine;
  final Color themeColor;
  final VoidCallback onEdit;

  const _AddressCard({
    super.key,
    required this.label,
    required this.name,
    required this.phone,
    required this.addressLine,
    required this.themeColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Düzenle',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phone.isEmpty ? 'Telefon eklenmemiş' : phone,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            addressLine,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
