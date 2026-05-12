import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yemis/models/app_module_type.dart';
import 'package:yemis/models/notification/notification_model.dart';
import 'package:yemis/utils/constants/app_colors.dart';
import 'package:yemis/utils/locale_keys.dart';
import 'package:yemis/utils/theme/app_theme.dart';
import 'package:yemis/utils/theme/text_styles_custom.dart';
import 'package:yemis/viewmodels/notification/notification_viewmodel.dart';
import 'package:yemis/services/notifications/api_notification_service.dart';
import 'package:yemis/services/auth/user_session.dart';

class NotificationView extends StatelessWidget {
  final AppModuleType moduleType;

  const NotificationView({super.key, required this.moduleType});

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
    final session = context.read<UserSession>();
    final notifService = ApiNotificationService()..setToken(session.token);

    Widget view = _NotificationViewBody(
      primaryColor: _primaryColor,
      title: _title,
    );

    if (moduleType == AppModuleType.volunteer) {
      view = Theme(data: AppTheme.themeFor(AppSection.volunteer), child: view);
    }

    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(notifService)
        ..loadAll()
        ..loadPreferences(),
      child: view,
    );
  }
}

class _NotificationViewBody extends StatefulWidget {
  final Color primaryColor;
  final String title;

  const _NotificationViewBody({
    required this.primaryColor,
    required this.title,
  });

  @override
  State<_NotificationViewBody> createState() => _NotificationViewBodyState();
}

class _NotificationViewBodyState extends State<_NotificationViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final color = widget.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (vm.unreadCount > 0)
            IconButton(
              onPressed: () => vm.markAllAsRead(),
              icon: Icon(Icons.done_all_rounded, color: color),
              tooltip: 'Tümünü Okundu İşaretle',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: color,
          labelColor: color,
          unselectedLabelColor: Colors.grey.shade500,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bildirimler',
                    style: TextStyle(
                      fontFamily: 'nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (vm.unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${vm.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              child: Text(
                'Tercihler',
                style: TextStyle(
                  fontFamily: 'nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotificationsTab(primaryColor: color, vm: vm),
          _PreferencesTab(primaryColor: color, vm: vm),
        ],
      ),
    );
  }
}

// ── Notifications Tab ─────────────────────────────────────────────────────────

class _NotificationsTab extends StatelessWidget {
  final Color primaryColor;
  final NotificationViewModel vm;

  const _NotificationsTab({required this.primaryColor, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (vm.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: vm.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = vm.notifications[index];
        return _NotificationCard(
          notification: notification,
          primaryColor: primaryColor,
          timeAgo: vm.timeAgo(notification.createdAt),
          onMarkRead: () => vm.markAsRead(notification.id),
          onDelete: () => vm.deleteNotification(notification.id),
        );
      },
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
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimler burada görünecek',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final Color primaryColor;
  final String timeAgo;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.primaryColor,
    required this.timeAgo,
    required this.onMarkRead,
    required this.onDelete,
  });

  IconData get _icon {
    switch (notification.notificationType.toLowerCase()) {
      case 'volunteer':
        return Icons.volunteer_activism_outlined;
      case 'order':
        return Icons.shopping_basket_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: notification.isRead ? null : onMarkRead,
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : primaryColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withOpacity(0.5)),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: primaryColor, size: 22),
            ),
            title: Text(
              notification.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.2,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: notification.isRead
                        ? FontWeight.w400
                        : FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            trailing: !notification.isRead
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// ── Preferences Tab ───────────────────────────────────────────────────────────

class _PreferencesTab extends StatelessWidget {
  final Color primaryColor;
  final NotificationViewModel vm;

  const _PreferencesTab({required this.primaryColor, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isPrefsLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    final prefs = vm.preferences;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Kanal Tercihleri'),
        const SizedBox(height: 12),
        _buildPrefsCard([
          _PrefItem(
            icon: Icons.notifications_active_outlined,
            title: 'Push Bildirimleri',
            subtitle: 'Uygulama içi anlık bildirimler',
            value: prefs.pushEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(pushEnabled: v)),
          ),
          _PrefItem(
            icon: Icons.email_outlined,
            title: 'E-posta Bildirimleri',
            subtitle: 'E-posta ile bildirim al',
            value: prefs.emailEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(emailEnabled: v)),
          ),
        ]),
        const SizedBox(height: 20),
        _buildSectionHeader('Bildirim Türleri'),
        const SizedBox(height: 12),
        _buildPrefsCard([
          _PrefItem(
            icon: Icons.shopping_basket_outlined,
            title: 'Sipariş Güncellemeleri',
            subtitle: 'Sipariş durumu değişikliklerinde bildirim al',
            value: prefs.orderUpdatesEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(orderUpdatesEnabled: v)),
          ),
          _PrefItem(
            icon: Icons.local_offer_outlined,
            title: 'Promosyonlar',
            subtitle: 'Kampanya ve fırsat bildirimleri',
            value: prefs.promotionsEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(promotionsEnabled: v)),
          ),
          _PrefItem(
            icon: Icons.volunteer_activism_outlined,
            title: 'Gönüllü Güncellemeleri',
            subtitle: 'Gönüllü ilan ve görev bildirimleri',
            value: prefs.volunteerUpdatesEnabled,
            color: primaryColor,
            onChanged: (v) => vm.updatePreferences(
              prefs.copyWith(volunteerUpdatesEnabled: v),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tercihleriniz anında kaydedilir. Değişiklikler tüm cihazlarınıza yansır.',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF888888),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPrefsCard(List<_PrefItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                value: item.value,
                onChanged: item.onChanged,
                activeColor: item.color,
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 60, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }
}

class _PrefItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _PrefItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });
}
