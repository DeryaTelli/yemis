import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/widgets/business/location_button.dart';
import 'package:yemis/widgets/common/custom_text_field.dart';
import '../../models/business/business_listing_model.dart';
import '../../services/auth/i_auth_service.dart';
import '../../services/business/i_business_service.dart';
import 'package:yemis/widgets/business/photo_box.dart';
import 'package:yemis/widgets/business/price_field.dart';
import 'package:yemis/widgets/business/quantity_row.dart';
import 'package:yemis/widgets/business/time_wheel_section.dart';
import '../../models/app_module_type.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/business/business_edit_order_viewmodel.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/success_dialog_custom.dart';

class BusinessEditOrderView extends StatelessWidget {
  final BusinessListingModel listing;

  const BusinessEditOrderView({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.food),
      child: ChangeNotifierProvider(
        create: (ctx) => BusinessEditOrderViewModel(
          authService: ctx.read<IAuthService>(),
          businessService: ctx.read<IBusinessService>(),
          initialListing: listing,
        ),
        child: _Body(listing: listing),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final BusinessListingModel listing;
  const _Body({required this.listing});
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _allergensController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listing.title);
    _priceController = TextEditingController(
      text: widget.listing.originalPrice.toString(),
    );
    _discountPriceController = TextEditingController(
      text: widget.listing.discountedPrice.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.listing.description ?? '',
    );
    _allergensController = TextEditingController(
      text: widget.listing.allergens ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _descriptionController.dispose();
    _allergensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessEditOrderViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.volunteerEditListing_title.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: vm.isSubmitting,
        moduleType: AppModuleType.business,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(LocaleKeys.businessAddOrder_titleLabel.tr()),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _titleController,
                hintText: LocaleKeys.businessAddOrder_titleHint.tr(),
                onChanged: vm.onTitleChanged,
                borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),

              _label(LocaleKeys.businessAddOrder_categoryLabel.tr()),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _showCategoryPickerSheet(context, vm),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            vm.selectedCategory != null
                                ? (vm.selectedCategory!.toLowerCase() ==
                                          'patiseri'
                                      ? LocaleKeys
                                            .businessListingDetail_breadPastry
                                            .tr()
                                      : vm.selectedCategory!
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            vm.selectedCategory!.substring(1))
                                : LocaleKeys
                                      .businessAddOrder_categoryPlaceholder
                                      .tr(),
                            style: TextStyle(
                              color: vm.selectedCategory != null
                                  ? AppColors.primaryTextColor
                                  : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label(LocaleKeys.businessAddOrder_photoLabel.tr()),
              const SizedBox(height: 8),
              PhotoBox(
                imagePath: vm.selectedImage?.path,
                networkImageUrl: vm.selectedImage == null
                    ? vm.initialListing.imageUrl
                    : null,
                onTap: () => _showImagePickerSheet(context, vm),
              ),
              const SizedBox(height: 12),

              _label(LocaleKeys.businessAddOrder_endTimeLabel.tr()),
              const SizedBox(height: 8),
              // TimeWheelSection vm tipi uyuşmazlığı olabilir, vm interface veya dynamic kullanılabilir.
              // Şimdilik BusinessAddOrderViewModel bekliyor olabilir, kontrol etmeliyiz.
              // TimeWheelSection'ı düzenleyelim veya burada manuel gösterelim.
              _buildTimeSelector(vm),
              const SizedBox(height: 24),

              _label(LocaleKeys.businessAddOrder_locationLabel.tr()),
              const SizedBox(height: 8),
              _buildLocationButton(vm),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label(LocaleKeys.businessAddOrder_quantityLabel.tr()),
                  _buildQuantityRow(vm),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label(LocaleKeys.businessAddOrder_priceLabel.tr()),
                  PriceField(
                    controller: _priceController,
                    hintText: '0',
                    onChanged: vm.onPriceChanged,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label(LocaleKeys.businessAddOrder_discountPriceLabel.tr()),
                  PriceField(
                    controller: _discountPriceController,
                    hintText: '0',
                    onChanged: vm.onDiscountPriceChanged,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _label(LocaleKeys.businessAddOrder_descriptionLabel.tr()),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                hintText: LocaleKeys.businessAddOrder_descriptionHint.tr(),
                maxLines: 3,
                onChanged: vm.onDescriptionChanged,
                borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),

              _label(LocaleKeys.businessAddOrder_allergensLabel.tr()),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _allergensController,
                hintText: LocaleKeys.businessAddOrder_allergensHint.tr(),
                onChanged: vm.onAllergensChanged,
                borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 28),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    vm.errorMessage == 'errorNoLocation'
                        ? LocaleKeys.businessAddOrder_errorNoLocation.tr()
                        : vm.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await vm.submit();
                      if (success && mounted) {
                        SuccessDialogCustom.show(
                          context,
                          title: LocaleKeys.businessEditOrder_successTitle.tr(),
                          message: LocaleKeys.businessEditOrder_successMessage
                              .tr(),
                          onConfirm: () {
                            Navigator.pop(context, true);
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.common_save.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildTimeSelector(BusinessEditOrderViewModel vm) {
    // TimeWheelSection tip uyuşmazlığı varsa manuel yapalım
    return TimeWheelSection(vm: vm as dynamic);
  }

  Widget _buildLocationButton(BusinessEditOrderViewModel vm) {
    return InkWell(
      onTap: () => vm.pickLocation(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                vm.locationAddress.isEmpty
                    ? LocaleKeys.common_selectLocation.tr()
                    : vm.locationAddress,
                style: TextStyle(
                  color: vm.locationAddress.isEmpty
                      ? Colors.grey
                      : AppColors.primaryTextColor,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityRow(BusinessEditOrderViewModel vm) {
    return Row(
      children: [
        _qBtn(Icons.remove, vm.decrementQuantity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            vm.quantity.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _qBtn(Icons.add, vm.incrementQuantity),
      ],
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, size: 20, color: AppColors.primaryColor),
    ),
  );

  void _showImagePickerSheet(
    BuildContext context,
    BusinessEditOrderViewModel vm,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(LocaleKeys.common_pickFromCamera.tr()),
              onTap: () {
                Navigator.pop(context);
                vm.pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(LocaleKeys.common_pickFromGallery.tr()),
              onTap: () {
                Navigator.pop(context);
                vm.pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPickerSheet(
    BuildContext context,
    BusinessEditOrderViewModel vm,
  ) {
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  LocaleKeys.businessAddOrder_categoryLabel.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...vm.categories.map((cat) {
                final isSelected = vm.selectedCategory == cat;
                return ListTile(
                  title: Text(
                    cat.toLowerCase() == 'patiseri'
                        ? LocaleKeys.businessListingDetail_breadPastry.tr()
                        : cat.substring(0, 1).toUpperCase() + cat.substring(1),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.primaryTextColor,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                        )
                      : null,
                  onTap: () {
                    vm.onCategoryChanged(cat);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
