import 'package:get/get.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_service.dart';

class CollaborationController extends GetxController {
  var collaborators = <Task>[].obs;
  var projects = <Task>[].obs;
  var tasksOfCollaboration = <String, List<Task>>{}.obs;

  var isLoading = false.obs;

  final RxBool isLoadingCollaborators = false.obs;
  final RxBool isLoadingProjects = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString lastError = ''.obs;

      print(
        'CollaborationController: Added collaborator $_projectId to task $taskId',
      );
    } catch (e) {
      print('Error adding collaborator: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllProjects();
  }

  Future<void> fetchAllProjects() async {
    isLoadingProjects.value = true;
    try {
      isLoading.value = true;
      final results = await TaskService().getAllProjects();
      projects.assignAll(results);
    } catch (e) {
      // ignore: avoid_print
      print('UserTaskController: Failed to fetch all projects — $e');
      projects.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCollaboratedProjects(String projectId) async {
    final normalized = projectId.trim();
    if (normalized.isEmpty) return;

    _activeProjectId = normalized;
    isLoadingCollaborators.value = true;

    try {
      final results = await TaskService().getCollaboratedProjects(normalized);
      collaborators.assignAll(results);
    } catch (e) {
      collaborators.clear();
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
    } finally {
      isLoadingCollaborators.value = false;
    }
  }

  List<Task> availableProjectsFor(
    String currentProjectId, {
    String searchQuery = '',
  }) {
    final current = currentProjectId.trim().toLowerCase();
    final query = searchQuery.trim().toLowerCase();

    final collaboratorIds = collaborators
        .map((task) => (task.id ?? '').trim().toLowerCase())
        .where((id) => id.isNotEmpty)
        .toSet();

    return projects.where((project) {
      final id = (project.id ?? '').trim();
      if (id.isEmpty) return false;

      final normalizedId = id.toLowerCase();
      if (normalizedId == current) return false;
      if (collaboratorIds.contains(normalizedId)) return false;

      if (query.isEmpty) return true;
      return project.title.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query) ||
          project.ownerId.toLowerCase().contains(query);
    }).toList();
  }

  Future<bool> addCollaborator({
    required String taskId,
    required String collaboratorProjectId,
  }) async {
    final sourceId = taskId.trim();
    final targetId = collaboratorProjectId.trim();

    if (sourceId.isEmpty || targetId.isEmpty) {
      lastError.value = 'Invalid project selection.';
      return false;
    }

    if (sourceId.toLowerCase() == targetId.toLowerCase()) {
      lastError.value =
          'The current project cannot be added as its own collaborator.';
      return false;
    }

    isSubmitting.value = true;
    lastError.value = '';

    try {
      final results = await TaskService().getCollaboratedProjects(projectId);
      collaborators.value = results;
      print(
        'CollaborationController: Fetched ${collaborators.length} collaborators for project $projectId',
      );
      collaborators.refresh();
    } catch (e) {
      lastError.value = e.toString().replaceFirst('Exception: ', '').trim();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> getAllTasksByCollaboration(String projectId) async {
    try {
      final results = await TaskService().getAllTasksByCollaboration(projectId);

      tasksOfCollaboration.value = results;

      // Calculate total tasks (not just project count)
      int totalTasks = results.values.fold(0, (sum, list) => sum + list.length);

      print(
        'CollaborationController: Fetched $totalTasks tasks across ${results.length} projects for collaboration $projectId',
      );
    } catch (e) {
      print('CollaborationController: Failed to fetch tasks — $e');
      tasksOfCollaboration.value = {};
    }
  }

  void addDependency(String taskId, String dependencyId) async {
    try {
      await TaskService().addDependency(taskId, dependencyId);
      print(
        'CollaborationController: Added dependency $dependencyId to task $taskId',
      );
    } catch (e) {
      print('Error adding dependency: $e');
    }
  }
}
