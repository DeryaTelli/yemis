class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = json['notification_type']?.toString() ?? 'general';
    String defaultTitle = 'Bildirim';
    switch (type.toLowerCase()) {
      case 'volunteer':
        defaultTitle = 'Gönüllü Güncellemesi';
        break;
      case 'order':
        defaultTitle = 'Sipariş Bildirimi';
        break;
      case 'promotion':
        defaultTitle = 'Kampanya Fırsatı';
        break;
      case 'system':
        defaultTitle = 'Sistem Mesajı';
        break;
    }

    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title']?.toString() ?? defaultTitle,
      message: json['message']?.toString() ?? '',
      notificationType: type,
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
      message: message,
      notificationType: notificationType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
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
      volunteerUpdatesEnabled: volunteerUpdatesEnabled ?? this.volunteerUpdatesEnabled,
    );
  }
}
