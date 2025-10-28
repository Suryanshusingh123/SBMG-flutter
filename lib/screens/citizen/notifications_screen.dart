import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeNotifications();
      _initialized = true;
    }
  }

  void _initializeNotifications() {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      setState(() {
        _notifications = [
          NotificationItem(
            title: l10n.complaintResolved,
            description: l10n.complaintResolvedDescription,
            timeAgo: l10n.fiveMinutesAgo,
            isUnread: true,
          ),
          NotificationItem(
            title: l10n.newSchemeAdded,
            description: l10n.newSchemeAddedDescription,
            timeAgo: l10n.fiveMinutesAgo,
            isUnread: true,
          ),
          NotificationItem(
            title: l10n.upcomingEvents,
            description: l10n.upcomingEventsDescription,
            timeAgo: l10n.fiveMinutesAgo,
            isUnread: true,
          ),
        ];
      });
    }
  }

  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notification,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAllNotifications,
              child: Text(
                l10n.clearAll,
                style: const TextStyle(
                  color: Color(0xFF009B56),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.noNotifications,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(_notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dot
          if (notification.isUnread)
            Container(
              margin: EdgeInsets.only(right: 12.w, top: 6.h),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF009B56),
                shape: BoxShape.circle,
              ),
            ),
          if (!notification.isUnread) SizedBox(width: 8 + 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF111827),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    if (notification.isUnread)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            notification.isUnread = false;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final String timeAgo;
  bool isUnread;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.isUnread,
  });
}
