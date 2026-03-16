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

      try {
        final allProjects = await _taskService.getTasksByType('PROJECT');
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
        loadedActivities = await _activityService.getActivities();
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
      if (project.status == 'OVERDUE') {
        alerts.add(
          AlertItem(
            title: '${project.title} is overdue',
            subtitle: project.description,
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

  Color projectAccent(Task p) {
    final statusUpper = (p.status ?? '').toUpperCase();
    if (statusUpper == 'DONE') return AppColors.success;
    if (statusUpper == 'IN_PROGRESS') return AppColors.info;
    if (statusUpper == 'OVERDUE') return AppColors.warning;
    return const Color(0xFFD1D5DB);
  }

  String formatDeadline(DateTime? dt) {
    if (dt == null) return 'No deadline';
    return DateTimeHelper.remainingDaysLabel(dt);
  }
}
