import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managementt/admin/add_task.dart';
import 'package:managementt/components/app_colors.dart';
import 'package:managementt/controller/auth_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';

class UserTaskDetailPage extends StatefulWidget {
  final Task task;

  const UserTaskDetailPage({super.key, required this.task});

  @override
  State<UserTaskDetailPage> createState() => _UserTaskDetailPageState();
}

class _UserTaskDetailPageState extends State<UserTaskDetailPage> {
  final TaskController _taskController = Get.find<TaskController>();

  Future<void> _convertTaskToProjectAndAddSubtasks() async {
    final taskId = widget.task.id;
    if (taskId == null || taskId.isEmpty) {
      Get.snackbar(
        'Error',
        'Task id is missing. Please refresh and try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final alreadyProject = (widget.task.type ?? '').toUpperCase() == 'PROJECT';

    if (!alreadyProject) {
      final evolvedTask = Task(
        id: widget.task.id,
        title: widget.task.title,
        description: widget.task.description,
        priority: widget.task.priority,
        type: 'PROJECT',
        status: widget.task.status,
        ownerId: widget.task.ownerId,
        parentTaskId: widget.task.parentTaskId,
        progress: widget.task.progress,
        contributionPercent: 0,
        remark: widget.task.remark,
        deadLine: widget.task.deadLine,
        startDate: widget.task.startDate,
        remainingTask: widget.task.remainingTask,
        completedTask: widget.task.completedTask,
      );

      await _taskController.updateTask(taskId, evolvedTask);
      await _taskController.getAllTask();
    }

    Get.to(() => AddTask(defaultType: 'TASK', parentTaskId: taskId));
  }

  Future<void> _submitForReview() async {
    final taskId = widget.task.id;
    if (taskId == null || taskId.isEmpty) {
      Get.snackbar(
        'Error',
        'Task id is missing. Please refresh and try again.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final ok = await _taskController.submitTaskForReview(
      taskId: taskId,
      actorId: widget.task.ownerId,
      actorRole: AuthController.to.role.value,
    );

    if (ok) {
      setState(() {
        widget.task.status = 'REVIEW';
      });
      Get.snackbar(
        'Submitted',
        'Task submitted for project-owner review.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final task = widget.task;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF3B5BEE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: Get.back,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                height: 1.02,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Task status info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Status: ${task.status ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.stripColor(
                                  priority: task.priority,
                                  status: task.status,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                task.priority.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                            Text(
                              '${task.progress}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: (task.progress / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.stripColor(
                                priority: task.priority,
                                status: task.status,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Task details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(label: 'Description', value: task.description),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Priority',
                          value: task.priority.toUpperCase(),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Status', value: task.status ?? 'N/A'),
                        if (task.deadLine != null) ...[
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Deadline',
                            value:
                                "${task.deadLine!.day}/${task.deadLine!.month}/${task.deadLine!.year}",
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons section
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _convertTaskToProjectAndAddSubtasks();
                          },
                          icon: const Icon(Icons.add_task_rounded, size: 18),
                          label: const Text('Add Subtasks'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if ((task.type ?? '').toUpperCase() == 'TASK' &&
                          !AppColors.isCompletedStatus(task.status) &&
                          (task.status ?? '').toUpperCase() != 'REVIEW') ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _submitForReview();
                            },
                            icon: const Icon(Icons.rule_rounded, size: 18),
                            label: const Text('Submit Review'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Subtasks section (placeholder)
                  Text(
                    'Subtasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Center(
                      child: Text(
                        'Subtasks will appear here once added',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }
}
