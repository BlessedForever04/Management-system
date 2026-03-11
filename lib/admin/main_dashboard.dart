import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/animated_gradient_container.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/dashboard_tiles.dart';
import 'package:managementt/components/donut_chart.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/components/section_header.dart';
import 'package:managementt/components/stat_card.dart';
import 'package:managementt/controller/dashboard_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        top: false,
        child: Obx(() {
          final statusData = dc.statusData;
          final criticalAlerts = dc.criticalAlerts;
          final upcomingDeadlines = dc.deadlineItems;
          final recentActivity = dc.activityItems;

          final totalStatusCount = statusData.fold<int>(
            0,
            (sum, item) => sum + item.count,
          );
          final completionPercent = dc.completionPercent;

          return SingleChildScrollView(
            child: Column(
              children: [
                AnimatedGradientContainer(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    MediaQuery.of(context).padding.top + 10,
                    12,
                    14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        dc.welcomeName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        dc.formattedDate,
                        style: TextStyle(color: Colors.white),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.folder_open,
                              count: '${dc.projectCount}',
                              label: 'Projects',
                              iconColor: const Color(0xFFF3B200),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              icon: Icons.edit_note,
                              count: '${dc.activeProjectCount}',
                              label: 'Active',
                              iconColor: const Color(0xFF60A5FA),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              icon: Icons.task_alt,
                              count: '${dc.totalTaskCount}',
                              label: 'Tasks',
                              iconColor: const Color(0xFF4ADE80),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              icon: Icons.warning_amber_rounded,
                              count: '${dc.overdueCount}',
                              label: 'Overdue',
                              iconColor: const Color(0xFFFACC15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14),
                // Critical Alerts
                if (criticalAlerts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: const Color(0xFFE6C3C5).withValues(alpha: 0.9),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Critical Alerts',
                                  style: TextStyle(
                                    color: AppColors.alertTitle,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...criticalAlerts.map(
                              (item) => AlertTile(item: item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Task Overview
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Card(
                    color: Colors.white,
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Task Overview",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F3FF),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.insights,
                                        color: AppColors.accent,
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Analytics",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 170,
                            child: totalStatusCount > 0
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: SizedBox(
                                            height: 140,
                                            width: 140,
                                            child: CustomPaint(
                                              painter: DonutChartPainter(
                                                statusData,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: statusData
                                              .map(
                                                (item) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 9,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: item
                                                                      .color,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            item.label,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppColors
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        '${item.count}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Text(
                                      'No tasks yet',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                          ),
                          const Divider(color: AppColors.divider, height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Completion',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                              Text(
                                '$completionPercent%',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SectionHeader(
                  title: 'Active Projects',
                  actionText: 'See all',
                ),
                ...List.generate(dc.projects.length, (i) {
                  final project = dc.projects[i];
                  final totalSub =
                      project.completedTask + project.remainingTask;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ProjectCard(
                      title: project.title,
                      subtitle: project.description,
                      dueText: dc.formatDeadline(project.deadLine),
                      status: '${project.completedTask}/$totalSub tasks',
                      progress: project.progress / 100.0,
                      teamMembers: [dc.getMemberInitials(project.ownerId)],
                      accentColor: dc.projectAccent(i),
                    ),
                  );
                }),
                if (dc.projects.isEmpty && !dc.isLoading.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      'No projects yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                const SectionHeader(
                  title: 'Upcoming Deadlines',
                  actionText: 'See all',
                ),
                if (upcomingDeadlines.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: upcomingDeadlines
                            .map((item) => DeadlineTile(item: item))
                            .toList(),
                      ),
                    ),
                  ),
                if (upcomingDeadlines.isEmpty && !dc.isLoading.value)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      'No upcoming deadlines',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: SectionHeader(title: 'Team', actionText: 'See all'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: SectionHeader(
                    title: 'Recent Activity',
                    trailing: TextButton.icon(
                      onPressed: () => dc.loadDashboard(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.refresh,
                        size: 14,
                        color: Colors.blueGrey.withValues(alpha: 0.85),
                      ),
                      label: Text(
                        'Refresh',
                        style: TextStyle(
                          color: Colors.blueGrey.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 86),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: recentActivity.isNotEmpty
                          ? Column(
                              children: recentActivity
                                  .map((item) => ActivityTile(item: item))
                                  .toList(),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No recent activity',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }
}
