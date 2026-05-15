import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:yemis/utils/locale_keys.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/addresses_viewmodel.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/auth/user_session.dart';
import '../../utils/routes/app_routes.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import '../../utils/theme/app_theme.dart';

class AddressesView extends StatelessWidget {
  final AppModuleType moduleType;
  const AddressesView({super.key, this.moduleType = AppModuleType.food});

  @override
  Widget build(BuildContext context) {
    final themeColor =
        (moduleType == AppModuleType.food ||
            moduleType == AppModuleType.business)
        ? AppColors.primaryColor
        : AppColors.volunteerColor;

    return ChangeNotifierProvider(
      create: (_) => AddressesViewModel(
        authService: context.read<IAuthService>(),
        userSession: context.read<UserSession>(),
      )..init(),
      child: Consumer<AddressesViewModel>(
        builder: (context, vm, child) {
          final section =
              (moduleType == AppModuleType.food ||
                  moduleType == AppModuleType.business)
              ? AppSection.food
              : AppSection.volunteer;

          return Theme(
            data: AppTheme.themeFor(section),
            child: LoadingOverlay(
              isLoading: vm.isLoading,
              moduleType: moduleType,
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: Text(LocaleKeys.addresses_title.tr()),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
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
                                LocaleKeys.addresses_notFound.tr(),
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
                          child: Dismissible(
                            key: ValueKey('dismiss_${address.id}'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: const Color(0xFFFDF5F2),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
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
                                              LocaleKeys.addresses_deleteTitle.tr(),
                                              style: CustomTextStyles
                                                  .orelegaOne30Primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        LocaleKeys.addresses_deleteConfirm.tr(),
                                        style: CustomTextStyles.semiBold16Grey,
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text(
                                              LocaleKeys.common_no.tr(),
                                              style: CustomTextStyles
                                                  .semiBold16Grey,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
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
                              return confirmed;
                            },
                            onDismissed: (direction) {
                              vm.deleteAddress(address.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleKeys.addresses_deleted.tr(),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            child: _AddressCard(
                              key: ValueKey(address.id),
                              label: address.label.isEmpty
                                  ? LocaleKeys.addresses_defaultLabel.tr()
                                  : address.label,
                              name:
                                  context
                                      .read<UserSession>()
                                      .currentUser
                                      ?.name ??
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
                      ),
                  ],
                ),
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
              LocaleKeys.addresses_newAddress.tr(),
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
              title: LocaleKeys.addresses_selectFromLocation.tr(),
              themeColor: themeColor,
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.location,
                  arguments: {'returnToSender': true, 'moduleType': moduleType},
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
              title: LocaleKeys.addresses_enterAddress.tr(),
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
                  LocaleKeys.addresses_editLabel.tr(),
                  style: TextStyle(
                    color: themeColor,
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
