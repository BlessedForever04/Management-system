import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/model/activity.dart';
import 'package:managementt/model/dashboard_models.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/activity_service.dart';
import 'package:managementt/service/member_service.dart';
import 'package:managementt/service/task_service.dart';

class DashboardController extends GetxController {
  final TaskService _taskService = TaskService();
  final ActivityService _activityService = ActivityService();
  final MemberService _memberService = MemberService();

  var projects = <Task>[].obs;
  var tasks = <Task>[].obs;
  var activities = <Activity>[].obs;
  var members = <Member>[].obs;
  var isLoading = false.obs;
  var currentMember = Rxn<Member>();

  List<Task> get allItems => [...projects, ...tasks];

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _taskService.getTasksByType('PROJECT'),
        _taskService.getTasksByType('TASK'),
        _activityService.getActivities(),
        _memberService.getMembers(),
      ]);
      projects.value = results[0] as List<Task>;
      tasks.value = results[1] as List<Task>;
      activities.value = results[2] as List<Activity>;
      members.value = results[3] as List<Member>;

      final username = AuthController.to.username.value;
      if (username.isNotEmpty) {
        currentMember.value = members.firstWhereOrNull(
          (m) => m.email == username,
        );
      }
    } catch (e) {
      print('DashboardController: Failed to load dashboard — $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Stat card values ──

  int get projectCount => projects.length;

  int get activeProjectCount =>
      projects.where((p) => p.status == 'IN_PROGRESS').length;

  int get totalTaskCount => tasks.length;

  int get overdueCount => projects.where((p) => p.status == 'OVERDUE').length;

  // ── Donut chart data ──

  List<StatusData> get statusData {
    final all = projects;
    final done = all.where((p) => p.status == 'DONE').length;
    final inProgress = all.where((p) => p.status == 'IN_PROGRESS').length;
    final notStarted = all.where((p) => p.status == 'NOT_STARTED').length;
    final overdue = all.where((p) => p.status == 'OVERDUE').length;
    return [
      StatusData(label: 'Done', count: done, color: AppColors.success),
      StatusData(
        label: 'In Progress',
        count: inProgress,
        color: AppColors.info,
      ),
      StatusData(
        label: 'Not Started',
        count: notStarted,
        color: const Color(0xFFD1D5DB),
      ),
      StatusData(label: 'Overdue', count: overdue, color: AppColors.warning),
    ];
  }

  String get completionPercent {
    if (projects.isEmpty) return '0';
    final done = projects.where((p) => p.status == 'DONE').length;
    return ((done / projects.length) * 100).toStringAsFixed(0);
  }

  // ── Header info ──

  String get welcomeName {
    if (currentMember.value != null) return currentMember.value!.name;
    final username = AuthController.to.username.value;
    if (username.isNotEmpty) return username;
    return 'Admin';
  }

  String get formattedDate {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ── Member helpers ──

  String getMemberName(String ownerId) {
    final member = members.firstWhereOrNull((m) => m.id == ownerId);
    return member?.name ?? 'Unknown';
  }

  String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String getMemberInitials(String ownerId) {
    return getInitials(getMemberName(ownerId));
  }

  // ── Date formatting ──

  String formatDeadline(DateTime? deadline) {
    if (deadline == null) return '';
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final diff = deadline.difference(today).inDays;
    if (diff > 0) return '${diff}d left';
    if (diff < 0) return '${-diff}d over';
    return 'Today';
  }

  Color deadlineColor(DateTime? deadline) {
    if (deadline == null) return AppColors.warning;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final diff = deadline.difference(today).inDays;
    if (diff < 0) return AppColors.error;
    if (diff <= 7) return AppColors.warning;
    return AppColors.success;
  }

  String formatRelativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  // ── Dashboard section data ──

  List<AlertItem> get criticalAlerts {
    final overdueItems = allItems.where((t) => t.status == 'OVERDUE').toList();
    if (overdueItems.isEmpty) return [];
    final alerts = <AlertItem>[];
    for (final p in projects.where((p) => p.status == 'OVERDUE')) {
      if (p.deadLine != null) {
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final daysOver = today.difference(p.deadLine!).inDays;
        alerts.add(
          AlertItem(title: p.title, subtitle: '${daysOver}d past deadline'),
        );
      }
    }
    alerts.add(
      AlertItem(
        title: '${overdueItems.length} tasks overdue',
        subtitle: 'Tap to view and resolve',
      ),
    );
    return alerts;
  }

  List<DeadlineItem> get deadlineItems {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final withDeadlines = projects.where((p) => p.deadLine != null).toList();
    // Sort by remaining days descending (most remaining first)
    withDeadlines.sort((a, b) {
      final remainA = a.deadLine!.difference(today).inDays;
      final remainB = b.deadLine!.difference(today).inDays;
      return remainB.compareTo(remainA);
    });
    return withDeadlines.take(5).map((p) {
      final ownerName = getMemberName(p.ownerId);
      return DeadlineItem(
        title: p.title,
        subtitle: p.description,
        due: formatDeadline(p.deadLine),
        accent: deadlineColor(p.deadLine),
        initials: getInitials(ownerName),
      );
    }).toList();
  }

  List<ActivityItem> get activityItems {
    return activities.take(5).map((a) {
      return ActivityItem(
        initials: getInitials(a.userName),
        message: '${a.userName} ${a.verb} "${a.projectName}"',
        project: a.projectName,
        when: formatRelativeTime(a.time),
      );
    }).toList();
  }

  static const _projectAccents = [
    AppColors.projectBlue,
    AppColors.projectTeal,
    AppColors.projectPink,
    AppColors.projectPurple,
  ];

  Color projectAccent(int index) {
    return _projectAccents[index % _projectAccents.length];
  }
}
