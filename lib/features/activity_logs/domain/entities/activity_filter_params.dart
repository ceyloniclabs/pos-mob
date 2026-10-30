class ActivityFilterParams {
  final int page;
  final int perPage;
  final int? userId;
  final String? role;
  final String? action;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  const ActivityFilterParams({
    this.page = 1,
    this.perPage = 10,
    this.userId,
    this.role,
    this.action,
    this.startDate,
    this.endDate,
    this.search,
  });

  ActivityFilterParams copyWith({
    int? page,
    int? perPage,
    int? userId,
    String? role,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  }) {
    return ActivityFilterParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      action: action ?? this.action,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      search: search ?? this.search,
    );
  }

  bool get hasActiveFilters =>
      userId != null ||
      (role != null && role != 'all' && role!.isNotEmpty) ||
      (action != null && action != 'all' && action!.isNotEmpty) ||
      startDate != null ||
      endDate != null ||
      (search != null && search!.trim().isNotEmpty);

  int get activeFilterCount {
    int count = 0;
    if (userId != null) count++;
    if (role != null && role != 'all' && role!.isNotEmpty) count++;
    if (action != null && action != 'all' && action!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'page': page,
      'per_page': perPage,
    };

    if (userId != null) {
      params['user_id'] = userId;
    }
    if (role != null && role != 'all' && role!.isNotEmpty) {
      params['role'] = role;
    }
    if (action != null && action != 'all' && action!.isNotEmpty) {
      params['action'] = action;
    }
    if (startDate != null) {
      params['start_date'] =
          "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}";
    }
    if (endDate != null) {
      params['end_date'] =
          "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}";
    }
    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }

    return params;
  }
}
