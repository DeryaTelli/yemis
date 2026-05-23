class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String message;
  final String notificationType;
  final String category;
  final String icon;
  final String accentColor;
  final String backgroundColor;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.message,
    required this.notificationType,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = json['notification_type']?.toString() ?? 'general';
    final category = json['category']?.toString() ?? _categoryForType(type);
    final message = json['message']?.toString() ?? '';
    final body = json['body']?.toString() ?? message;

    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title']?.toString() ?? _titleForCategory(category),
      body: body,
      message: message.isNotEmpty ? message : body,
      notificationType: type,
      category: category,
      icon: json['icon']?.toString() ?? _iconForCategory(category),
      accentColor:
          json['accent_color']?.toString() ?? _accentForCategory(category),
      backgroundColor:
          json['background_color']?.toString() ??
          _backgroundForCategory(category),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      message: message,
      notificationType: notificationType,
      category: category,
      icon: icon,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  static String _categoryForType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('volunteer') || normalized.startsWith('meal_')) {
      return 'volunteer';
    }
    if (normalized.contains('order')) return 'order';
    if (normalized.contains('promo') || normalized.contains('campaign')) {
      return 'promotion';
    }
    if (normalized.contains('review')) return 'review';
    if (normalized.contains('system')) return 'system';
    return 'general';
  }

  static String _titleForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'volunteer':
        return 'Gonullu Guncellemesi';
      case 'order':
        return 'Siparis Bildirimi';
      case 'promotion':
        return 'Kampanya Firsati';
      case 'review':
        return 'Yeni Yorum';
      case 'system':
        return 'Sistem Mesaji';
      default:
        return 'Bildirim';
    }
  }

  static String _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'volunteer':
        return 'user-plus';
      case 'order':
        return 'receipt';
      case 'promotion':
        return 'local-offer';
      case 'review':
        return 'star';
      case 'system':
        return 'settings';
      default:
        return 'bell';
    }
  }

  static String _accentForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'volunteer':
        return '#F97316';
      case 'order':
        return '#22C55E';
      case 'promotion':
        return '#EC4899';
      case 'review':
        return '#8B5CF6';
      case 'system':
        return '#64748B';
      default:
        return '#F97316';
    }
  }

  static String _backgroundForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'volunteer':
        return '#FFF7ED';
      case 'order':
        return '#F0FDF4';
      case 'promotion':
        return '#FDF2F8';
      case 'review':
        return '#F5F3FF';
      case 'system':
        return '#F8FAFC';
      default:
        return '#FFF7ED';
    }
  }
}

class NotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool orderUpdatesEnabled;
  final bool promotionsEnabled;
  final bool volunteerUpdatesEnabled;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.orderUpdatesEnabled = true,
    this.promotionsEnabled = true,
    this.volunteerUpdatesEnabled = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushEnabled: json['push_enabled'] == true,
      emailEnabled: json['email_enabled'] == true,
      orderUpdatesEnabled: json['order_updates_enabled'] == true,
      promotionsEnabled: json['promotions_enabled'] == true,
      volunteerUpdatesEnabled: json['volunteer_updates_enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'push_enabled': pushEnabled,
    'email_enabled': emailEnabled,
    'order_updates_enabled': orderUpdatesEnabled,
    'promotions_enabled': promotionsEnabled,
    'volunteer_updates_enabled': volunteerUpdatesEnabled,
  };

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? orderUpdatesEnabled,
    bool? promotionsEnabled,
    bool? volunteerUpdatesEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      orderUpdatesEnabled: orderUpdatesEnabled ?? this.orderUpdatesEnabled,
      promotionsEnabled: promotionsEnabled ?? this.promotionsEnabled,
      volunteerUpdatesEnabled:
          volunteerUpdatesEnabled ?? this.volunteerUpdatesEnabled,
    );
  }
}
