import 'package:flutter/material.dart';
import 'package:managementt/components/app_colors.dart';

class NotificationTileData {
  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color iconBackground;
  final bool isUnread;

  const NotificationTileData({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.iconBackground,
    this.isUnread = false,
  });
}

class NotificationTile extends StatelessWidget {
  final NotificationTileData notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final cardColor = isUnread ? Colors.white : const Color(0xFFF3F4F6);
    final borderColor = isUnread
        ? AppColors.borderColor
        : const Color(0xFFE5E7EB);
    final titleColor = isUnread
        ? const Color(0xFF111827)
        : const Color(0xFF6B7280);
    final messageColor = isUnread
        ? AppColors.textSecondary
        : const Color(0xFF9CA3AF);
    final timeColor = isUnread
        ? Colors.blueGrey.withValues(alpha: 0.7)
        : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: isUnread
                    ? notification.iconBackground
                    : notification.iconBackground.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: notification.iconBackground.withValues(
                        alpha: isUnread ? 0.1 : 0.07,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notification.icon,
                      color: isUnread
                          ? notification.iconBackground
                          : notification.iconBackground.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 13,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            if (notification.isUnread)
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (onDelete != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: isDeleting
                                      ? Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.error,
                                                ),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: onDelete,
                                          tooltip: 'Delete notification',
                                          icon: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 16,
                                            color: AppColors.error,
                                          ),
                                          padding: EdgeInsets.zero,
                                          splashRadius: 16,
                                          constraints: const BoxConstraints(),
                                        ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: messageColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: timeColor,
                            fontWeight: isUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
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
    );
  }
}
