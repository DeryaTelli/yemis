import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/widgets/business/location_button.dart';
import 'package:yemis/widgets/business/photo_box.dart';
import 'package:yemis/widgets/business/price_field.dart';
import 'package:yemis/widgets/business/quantity_row.dart';
import 'package:yemis/widgets/business/share_button.dart';
import 'package:yemis/widgets/business/time_wheel_section.dart';
import 'package:yemis/widgets/common/app_bottom_nav_bar.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/theme/app_theme.dart';
import '../../utils/routes/app_routes.dart';
import '../../viewmodels/business/business_add_order_viewmodel.dart';


class BusinessAddOrderView extends StatelessWidget {
  const BusinessAddOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.food),
      child: ChangeNotifierProvider(
        create: (_) => BusinessAddOrderViewModel(),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessAddOrderViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.businessAddOrder_title.tr()),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fotoğraf ──────────────────────────────────────
            _label(LocaleKeys.businessAddOrder_photoLabel.tr()),
            const SizedBox(height: 8),
            PhotoBox(
              imagePath: vm.selectedImage?.path,
              onTap: () => _showImagePickerSheet(context, vm),
            ),
            const SizedBox(height: 24),

            // ── Bitiş Saati ───────────────────────────────────
            _label(LocaleKeys.businessAddOrder_endTimeLabel.tr()),
            const SizedBox(height: 8),
            TimeWheelSection(vm: vm),
            const SizedBox(height: 24),

            // ── Konum ─────────────────────────────────────────
            _label(LocaleKeys.businessAddOrder_locationLabel.tr()),
            const SizedBox(height: 8),
            LocationButton(vm: vm),
            const SizedBox(height: 20),

            // ── İlan Sayısı ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label(LocaleKeys.businessAddOrder_quantityLabel.tr()),
                QuantityRow(vm: vm),
              ],
            ),
            const SizedBox(height: 16),

            // ── İlan Fiyatı ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label(LocaleKeys.businessAddOrder_priceLabel.tr()),
                PriceField(
                  controller: _priceController,
                  onChanged: vm.onPriceChanged,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Hata ──────────────────────────────────────────
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  LocaleKeys.businessAddOrder_errorNoLocation.tr(),
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            // ── Paylaş ────────────────────────────────────────
            ShareButton(vm: vm),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: vm.selectedIndex,
        onItemSelected: (index) => _navigate(context, index),
        moduleType: AppModuleType.business,
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryTextColor,
        ),
      );

  void _showImagePickerSheet(BuildContext context, BusinessAddOrderViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primaryColor),
                ),
                title: Text(
                  LocaleKeys.businessAddOrder_pickFromCamera.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.primaryColor),
                onTap: () async {
                  Navigator.pop(context);
                  await vm.pickFromCamera();
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
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primaryColor),
                ),
                title: Text(
                  LocaleKeys.businessAddOrder_pickFromGallery.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.primaryColor),
                onTap: () async {
                  Navigator.pop(context);
                  await vm.pickFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (r) => false);
      return;
    }
    final map = {
      0: AppRoutes.businessHome,
      1: AppRoutes.businessApprovals,
      3: AppRoutes.businessAddOrder,
      4: AppRoutes.businessProfile,
    };
    final route = map[index];
    if (route != null && ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }
}


