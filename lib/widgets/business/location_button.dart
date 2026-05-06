import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/utils/routes/app_routes.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key, required this.vm});
  final BusinessAddOrderViewModel vm;

  Future<void> _handleTap(BuildContext context) async {
    await vm.fetchAddresses();

    if (context.mounted) {
      if (vm.savedAddresses.isEmpty) {
        // Kayıtlı adres yoksa yönlendir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.businessAddOrder_errorNoAddress.tr()),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        Navigator.pushNamed(
          context,
          AppRoutes.addresses,
          arguments: AppModuleType.business,
        );
      } else {
        // Kayıtlı adresleri göster
        _showSavedAddressesSheet(context);
      }
    }
  }

  void _showSavedAddressesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: Consumer<BusinessAddOrderViewModel>(
            builder: (context, vm, child) {
              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Adres Seçiniz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (vm.savedAddresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(LocaleKeys.addresses_noAddressFound.tr()),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: vm.savedAddresses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final addr = vm.savedAddresses[index];
                            final isSelected = vm.locationAddress.contains(
                              addr.addressLine,
                            );

                            return GestureDetector(
                              onTap: () {
                                vm.selectAddress(addr);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : const Color(0xFFEEEEEE),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addr.label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            addr.addressLine,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${addr.district ?? ''} / ${addr.city ?? ''}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Sheet'i kapat
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addresses,
                          arguments: AppModuleType.business,
                        );
                      },
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(LocaleKeys.addresses_addAddress.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = vm.locationAddress.isNotEmpty;

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasData
                ? const Color(0xFFE0E0E0)
                : AppColors.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasData ? Icons.location_on_rounded : Icons.add_rounded,
              color: AppColors.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasData ? vm.locationAddress : LocaleKeys.common_selectLocation.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: hasData ? FontWeight.w500 : FontWeight.w600,
                  color: hasData
                      ? AppColors.primaryTextColor
                      : AppColors.primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasData)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.hintTextColor,
              ),
          ],
        ),
      ),
    );
  }
}
