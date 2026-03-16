// Pagination Models and State Management

/// Generic response wrapper for paginated API responses.
/// Matches the Spring Boot PagedResponse structure from the backend.
class PaginatedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;

  PaginatedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  /// Check if there are more pages to load
  bool get hasMore => page < totalPages - 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      content: (json['content'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
    );
  }
}

/// State object for managing pagination state across dashboards.
/// Tracks loading state, current page, error messages, and more.
class PaginationState {
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  PaginationState({
    // Start at -1 so the first load requests page 0.
    this.currentPage = -1,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  /// Creates a copy of this state with specified fields replaced
  PaginationState copyWith({
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'PaginationState(page: $currentPage, isLoading: $isLoading, hasMore: $hasMore, error: $error)';
}
