import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/admin/project_detail_page.dart';
import 'package:managementt/components/app_confirm_dialog.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/components/pagination_loading_indicator.dart';
import 'package:managementt/components/date_time_helper.dart';
import 'package:managementt/components/app_render_entrance.dart';
import 'package:managementt/components/project_card.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/controller/project_pagination_controller.dart';
import 'package:managementt/model/filter_enums.dart';

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
  late ProjectPaginationController paginationController;
  final TaskController taskController = Get.find<TaskController>();
  final DashboardController dc = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    paginationController = Get.isRegistered<ProjectPaginationController>()
        ? Get.find<ProjectPaginationController>()
        : Get.put(ProjectPaginationController());
    paginationController.updateStatusFilter(ProjectStatusFilter.all);
    paginationController.updatePriorityFilter(PriorityFilter.all);
    paginationController.updateSearchQuery('');
    // Force fresh load on entry to avoid stale/empty cached pagination state.
    paginationController.resetPagination();
    paginationController.loadNextPage();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ProjectPaginationController>()) {
      Get.delete<ProjectPaginationController>();
    }
    super.dispose();
  }

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
        child: RefreshIndicator(
          onRefresh: () async {
            paginationController.resetPagination();
            await paginationController.loadNextPage();
          },
          child: CustomScrollView(
            controller: paginationController.scrollController,
            slivers: [
              /// HEADER
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 230,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text(
                            "Overview · $formattedDate",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),

                          /// STAT CHIPS
                          Obx(() {
                            final projects = paginationController.items;
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

                          /// SEARCH
                          SizedBox(
                            height: 44,
                            child: TextField(
                              onChanged: (val) =>
                                  paginationController.updateSearchQuery(val),
                              decoration: InputDecoration(
                                hintText: "Search by project name or owner…",
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
                  ),
                ),
              ),

              /// PROJECT LIST
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                sliver: Obx(() {
                  final state = paginationController.paginationState.value;
                  final filteredProjects = paginationController
                      .getFilteredItems((ownerId) => dc.getMemberName(ownerId));

                  if (filteredProjects.isEmpty &&
                      !state.isLoading &&
                      state.error == null) {
                    return SliverToBoxAdapter(
                      child: Padding(
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
                      ),
                    );
                  }

                  if (filteredProjects.isEmpty && state.isLoading) {
                    return SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  return SliverList.builder(
                    itemCount: filteredProjects.length + 2,
                    itemBuilder: (context, index) {
                      // Show loading indicator at bottom
                      if (index == filteredProjects.length) {
                        return PaginationLoadingIndicator(
                          isLoading: state.isLoading,
                        );
                      }

                      // Show end-of-list indicator
                      if (index == filteredProjects.length + 1) {
                        return EndOfListIndicator(
                          show: !state.hasMore && !state.isLoading,
                        );
                      }

                      final task = filteredProjects[index];
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
