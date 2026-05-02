import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key, required this.vm});
  final BusinessAddOrderViewModel vm;

  void _showLocationPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: double.infinity,
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
                const Text(
                  'Adres Seçiniz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: const Text(
                    'Kayıtlı Adreslerimden Seç',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSavedAddressesSheet(context);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: const Text(
                    'Haritadan Seç',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    vm.pickLocation(context);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_location_alt_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: const Text(
                    'Yeni Adres Ekle',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    vm.addNewAddress(context);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSavedAddressesSheet(BuildContext context) {
    vm.fetchAddresses();

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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('Kayıtlı adres bulunamadı.'),
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
      onTap: () => _showLocationPickerSheet(context),
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
                hasData ? vm.locationAddress : 'Konum Seç',
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
