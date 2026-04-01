import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/service/task_service.dart';

import 'package:managementt/components/task_velocity_chart.dart';
import 'package:managementt/components/project_health_section.dart';
import 'package:managementt/components/team_task_distribution.dart';
import 'package:managementt/components/top_contributors.dart';
import 'package:managementt/components/priority_breakdown.dart';
import 'package:managementt/components/deadlines_at_risk.dart';

const _months = [
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

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  String get _formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DashboardController>();
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: Obx(() {
          final totalItems = dc.allItems.length;
          final doneItems = dc.allItems.where((t) => t.status == 'DONE').length;

          return RefreshIndicator(
            onRefresh: () async {
              await TaskService().checkOverdue();
              await dc.loadDashboard();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.alertTitle],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Analytics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.tune_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {},
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Performance overview · $_formattedDate',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // ─── Stat cards (reactive) ───
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle_outline_rounded,
                                color: const Color(0xFF2ECC71),
                                label: 'Completion',
                                value: '${dc.completionPercent}%',
                                subtitle: '$doneItems of $totalItems tasks',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.schedule_rounded,
                                color: const Color(0xFF3498DB),
                                label: 'On‑Time',
                                value: '${dc.onTimePercent}%',
                                subtitle: '${dc.overdueTaskCount} overdue',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.speed_rounded,
                                color: const Color(0xFFF39C12),
                                label: 'Tasks',
                                value: '$totalItems',
                                subtitle: 'total items',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.groups_rounded,
                                color: const Color(0xFF9B59B6),
                                label: 'Coverage',
                                value: '${dc.coveragePercent}%',
                                subtitle: '${dc.assignedCount} assigned',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ─── Task Velocity Trend Chart ───
                  const TaskVelocityChart(),
                  const SizedBox(height: 8),
                  // ─── Project Health (reactive) ───
                  ProjectHealthSection(items: dc.projectHealthItems),
                  const SizedBox(height: 8),
                  // ─── Team Task Distribution (reactive) ───
                  TeamTaskDistribution(teamData: dc.teamDistribution),
                  const SizedBox(height: 8),
                  // ─── Top Contributors (reactive) ───
                  TopContributors(contributors: dc.topContributors),
                  const SizedBox(height: 8),
                  // ─── Priority Breakdown (reactive) ───
                  PriorityBreakdown(
                    highCount: dc.highPriorityCount,
                    mediumCount: dc.mediumPriorityCount,
                    lowCount: dc.lowPriorityCount,
                  ),
                  const SizedBox(height: 8),
                  // ─── Deadlines at Risk (reactive) ───
                  DeadlinesAtRisk(
                    tasks: dc.atRiskTasks,
                    getMemberName: dc.getMemberName,
                    getMemberInitials: dc.getMemberInitials,
                  ),
                  // bottom padding for nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
