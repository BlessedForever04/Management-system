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
import 'package:managementt/model/filter_enums.dart';
import 'package:managementt/service/task_service.dart';

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

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({super.key});

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  final TaskController taskController = Get.find<TaskController>();
  final DashboardController dc = Get.find<DashboardController>();

  var selectedStatus = ProjectStatusFilter.all.obs;

  static const List<_StatusFilterChipData> _statusFilterOptions = [
    _StatusFilterChipData(
      filter: ProjectStatusFilter.all,
      label: 'All',
      color: Color(0xFFCBBCE6),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.active,
      label: 'In Progress',
      color: Color(0xFF2563EB),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.completed,
      label: 'Completed',
      color: Color(0xFF14B8A6),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.notStarted,
      label: 'Not Started',
      color: Color(0xFFF9BC16),
    ),
    _StatusFilterChipData(
      filter: ProjectStatusFilter.overdue,
      label: 'Overdue',
      color: Color(0xFFF97316),
    ),
  ];

  String get formattedDate {
    final now = DateTime.now();
    return '${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // ONLY showing FIXED parts (rest remains same)

  // 🔥 FIX 1: make filtering reactive properly
  List getFilteredTasks() {
    final allTasks = taskController.filteredTasks; // 🔥 USE CONTROLLER FILTER
    final statusFilter = selectedStatus.value;

    return allTasks.where((t) {
      final status = (t.status ?? '').toUpperCase();

      switch (statusFilter) {
        case ProjectStatusFilter.active:
          return status == 'IN_PROGRESS';
        case ProjectStatusFilter.completed:
          return status == 'DONE' || status == 'COMPLETED';
        case ProjectStatusFilter.overdue:
          return status == 'OVERDUE';
        case ProjectStatusFilter.notStarted:
          return status == 'NOT_STARTED' || status == 'TODO';
        case ProjectStatusFilter.all:
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildStatusFilterCarousel() {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final current = selectedStatus.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _statusFilterOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final option = _statusFilterOptions[index];

            return _StatusFilterChip(
              data: option,
              isActive: current == option.filter,
              count: taskController
                  .projects
                  .length, // avoid calling non-reactive fn
              onTap: () => selectedStatus.value = option.filter,
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: AppRenderEntrance(
        child: RefreshIndicator(
          onRefresh: () async {
            await TaskService().checkOverdue();
            await taskController.getAllTask();
          },
          child: CustomScrollView(
            slivers: [
              /// HEADER
              SliverAppBar(
                pinned: true,
                expandedHeight: 330,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4338CA)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE
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

                          Text(
                            "Overview · $formattedDate",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),

                          /// STATS
                          Obx(() {
                            final tasks = taskController.projects;
                            return Wrap(
                              children: [
                                _StatChip(
                                  label: 'Total',
                                  count: tasks.length,
                                  color: Colors.blue,
                                ),
                                _StatChip(
                                  label: 'Active',
                                  count: tasks
                                      .where((t) => t.status == 'IN_PROGRESS')
                                      .length,
                                  color: Colors.green,
                                ),
                                _StatChip(
                                  label: 'Completed',
                                  count: tasks
                                      .where((t) => t.status == 'DONE')
                                      .length,
                                  color: Colors.purple,
                                ),
                                _StatChip(
                                  label: 'Overdue',
                                  count: tasks
                                      .where((t) => t.status == 'OVERDUE')
                                      .length,
                                  color: Colors.red,
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 10),

                          _buildStatusFilterCarousel(),

                          const SizedBox(height: 10),

                          /// SEARCH
                          SizedBox(
                            height: 44,
                            child: TextField(
                              onChanged: (val) =>
                                  taskController.searchQuery.value = val,
                              decoration: InputDecoration(
                                hintText: "Search...",
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
                  ),
                ),
              ),

              /// LIST
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: Obx(() {
                  final _ = selectedStatus.value; // 👈 trigger rebuild
                  final __ = taskController.searchQuery.value;
                  final tasks = getFilteredTasks();

                  if (tasks.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text("No projects found")),
                    );
                  }

                  return SliverList.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final total = task.completedTask + task.remainingTask;

                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return AppConfirmDialog.show(
                            title: 'Delete Project',
                            message: 'Remove "${task.title}"?',
                            confirmText: 'Delete',
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
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ProjectCard(
                          title: task.title,
                          subtitle: task.description,
                          dueText: dc.formatDeadline(task.deadLine),
                          status: total > 0
                              ? '${task.completedTask}/$total'
                              : null,
                          progress: task.progress / 100,
                          timeProgress: DateTimeHelper.remainingTimeRatio(
                            task.startDate,
                            task.deadLine,
                          ),
                          teamMembers: [dc.getMemberInitials(task.ownerId)],
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
      margin: EdgeInsets.all(5),
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

class _StatusFilterChipData {
  final ProjectStatusFilter filter;
  final String label;
  final Color color;

  const _StatusFilterChipData({
    required this.filter,
    required this.label,
    required this.color,
  });
}

class _StatusFilterChip extends StatelessWidget {
  final _StatusFilterChipData data;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.data,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? data.color.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? data.color : Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Text(
          data.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
