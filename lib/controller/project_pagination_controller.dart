import 'package:get/get.dart';
import 'package:managementt/controller/pagination_controller.dart';
import 'package:managementt/model/filter_enums.dart';
import 'package:managementt/model/pagination_models.dart';
import 'package:managementt/model/task.dart';
import 'package:managementt/service/task_pagination_service.dart';

/// Pagination controller for projects dashboard.
/// Extends PaginationController to handle infinite scrolling for project lists.
class ProjectPaginationController extends PaginationController<Task> {
  final TaskPaginationService _taskService = TaskPaginationService();
  var searchQuery = ''.obs;
  var statusFilter = ProjectStatusFilter.all.obs;
  var priorityFilter = PriorityFilter.all.obs;

  @override
  Future<PaginatedResponse<Task>> fetchPage(int page, int size) {
    return _taskService.getProjectsPaginated(page, size);
  }

  /// Update search query and filter items locally.
  /// This is client-side filtering on loaded items.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Update status filter
  void updateStatusFilter(ProjectStatusFilter filter) {
    statusFilter.value = filter;
  }

  /// Update priority filter
  void updatePriorityFilter(PriorityFilter filter) {
    priorityFilter.value = filter;
  }

  /// Get filtered list based on search query, status filter, and priority filter.
  /// Filters from already loaded items, not from API.
  /// Searches by both project title and owner name.
  List<Task> getFilteredItems(String Function(String ownerId)? getOwnerName) {
    var filtered = items.toList();

    // Apply status filter
    if (statusFilter.value != ProjectStatusFilter.all) {
      filtered = filtered.where((project) {
        final status = (project.status ?? '').toUpperCase();
        switch (statusFilter.value) {
          case ProjectStatusFilter.active:
            return status == 'IN_PROGRESS';
          case ProjectStatusFilter.completed:
            return status == 'DONE' || status == 'COMPLETED';
          case ProjectStatusFilter.overdue:
            return status == 'OVERDUE';
          case ProjectStatusFilter.notStarted:
            return status == 'NOT_STARTED';
          default:
            return true;
        }
      }).toList();
    }

    // Apply priority filter
    if (priorityFilter.value != PriorityFilter.all) {
      filtered = filtered.where((project) {
        final priority = project.priority.toLowerCase();
        switch (priorityFilter.value) {
          case PriorityFilter.high:
            return priority == 'high';
          case PriorityFilter.medium:
            return priority == 'medium';
          case PriorityFilter.low:
            return priority == 'low';
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((project) {
        final titleMatch = project.title.toLowerCase().contains(query);
        if (getOwnerName != null) {
          final ownerName = getOwnerName(project.ownerId).toLowerCase();
          final ownerMatch = ownerName.contains(query);
          return titleMatch || ownerMatch;
        }
        return titleMatch;
      }).toList();
    }

    return filtered;
  }
}
