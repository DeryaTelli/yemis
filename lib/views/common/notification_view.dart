import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/app_module_type.dart';
import '../../utils/theme/text_styles_custom.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/locale_keys.dart';

class NotificationView extends StatelessWidget {
  final AppModuleType moduleType;

  const NotificationView({
    super.key,
    required this.moduleType,
  });

  Color get _primaryColor {
    switch (moduleType) {
      case AppModuleType.volunteer:
        return AppColors.volunteerColor;
      case AppModuleType.food:
      case AppModuleType.business:
        return AppColors.primaryColor;
    }
  }

  String get _title {
    switch (moduleType) {
      case AppModuleType.volunteer:
        return LocaleKeys.volunteerProfile_notifications.tr();
      case AppModuleType.business:
        return LocaleKeys.businessProfile_notifications.tr();
      case AppModuleType.food:
        return LocaleKeys.foodProfile_notifications.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Yeni Sipariş!',
        'body': 'Bir kullanıcı yemeğini rezerve etti.',
        'time': '2 dakika önce',
        'isRead': false,
        'icon': Icons.shopping_basket_outlined,
      },
      {
        'title': 'Gönüllü Çağrısı',
        'body': 'Yakınınızda yeni bir yardım talebi var.',
        'time': '1 saat önce',
        'isRead': true,
        'icon': Icons.volunteer_activism_outlined,
      },
      {
        'title': 'Adres Doğrulandı',
        'body': 'Yeni adresiniz başarıyla doğrulandı.',
        'time': 'Dün',
        'isRead': true,
        'icon': Icons.location_on_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _title,
          style: CustomTextStyles.orelegaOne32Primary.copyWith(color: _primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      decoration: BoxDecoration(
        color: notification['isRead'] ? Colors.white : _primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification['isRead'] ? Colors.grey.shade200 : _primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification['icon'],
            color: _primaryColor,
            size: 24,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                notification['title'],
                style: CustomTextStyles.extraBold16Black,
              ),
            ),
            if (!notification['isRead'])
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['body'],
              style: CustomTextStyles.regular14Grey,
            ),
            const SizedBox(height: 8),
            Text(
              notification['time'],
              style: CustomTextStyles.italic14Grey.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bildiriminiz yok',
            style: CustomTextStyles.semiBold16Grey,
          ),
        ],
      ),
    );
  }
}
