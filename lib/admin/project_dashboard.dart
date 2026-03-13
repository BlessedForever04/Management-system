import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/task_controller.dart';

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

class ProjectDashboard extends StatelessWidget {
  ProjectDashboard({super.key});

  final TaskController taskController = Get.find<TaskController>();
  final DashboardController dc = Get.find<DashboardController>();

  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE ROW
                    Row(
                      children: [
                        const Text(
                          "Projects",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Get.to(() => AddTask()),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Overview · $formattedDate",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// STAT CHIPS
                    Obx(() {
                      final projects = taskController.tasks
                          .where(
                            (t) => (t.type ?? '').toUpperCase() == 'PROJECT',
                          )
                          .toList();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatChip(
                            label: 'Total',
                            count: projects.length,
                            color: const Color(0xFF60A5FA),
                          ),
                          _StatChip(
                            label: 'Active',
                            count: projects
                                .where((t) => t.status == 'IN_PROGRESS')
                                .length,
                            color: const Color(0xFF4ADE80),
                          ),
                          _StatChip(
                            label: 'Completed',
                            count: projects
                                .where((t) => t.status == 'DONE')
                                .length,
                            color: const Color(0xFFA78BFA),
                          ),
                          _StatChip(
                            label: 'Overdue',
                            count: projects
                                .where((t) => t.status == 'OVERDUE')
                                .length,
                            color: const Color(0xFFF87171),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 14),

                    /// SEARCH
                    SizedBox(
                      height: 44,
                      child: TextField(
                        onChanged: (val) =>
                            taskController.searchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: "Search projects…",
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.12),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// PROJECT LIST using ProjectCard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(() {
                  if (taskController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final projects = taskController.tasks
                      .where((t) => (t.type ?? '').toUpperCase() == 'PROJECT')
                      .toList();

                  final query = taskController.searchQuery.value
                      .trim()
                      .toLowerCase();
                  final filtered = query.isEmpty
                      ? projects
                      : projects
                            .where((t) => t.title.toLowerCase().contains(query))
                            .toList();

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No projects found",
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      final totalSub = task.completedTask + task.remainingTask;
                      final ownerInitials = dc.getMemberInitials(task.ownerId);

                      return Dismissible(
                        key: ValueKey(task.id ?? index),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return AppConfirmDialog.show(
                            title: 'Delete Project',
                            message:
                                'Remove "${task.title}" and all its tasks?',
                            cancelText: 'Cancel',
                            confirmText: 'Delete',
                            tone: AppDialogTone.danger,
                            icon: Icons.delete_outline_rounded,
                          );
                        },
                        onDismissed: (_) {
                          if (task.id != null) {
                            taskController.removeTask(task.id!);
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        child: ProjectCard(
                          title: task.title,
                          subtitle: task.description,
                          dueText: dc.formatDeadline(task.deadLine),
                          status: totalSub > 0
                              ? '${task.completedTask}/$totalSub tasks'
                              : null,
                          progress: task.progress / 100.0,
                          timeProgress: DateTimeHelper.remainingTimeRatio(
                            task.startDate,
                            task.deadLine,
                          ),
                          teamMembers: [ownerInitials],
                          accentColor: dc.projectAccent(task),
                          onTap: () {
                            Get.to(
                              () => ProjectDetailPage(
                                project: task,
                                projectMemberNames: [
                                  dc.getMemberName(task.ownerId),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
