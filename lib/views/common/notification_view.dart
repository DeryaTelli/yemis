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
              tooltip: LocaleKeys.notifications_markAllRead.tr(),
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
                  Text(
                    LocaleKeys.notifications_title.tr(),
                    style: const TextStyle(
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
            Tab(
              child: Text(
                LocaleKeys.notifications_preferences.tr(),
                style: const TextStyle(
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
            LocaleKeys.notifications_emptyTitle.tr(),
            style: CustomTextStyles.semiBold16Grey,
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.notifications_emptySubtitle.tr(),
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
    switch (notification.icon.toLowerCase()) {
      case 'user-plus':
        return Icons.person_add_alt_1_outlined;
      case 'clock':
        return Icons.access_time_rounded;
      case 'badge-check':
      case 'check-circle':
        return Icons.check_circle_outline_rounded;
      case 'x-circle':
        return Icons.cancel_outlined;
      case 'package-check':
        return Icons.inventory_2_outlined;
      case 'home':
        return Icons.home_work_outlined;
      case 'star':
        return Icons.star_border_rounded;
      case 'undo-2':
        return Icons.undo_rounded;
      case 'alarm-clock':
        return Icons.alarm_rounded;
      case 'receipt':
        return Icons.receipt_long_outlined;
      case 'map-pin':
        return Icons.location_on_outlined;
      case 'refresh-cw':
        return Icons.sync_rounded;
      case 'local-offer':
        return Icons.local_offer_outlined;
      case 'settings':
        return Icons.settings_outlined;
      case 'bell':
        return Icons.notifications_outlined;
    }

    switch (notification.category.toLowerCase()) {
      case 'volunteer':
        return Icons.volunteer_activism_outlined;
      case 'order':
        return Icons.shopping_basket_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'review':
        return Icons.star_border_rounded;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String get _emoji {
    switch (notification.icon.toLowerCase()) {
      case 'user-plus':
        return '🙋';
      case 'clock':
        return '⏳';
      case 'badge-check':
      case 'check-circle':
        return '✅';
      case 'x-circle':
        return '❌';
      case 'package-check':
        return '📦';
      case 'home':
        return '🏠';
      case 'star':
        return '⭐';
      case 'undo-2':
        return '↩️';
      case 'alarm-clock':
        return '⏰';
      case 'receipt':
        return '🧾';
      case 'map-pin':
        return '📍';
      case 'refresh-cw':
        return '🔄';
      case 'local-offer':
        return '🎁';
    }

    switch (notification.category.toLowerCase()) {
      case 'volunteer':
        return '🐾';
      case 'order':
        return '🛍️';
      case 'promotion':
        return '✨';
      case 'review':
        return '⭐';
      case 'system':
        return '🔔';
      default:
        return '🔔';
    }
  }

  String get _categoryLabel {
    switch (notification.category.toLowerCase()) {
      case 'volunteer':
        return 'Gonullu';
      case 'order':
        return 'Siparis';
      case 'promotion':
        return 'Firsat';
      case 'review':
        return 'Yorum';
      case 'system':
        return 'Sistem';
      default:
        return 'Bildirim';
    }
  }

  Color _colorFromHex(String value, Color fallback) {
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return fallback;
    final colorValue = int.tryParse(normalized, radix: 16);
    if (colorValue == null) return fallback;
    return Color(normalized.length == 6 ? 0xFF000000 | colorValue : colorValue);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _colorFromHex(notification.accentColor, primaryColor);
    final backgroundColor = _colorFromHex(
      notification.backgroundColor,
      accentColor.withValues(alpha: 0.08),
    );
    final cardColor = notification.isRead
        ? Colors.white
        : Color.alphaBlend(
            accentColor.withValues(alpha: 0.07),
            backgroundColor,
          );
    final borderColor = notification.isRead
        ? Colors.grey.shade200
        : accentColor.withValues(alpha: 0.24);

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(
                    alpha: notification.isRead ? 0.035 : 0.11,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  left: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(width: 4, color: accentColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 15, 16, 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(_icon, color: accentColor, size: 23),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _NotificationPill(
                                  label: timeAgo,
                                  color: accentColor,
                                  filled: !notification.isRead,
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              notification.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.35,
                                fontWeight: notification.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _NotificationPill(
                                  label: '$_emoji $_categoryLabel',
                                  color: accentColor,
                                ),
                                if (!notification.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Yeni',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: notification.isRead
                                        ? Colors.grey.shade300
                                        : accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Preferences Tab ───────────────────────────────────────────────────────────

class _NotificationPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _NotificationPill({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? color : color.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: filled ? Colors.white : color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

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
        _buildSectionHeader(LocaleKeys.notifications_channelPrefs.tr()),
        const SizedBox(height: 12),
        _buildPrefsCard([
          _PrefItem(
            icon: Icons.notifications_active_outlined,
            title: LocaleKeys.notifications_pushTitle.tr(),
            subtitle: LocaleKeys.notifications_pushSubtitle.tr(),
            value: prefs.pushEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(pushEnabled: v)),
          ),
          _PrefItem(
            icon: Icons.email_outlined,
            title: LocaleKeys.notifications_emailTitle.tr(),
            subtitle: LocaleKeys.notifications_emailSubtitle.tr(),
            value: prefs.emailEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(emailEnabled: v)),
          ),
        ]),
        const SizedBox(height: 20),
        _buildSectionHeader(LocaleKeys.notifications_typePrefs.tr()),
        const SizedBox(height: 12),
        _buildPrefsCard([
          _PrefItem(
            icon: Icons.shopping_basket_outlined,
            title: LocaleKeys.notifications_orderTitle.tr(),
            subtitle: LocaleKeys.notifications_orderSubtitle.tr(),
            value: prefs.orderUpdatesEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(orderUpdatesEnabled: v)),
          ),
          _PrefItem(
            icon: Icons.local_offer_outlined,
            title: LocaleKeys.notifications_promoTitle.tr(),
            subtitle: LocaleKeys.notifications_promoSubtitle.tr(),
            value: prefs.promotionsEnabled,
            color: primaryColor,
            onChanged: (v) =>
                vm.updatePreferences(prefs.copyWith(promotionsEnabled: v)),
          ),
          _PrefItem(
            icon: Icons.volunteer_activism_outlined,
            title: LocaleKeys.notifications_volunteerTitle.tr(),
            subtitle: LocaleKeys.notifications_volunteerSubtitle.tr(),
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
                  LocaleKeys.notifications_prefsNote.tr(),
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
