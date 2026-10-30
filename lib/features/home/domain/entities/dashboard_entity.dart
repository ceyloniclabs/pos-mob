class DashboardEntity {
  final int activeRentals;
  final int todaysSales;
  final int customers;
  final int overdueRentals;
  final List<ActivityEntity> recentActivity;

  DashboardEntity({
    required this.activeRentals,
    required this.todaysSales,
    required this.customers,
    required this.overdueRentals,
    required this.recentActivity,
  });
}

class ActivityEntity {
  final String title;
  final String time;
  final String iconType;

  ActivityEntity({
    required this.title,
    required this.time,
    required this.iconType,
  });
}
