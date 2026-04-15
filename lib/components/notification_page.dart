import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/notification_tile.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/app_notification.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  final Map<String, String> _projectNameCache = <String, String>{};
  late final TaskController? _taskController;
  late Future<List<AppNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _taskController = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : null;
    _notificationsFuture = _loadNotifications();
  }

  Future<List<AppNotification>> _loadNotifications() async {
    final memberId = AuthController.to.currentUserId.value.trim();
    if (memberId.isEmpty) {
      return const <AppNotification>[];
    }

    final notifications = await _notificationService.getNotifications(memberId);
    await _cacheProjectNames(notifications);
    return notifications;
  }

  Future<void> _refresh() async {
    final next = _loadNotifications();
    setState(() {
      _notificationsFuture = next;
    });
    await next;
  }

  NotificationTileData _toTileData(AppNotification notification) {
    final type = notification.eventType.trim().toUpperCase();
    final helperId = (notification.helperId ?? '').trim();

    IconData icon;
    Color iconBackground;

    switch (type) {
      case 'NEW_TASK_CREATION':
        icon = Icons.assignment_turned_in_outlined;
        iconBackground = const Color(0xFF2563EB);
        break;
      case 'REMARK_SECTION':
        icon = Icons.chat_bubble_outline;
        iconBackground = const Color(0xFF8B5CF6);
        break;
      case 'REVIEW_REQUEST':
        icon = Icons.rate_review_outlined;
        iconBackground = const Color(0xFF0EA5A4);
        break;
      case 'OVERDUE_WARNING':
        icon = Icons.warning_amber_rounded;
        iconBackground = const Color(0xFFEF4444);
        break;
      case 'PROJECT_READY_TO_WORK':
        icon = Icons.play_circle_outline;
        iconBackground = const Color(0xFF10B981);
        break;
      default:
        icon = Icons.notifications_none_rounded;
        iconBackground = const Color(0xFFFF7A1A);
    }

    return NotificationTileData(
      title: _projectNameCache[helperId] ?? 'Unknown Project',
      message: notification.message.isNotEmpty
          ? notification.message
          : 'You have a new update.',
      timeLabel: _formatTimeLabel(notification.time),
      icon: icon,
      iconBackground: iconBackground,
      isUnread: true,
    );
  }

  Future<void> _cacheProjectNames(List<AppNotification> notifications) async {
    final helperIds = notifications
        .map((n) => (n.helperId ?? '').trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final helperId in helperIds) {
      if (_projectNameCache.containsKey(helperId)) continue;
      _projectNameCache[helperId] = await _resolveProjectName(helperId);
    }
  }

  Future<String> _resolveProjectName(String helperId) async {
    try {
      final controller = _taskController;
      if (controller != null) {
        final matches = controller.projects.where((project) => project.id == helperId);
        if (matches.isNotEmpty) {
          final existing = matches.first;
          if (existing.title.trim().isNotEmpty) {
            return existing.title;
          }
        }

        final task = await controller.getTaskById(helperId);
        if (task.title.trim().isNotEmpty) {
          return task.title;
        }
      }
    } catch (_) {
      // Fall back to default title below.
    }
    return 'Unknown Project';
  }

  Future<void> _openProjectDetails(AppNotification notification) async {
    final projectId = (notification.helperId ?? '').trim();
    if (projectId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project id is missing for this notification.')),
      );
      return;
    }

    final controller = _taskController;
    if (controller == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task controller is not available.')),
      );
      return;
    }

    try {
      final matches = controller.projects.where((p) => p.id == projectId);
      final Task resolved = matches.isNotEmpty
          ? matches.first
          : await controller.getTaskById(projectId);

      await Get.to(() => ProjectDetailPage(project: resolved));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open project details.')),
      );
    }
  }

  String _formatTimeLabel(DateTime? value) {
    if (value == null) return 'Unknown time';

    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    final yyyy = value.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Notifications'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: FutureBuilder<List<AppNotification>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load notifications',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            (snapshot.error?.toString() ?? 'Unknown error')
                                .replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final notifications = snapshot.data ?? const <AppNotification>[];
              final tiles = notifications.map(_toTileData).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${tiles.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: tiles.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: 260,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.info.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.inbox_outlined,
                                          color: AppColors.info,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No notifications yet',
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        "You're all caught up!",
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: tiles.length,
                              itemBuilder: (context, index) {
                                return NotificationTile(
                                  notification: tiles[index],
                                  onTap: () => _openProjectDetails(notifications[index]),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
