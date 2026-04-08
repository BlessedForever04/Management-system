import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/model/activity.dart';
import 'package:managementt/model/dashboard_models.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/activity_service.dart';
import 'package:managementt/service/member_service.dart';
import 'package:managementt/service/task_service.dart';

class UserDashboardController extends GetxController {
  final TaskService _taskService = TaskService();
  final ActivityService _activityService = ActivityService();
  final MemberService _memberService = MemberService();

  var projects = <Task>[].obs;
  var tasks = <Task>[].obs;
  var activities = <Activity>[].obs;
  var members = <Member>[].obs;
  var isLoading = false.obs;
  var currentMember = Rxn<Member>();

  @override
  void onInit() {
    super.onInit();
    final auth = AuthController.to;
    ever(auth.isLoggedIn, (loggedIn) {
      if (loggedIn) loadDashboard();
    });
    Future.microtask(() {
      if (auth.isLoggedIn.value && projects.isEmpty && tasks.isEmpty) {
        loadDashboard();
      }
    });
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      List<Task> loadedProjects = const [];
      List<Task> loadedTasks = const [];
      List<Activity> loadedActivities = const [];
      List<Member> loadedMembers = const [];

      // First, load members to get current user's ID
      try {
        loadedMembers = await _memberService.getMembers();
      } catch (e) {
        print('UserDashboardController: Failed to load members — $e');
      }

      final username = AuthController.to.username.value;
      String? currentUserId;
      if (username.isNotEmpty && loadedMembers.isNotEmpty) {
        final member = loadedMembers.firstWhereOrNull(
          (m) => m.email == username,
        );
        currentUserId = member?.id;
      }
      if ((currentUserId == null || currentUserId.trim().isEmpty) &&
          AuthController.to.currentUserId.value.trim().isNotEmpty) {
        currentUserId = AuthController.to.currentUserId.value.trim();
      }

      try {
        final allProjects = await _taskService.getAllProjects();
        loadedProjects = currentUserId != null
            ? allProjects.where((p) => p.ownerId == currentUserId).toList()
            : [];
      } catch (e) {
        print('UserDashboardController: Failed to load projects — $e');
      }

      try {
        final allTasks = await _taskService.getTasksByType('TASK');
        loadedTasks = currentUserId != null
            ? allTasks.where((t) => t.ownerId == currentUserId).toList()
            : [];
      } catch (e) {
        print('UserDashboardController: Failed to load tasks — $e');
      }

      try {
        loadedActivities = currentUserId != null
            ? await _activityService.getLeaderActivities(currentUserId)
            : const <Activity>[];
      } catch (e) {
        print('UserDashboardController: Failed to load activities — $e');
      }

      projects.value = loadedProjects;
      tasks.value = loadedTasks;
      activities.value = loadedActivities;
      members.value = loadedMembers;

      if (username.isNotEmpty) {
        currentMember.value = members.firstWhereOrNull(
          (m) => m.email == username,
        );
      }
    } catch (e) {
      print('UserDashboardController: Failed to load dashboard — $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Stat card values ──

  int get projectCount => projects.length;

  bool _isDoneProject(Task project) {
    final status = (project.status ?? '').toUpperCase();
    return status == 'DONE' || status == 'COMPLETED' || project.progress >= 100;
  }

  bool _isOverdueProject(Task project) {
    return (project.status ?? '').toUpperCase() == 'OVERDUE';
  }

  bool _isNotStartedProject(Task project) {
    if (_isDoneProject(project) || _isOverdueProject(project)) return false;
    final status = (project.status ?? '').toUpperCase();
    final hasStarted =
        project.progress > 0 ||
        project.completedTask > 0 ||
        status == 'IN_PROGRESS';
    if (hasStarted) return false;
    return status == 'NOT_STARTED' || status == 'TODO' || project.progress <= 0;
  }

  bool _isInProgressProject(Task project) {
    if (_isDoneProject(project) ||
        _isOverdueProject(project) ||
        _isNotStartedProject(project)) {
      return false;
    }
    return true;
  }

  int get activeProjectCount => projects.where(_isInProgressProject).length;

  int get totalTaskCount => tasks.length;

  int get overdueCount => projects.where(_isOverdueProject).length;

  // ── Donut chart data ──

  List<StatusData> get statusData {
    final all = projects;
    final done = all.where(_isDoneProject).length;
    final inProgress = all.where(_isInProgressProject).length;
    final notStarted = all.where(_isNotStartedProject).length;
    final overdue = all.where(_isOverdueProject).length;
    return [
      StatusData(label: 'Done', count: done, color: AppColors.success),
      StatusData(
        label: 'In progress',
        count: inProgress,
        color: AppColors.info,
      ),
      StatusData(
        label: 'Not started',
        count: notStarted,
        color: const Color(0xFFD1D5DB),
      ),
      StatusData(label: 'Overdue', count: overdue, color: AppColors.error),
    ];
  }

  String get completionPercent {
    if (projects.isEmpty) return '0';
    final done = projects.where(_isDoneProject).length;
    return ((done / projects.length) * 100).toStringAsFixed(0);
  }

  // ── Deadline items ──

  List<DeadlineItem> get deadlineItems {
    final combinedItems = [...projects, ...tasks];
    return combinedItems
        .where((item) => item.deadLine != null)
        .map(
          (item) => DeadlineItem(
            title: item.title,
            subtitle: item.description,
            due: formatDeadline(item.deadLine),
            accent: projectAccent(item),
            initials: getMemberInitials(item.ownerId),
          ),
        )
        .toList();
  }

  // ── Critical alerts ──

  List<AlertItem> get criticalAlerts {
    final alerts = <AlertItem>[];

    for (final project in projects) {
      if (_isOverdueProject(project)) {
        alerts.add(
          AlertItem(
            title: '${project.title} is overdue',
            subtitle: project.description,
            project: project,
          ),
        );
      }
    }

    return alerts;
  }

  // ── Header info ──

  String get welcomeName {
    if (currentMember.value != null) {
      final fullName = currentMember.value!.name.trim();
      if (fullName.isNotEmpty) {
        return fullName.split(RegExp(r'\s+')).first;
      }
    }
    final username = AuthController.to.username.value;
    if (username.isNotEmpty) {
      final beforeAt = username.split('@').first.trim();
      if (beforeAt.isNotEmpty) return beforeAt;
    }
    return 'User';
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

  String formatDeadline(DateTime? deadline) {
    if (deadline == null) return '';
    return DateTimeHelper.remainingDaysLabel(deadline);
  }

  Color projectAccent(Task item) {
    return AppColors.stripColor(priority: item.priority, status: item.status);
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

  String formatActivityTime(DateTime? time) {
    if (time == null) return '';

    final localTime = time.toLocal();
    final hour = localTime.hour % 12 == 0 ? 12 : localTime.hour % 12;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
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

    return '${localTime.day} ${months[localTime.month - 1]} ${localTime.year}, $hour:$minute $amPm';
  }

  List<ActivityItem> get activityItems {
    return activities.take(5).map((a) {
      return ActivityItem(
        initials: getInitials(a.userName),
        message: '${a.userName} ${a.verb} "${a.projectName}"',
        project: a.projectName,
        when: formatActivityTime(a.time),
      );
    }).toList();
  }

  // ── Analytics computed properties ──

  /// Percentage of all items that are not overdue.
  String get onTimePercent {
    final allItems = [...projects, ...tasks];
    if (allItems.isEmpty) return '0';
    final overdue = allItems.where((t) => t.status == 'OVERDUE').length;
    return (((allItems.length - overdue) / allItems.length) * 100)
        .toStringAsFixed(0);
  }

  int get overdueTaskCount {
    final allItems = [...projects, ...tasks];
    return allItems.where((t) => t.status == 'OVERDUE').length;
  }

  /// Count of all items that are assigned to a member.
  String get coveragePercent {
    final allItems = [...projects, ...tasks];
    if (allItems.isEmpty) return '0';
    final assigned = allItems.where((t) => t.ownerId.isNotEmpty).length;
    return ((assigned / allItems.length) * 100).toStringAsFixed(0);
  }

  int get assignedCount {
    final allItems = [...projects, ...tasks];
    return allItems.where((t) => t.ownerId.isNotEmpty).length;
  }

  // ── Priority breakdown ──
  int get highPriorityCount {
    final allItems = [...projects, ...tasks];
    return allItems.where((t) => t.priority.toLowerCase() == 'high').length;
  }

  int get mediumPriorityCount {
    final allItems = [...projects, ...tasks];
    return allItems.where((t) => t.priority.toLowerCase() == 'medium').length;
  }

  int get lowPriorityCount {
    final allItems = [...projects, ...tasks];
    return allItems.where((t) => t.priority.toLowerCase() == 'low').length;
  }

  // ── At-risk deadlines (overdue items) ──
  List<Task> get atRiskTasks {
    final allItems = [...projects, ...tasks];
    return allItems.where((t) => t.status == 'OVERDUE').toList();
  }

  // ── Team task distribution ──
  List<Map<String, dynamic>> get teamDistribution {
    final allItems = [...projects, ...tasks];
    final result = <Map<String, dynamic>>[];
    for (final m in members) {
      final memberTasks = allItems.where((t) => t.ownerId == m.id).toList();
      result.add({
        'name': m.name.split(' ').first,
        'done': memberTasks.where((t) => t.status == 'DONE').length,
        'active': memberTasks
            .where((t) => t.status == 'IN_PROGRESS' || t.status == 'TODO')
            .length,
        'todo': memberTasks.where((t) => t.status == 'NOT_STARTED').length,
      });
    }
    return result;
  }

  // ── Top contributors (ranked by done tasks) ──
  List<Map<String, dynamic>> get topContributors {
    final allItems = [...projects, ...tasks];
    final contributors = <Map<String, dynamic>>[];
    for (final m in members) {
      final doneCount = allItems
          .where((t) => t.ownerId == m.id && t.status == 'DONE')
          .length;
      contributors.add({
        'name': m.name,
        'initials': getInitials(m.name),
        'tasksCompleted': doneCount,
      });
    }
    contributors.sort(
      (a, b) =>
          (b['tasksCompleted'] as int).compareTo(a['tasksCompleted'] as int),
    );
    return contributors.take(5).toList();
  }

  // ── Project health items ──
  List<Map<String, dynamic>> get projectHealthItems {
    final result = <Map<String, dynamic>>[];
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    for (final p in projects) {
      String status;
      Color statusColor;
      String timeInfo;

      if (p.status == 'OVERDUE') {
        status = 'Critical';
        statusColor = const Color(0xFFEF4444);
        final daysOver = p.deadLine != null
            ? today.difference(p.deadLine!).inDays
            : 0;
        timeInfo = '${daysOver}d overdue';
      } else if (p.deadLine != null &&
          p.deadLine!.difference(today).inDays <= 7) {
        status = 'At Risk';
        statusColor = const Color(0xFFF59E0B);
        timeInfo = '${p.deadLine!.difference(today).inDays}d remaining';
      } else {
        status = 'On Track';
        statusColor = const Color(0xFF10B981);
        timeInfo = p.deadLine != null
            ? '${p.deadLine!.difference(today).inDays}d remaining'
            : '';
      }

      result.add({
        'name': p.title,
        'description': p.description,
        'status': status,
        'statusColor': statusColor,
        'healthPercent': p.progress,
        'timeInfo': timeInfo,
      });
    }
    return result;
  }
}
