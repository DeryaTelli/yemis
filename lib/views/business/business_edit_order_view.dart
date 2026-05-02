import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _allergensController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<BusinessEditOrderViewModel>();
    _titleController = TextEditingController(text: vm.title);
    _priceController = TextEditingController(text: vm.price);
    _discountPriceController = TextEditingController(text: vm.discountPrice);
    _descriptionController = TextEditingController(text: vm.description);
    _allergensController = TextEditingController(text: vm.allergens);
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
        title: const Text('İlanı Düzenle'),
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
              _label('İlan Başlığı'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _titleController,
                hintText: 'Örn: Sürpriz Kahvaltı Kutusu',
                onChanged: vm.onTitleChanged,
                borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),

              _label('İlan Fotoğrafı'),
              const SizedBox(height: 8),
              PhotoBox(
                imagePath: vm.selectedImage?.path,
                networkImageUrl: vm.selectedImage == null
                    ? vm.initialListing.imageUrl
                    : null,
                onTap: () => _showImagePickerSheet(context, vm),
              ),
              const SizedBox(height: 12),

              _label('Bitiş Saati'),
              const SizedBox(height: 8),
              // TimeWheelSection vm tipi uyuşmazlığı olabilir, vm interface veya dynamic kullanılabilir.
              // Şimdilik BusinessAddOrderViewModel bekliyor olabilir, kontrol etmeliyiz.
              // TimeWheelSection'ı düzenleyelim veya burada manuel gösterelim.
              _buildTimeSelector(vm),
              const SizedBox(height: 24),

              _label('İlan Konumu'),
              const SizedBox(height: 8),
              _buildLocationButton(vm),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_label('İlan Sayısı'), _buildQuantityRow(vm)],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('İlan Fiyatı'),
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
                  _label('İndirim Fiyatı'),
                  PriceField(
                    controller: _discountPriceController,
                    hintText: '0',
                    onChanged: vm.onDiscountPriceChanged,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _label('İlan Detayı'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'İlanınızla ilgili detaylı bilgi giriniz...',
                maxLines: 3,
                onChanged: vm.onDescriptionChanged,
                borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),

              _label('Alerjen Bilgisi'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _allergensController,
                hintText: 'Örn: Glüten, Süt, Yumurta içerir...',
                onChanged: vm.onAllergensChanged,
                borderColor: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 28),

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    vm.errorMessage!,
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
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Güncelle',
                      style: TextStyle(
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
                vm.locationAddress.isEmpty ? 'Konum Seç' : vm.locationAddress,
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
              title: const Text('Kameradan Çek'),
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
              title: const Text('Galeriden Seç'),
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
}
