import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/theme/app_theme.dart';
import '../../viewmodels/volunteer/volunteer_add_address_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Gönüllü tarafı için yeni adres ekleme ekranı.
/// Volunteer teması otomatik uygulanır.
class VolunteerAddAddressView extends StatelessWidget {
  const VolunteerAddAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.themeFor(AppSection.volunteer),
      child: ChangeNotifierProvider(
        create: (_) => VolunteerAddAddressViewModel(),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VolunteerAddAddressViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Adres Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── İl ───────────────────────────────────────────────────────────
            _fieldLabel('İl'),
            _SelectionField(
              hint: 'Seçiniz',
              value: vm.selectedIl,
              items: vm.iller,
              onTap: (context) =>
                  _showPicker(context, 'İl Seçiniz', vm.iller, vm.selectIl),
            ),
            const SizedBox(height: 16),

            // ── İlçe ─────────────────────────────────────────────────────────
            _fieldLabel('İlçe'),
            _SelectionField(
              hint: vm.selectedIl == null ? 'Önce il seçiniz' : 'Seçiniz',
              value: vm.selectedIlce,
              items: vm.ilceler,
              enabled: vm.selectedIl != null,
              onTap: vm.selectedIl == null
                  ? null
                  : (context) => _showPicker(
                      context,
                      'İlçe Seçiniz',
                      vm.ilceler,
                      vm.selectIlce,
                    ),
            ),
            const SizedBox(height: 16),

            // ── Mahalle ───────────────────────────────────────────────────────
            _fieldLabel('Mahalle'),
            _SelectionField(
              hint: vm.selectedIlce == null ? 'Önce ilçe seçiniz' : 'Seçiniz',
              value: vm.selectedMahalle,
              items: vm.mahalleler,
              enabled: vm.selectedIlce != null,
              onTap: vm.selectedIlce == null
                  ? null
                  : (context) => _showPicker(
                      context,
                      'Mahalle Seçiniz',
                      vm.mahalleler,
                      vm.selectMahalle,
                    ),
            ),
            const SizedBox(height: 24),

            // ── Açık Adres ────────────────────────────────────────────────────
            _fieldLabel('Adres'),
            CustomTextField(
              controller: vm.adresController,
              hintText: 'Cadde, mahalle sokak ve diğer bilgileri giriniz.',
              maxLines: 3,
              borderColor: const Color(0xFFE0E0E0),
              fillColor: const Color(0xFFF9F9F9),
            ),
            const SizedBox(height: 16),

            // ── Adres Başlığı ─────────────────────────────────────────────────
            _fieldLabel('Adres Başlığı'),
            CustomTextField(
              controller: vm.baslikController,
              hintText: 'Adres Başlığı Giriniz',
              borderColor: const Color(0xFFE0E0E0),
              fillColor: const Color(0xFFF9F9F9),
            ),
            const SizedBox(height: 32),

            // ── Kaydet Butonu ─────────────────────────────────────────────────
            CustomButton(
              text: 'Kaydet',
              gradient: AppColors.volunteerBackgroundGradient,
              width: double.infinity,
              height: 54,
              borderRadius: 14,
              onPressed: () => Navigator.pop(context, vm.formattedAddress),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryTextColor,
    ),
  );

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryTextColor,
      ),
    ),
  );

  void _showPicker(
    BuildContext context,
    String title,
    List<String> items,
    void Function(String?) onSelect,
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
                    fontWeight: FontWeight.w700,
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
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.volunteerColor,
                      size: 18,
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

/// Dropdown-gibi görünen seçim alanı.
class _SelectionField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final bool enabled;
  final void Function(BuildContext)? onTap;

  const _SelectionField({
    required this.hint,
    required this.value,
    required this.items,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF9F9F9) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? AppColors.volunteerColor.withValues(alpha: 0.5)
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
                  ? (value != null
                        ? AppColors.volunteerColor
                        : AppColors.hintTextColor)
                  : AppColors.hintTextColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
