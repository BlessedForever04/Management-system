import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:managementt/components/app_snackbar.dart';
import 'package:managementt/controller/dashboard_controller.dart';
import 'package:managementt/controller/task_controller.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class UserTaskController extends GetxController {
  final TaskService _taskService = TaskService();
  var userTasks = <Task>[].obs;
  var userProjects = <Task>[].obs;

  Future<void> removeProject(String id, {required String userId}) async {
    final index = userProjects.indexWhere((project) => project.id == id);
    if (index < 0) {
      return;
    }

    final removed = userProjects[index];
    userProjects.removeAt(index);
    userProjects.refresh();

    try {
      await _taskService.deleteTask(id, false);
      await fetchUserProjects(userId);
      await fetchUserTasks(userId);

      if (Get.isRegistered<TaskController>()) {
        await Get.find<TaskController>().getAllTask();
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadDashboard();
      }
    } catch (e) {
      final safeIndex = index.clamp(0, userProjects.length);
      userProjects.insert(safeIndex, removed);
      userProjects.refresh();
      AppSnackbar.show('Error', 'Failed to remove task: $e');
    }
  }

  Future<void> fetchUserProjects(String userId) async {
    try {
      final allProjects = await _taskService.getAllProjects();
      final projects = allProjects
          .where(
            (t) =>
                (t.ownerId == userId) &&
                ((t.type ?? '').toUpperCase() == 'PROJECT' ||
                    t.isProject == true),
          )
          .toList();

      userProjects.value = projects;
      userProjects.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch user tasks — $e');
      userTasks.value = [];
    }
  }

  Future<void> fetchUserTasks(String userId) async {
    try {
      final results = await _taskService.getTaskByOwner(userId);
      var tasks = results
          .where((t) => t.type == 'TASK' && t.isProject == false)
          .toList();

      // If the member endpoint returned nothing (or no tasks), try a fallback:
      if (tasks.isEmpty) {
        // ignore: avoid_print
        print(
          'UserTaskController: member endpoint returned no tasks for $userId — falling back to all tasks',
        );
        final all = await _taskService.getAllTask();
        tasks = all
            .where((t) => (t.ownerId == userId) && (t.type == 'TASK'))
            .toList();
      }
      userTasks.value = tasks;
      userTasks.refresh();
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch user tasks — $e');
      userTasks.value = [];
    }
  }
}
