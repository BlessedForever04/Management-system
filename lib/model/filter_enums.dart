/// Shared filter enums used across the application
/// This file prevents duplication and provides a single source of truth

/// Status filter options for task dashboards
enum TaskStatusFilter { all, todo, inProgress, underReview, done, overdue }

/// Status filter options for project dashboard
enum ProjectStatusFilter { all, active, completed, overdue, notStarted }

/// Priority filter options for all dashboards
enum PriorityFilter { all, high, medium, low }
