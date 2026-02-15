import 'package:get/get.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  var tasks = <Task>[].obs;
  // Here have to pass owner's id somehow
  // String ownerId = "";
  var isLoading = false.obs;

  @override
  void onInit() {
    // getTaskByOwner(ownerId);
    super.onInit();
  }

  Future<void> addTask(Task task) async {
    isLoading.value = true;
    await _taskService.addTask(task);
    // getTaskByOwner(ownerId);
    isLoading.value = false;
  }

  Future<void> updateTask(String id, Task newTask) async {
    isLoading.value = true;
    await _taskService.updateTask(id, newTask);
    // getTaskByOwner(ownerId);
    isLoading.value = false;
  }

  Future<void> getTaskByOwner(String id) async {
    isLoading.value = true;
    tasks.value = await _taskService.getTaskByOwner(id);
    isLoading.value = false;
  }

  Future<Task> getTaskById(String id) async {
    isLoading.value = true;
    Task task = await _taskService.getTaskById(id);
    isLoading.value = false;
    return task;
  }

  Future<void> removeTask(String id) async {
    await _taskService.deleteTask(id);
    // getTaskByOwner(ownerId);
  }
}
