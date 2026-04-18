import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/notification_page.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/service/notification_service.dart';

class NotificationBellButton extends StatefulWidget {
  final Color iconColor;
  final double iconSize;
  final String tooltip;

  const NotificationBellButton({
    super.key,
    required this.iconColor,
    this.iconSize = 26,
    this.tooltip = 'Notifications',
  });

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final memberId = AuthController.to.currentUserId.value.trim();
    if (memberId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _unreadCount = 0;
      });
      return;
    }

    try {
      final unreadCount = await _notificationService.getUnreadNotificationCount(
        memberId,
      );
      if (!mounted) return;
      setState(() {
        _unreadCount = unreadCount < 0 ? 0 : unreadCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unreadCount = 0;
      });
    }
  }

  Future<void> _openNotificationPage() async {
    await Get.to(() => const NotificationPage());
    if (!mounted) return;
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _unreadCount > 0;
    final badgeText = _unreadCount > 99 ? '99+' : '$_unreadCount';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: _openNotificationPage,
          icon: Icon(
            Icons.notifications_none_rounded,
            color: widget.iconColor,
            size: widget.iconSize,
          ),
          splashRadius: 22,
          tooltip: widget.tooltip,
        ),
        if (hasUnread)
          Positioned(
            right: 6,
            top: 5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 1.4),
              ),
              child: Center(
                child: Text(
                  badgeText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
