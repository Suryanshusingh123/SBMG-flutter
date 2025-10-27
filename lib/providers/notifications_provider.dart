import 'package:flutter/material.dart';

enum NotificationType { complaint, scheme, event }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final bool isRead;
  final NotificationType type;
  final String? imageUrl;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.imageUrl,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    bool? isRead,
    NotificationType? type,
    String? imageUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class NotificationsProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get notificationsCount => _notifications.length;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasNotifications => _notifications.isNotEmpty;

  void loadNotifications() {
    // Sample data - replace with actual API call
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Complaint resolved',
        description:
            'Complaint id XYZ resolved by supervisor, please confirm if you are satisfied',
        timestamp: '5 min ago',
        isRead: false,
        type: NotificationType.complaint,
      ),
      NotificationItem(
        id: '2',
        title: 'New scheme added',
        description: 'New scheme added, might be helpful to you',
        timestamp: '5 min ago',
        isRead: false,
        type: NotificationType.scheme,
      ),
      NotificationItem(
        id: '3',
        title: 'Upcoming events',
        description: 'New event coming, checkout more details',
        timestamp: '5 min ago',
        isRead: false,
        type: NotificationType.event,
      ),
    ];
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    _notifications = _notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void markAllAsRead() {
    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }
}
