import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../viewmodels/auth/food_add_address_viewmodel.dart';
import '../../services/auth/i_auth_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/app_module_type.dart';
import '../../models/auth/address_model.dart';
import '../../services/auth/user_session.dart';

class FoodAddAddressView extends StatelessWidget {
  final AddressModel? address;
  final AppModuleType moduleType;

  const FoodAddAddressView({
    super.key,
    this.address,
    this.moduleType = AppModuleType.food,
  });

  @override
  Widget build(BuildContext context) {
    final userSession = context.read<UserSession>();
    final themeColor = moduleType == AppModuleType.food
        ? AppColors.primaryColor
        : AppColors.volunteerColor;

    return ChangeNotifierProvider(
      create: (_) => FoodAddAddressViewModel(
        authService: context.read<IAuthService>(),
        initialAddress: address,
        defaultPhone: userSession.currentUser?.phoneNumber,
      ),
      child: _FoodAddAddressBody(themeColor: themeColor),
    );
  }
}

class _FoodAddAddressBody extends StatelessWidget {
  final Color themeColor;
  const _FoodAddAddressBody({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FoodAddAddressViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      moduleType: AppModuleType.food,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            vm.isEditMode ? 'Adresi Düzenle' : 'Adres Ekle',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Telefon Numarası'),
              CustomTextField(
                controller: vm.phoneController,
                hintText: '05xx xxx xx xx',
                keyboardType: TextInputType.phone,
                borderColor: const Color(0xFFE0E0E0),
                fillColor: const Color(0xFFF9F9F9),
              ),
              const SizedBox(height: 16),
              _fieldLabel('İl'),
              _SelectionField(
                hint: 'Seçiniz',
                value: vm.selectedIl,
                themeColor: themeColor,
                onTap: () => _showPicker(
                  context,
                  'İl Seçiniz',
                  vm.iller,
                  vm.selectIl,
                  themeColor,
                ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('İlçe'),
              _SelectionField(
                hint: vm.selectedIl == null ? 'Önce il seçiniz' : 'Seçiniz',
                value: vm.selectedIlce,
                enabled: vm.selectedIl != null,
                themeColor: themeColor,
                onTap: vm.selectedIl == null
                    ? null
                    : () => _showPicker(
                        context,
                        'İlçe Seçiniz',
                        vm.ilceler,
                        vm.selectIlce,
                        themeColor,
                      ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Mahalle'),
              _SelectionField(
                hint: vm.selectedIlce == null ? 'Önce ilçe seçiniz' : 'Seçiniz',
                value: vm.selectedMahalle,
                enabled: vm.selectedIlce != null,
                themeColor: themeColor,
                onTap: vm.selectedIlce == null
                    ? null
                    : () => _showPicker(
                        context,
                        'Mahalle Seçiniz',
                        vm.mahalleler,
                        vm.selectMahalle,
                        themeColor,
                      ),
              ),
              const SizedBox(height: 24),
              _fieldLabel('Adres'),
              CustomTextField(
                controller: vm.adresController,
                hintText: 'Cadde, mahalle sokak ve diğer bilgileri giriniz.',
                maxLines: 3,
                borderColor: const Color(0xFFE0E0E0),
                fillColor: const Color(0xFFF9F9F9),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Adres Başlığı'),
              CustomTextField(
                controller: vm.baslikController,
                hintText: 'Adres Başlığı Giriniz (Örn: Ev, İş)',
                borderColor: const Color(0xFFE0E0E0),
                fillColor: const Color(0xFFF9F9F9),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Kaydet',
                backgroundColor: themeColor,
                onPressed: () async {
                  final success = await vm.saveAddress();
                  if (success && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                width: double.infinity,
                height: 54,
                borderRadius: 14,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  void _showPicker(
    BuildContext context,
    String title,
    List<String> items,
    void Function(String?) onSelect,
    Color themeColor,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, i) => ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: themeColor,
                      size: 20,
                    ),
                    title: Text(items[i], style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      onSelect(items[i]);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectionField extends StatelessWidget {
  final String hint;
  final String? value;
  final bool enabled;
  final Color themeColor;
  final VoidCallback? onTap;

  const _SelectionField({
    required this.hint,
    required this.value,
    this.enabled = true,
    required this.themeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF9F9F9) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppColors.primaryColor.withOpacity(0.5)
                : const Color(0xFFE0E0E0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: value != null
                    ? CustomTextStyles.regular16DarkGrey
                    : CustomTextStyles.semiBold16Grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled
                  ? (value != null ? AppColors.primaryColor : Colors.grey)
                  : Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
