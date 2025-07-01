class LogisticsAnalyticsModel {
  final int totalRoutes;
  final int completedRoutes;
  final int totalPickups;
  final int completedPickups;
  final double totalDistance;
  final int thisWeekPickups;
  final int lastWeekPickups;
  final double routeCompletionRate;
  final double pickupCompletionRate;
  final double weeklyGrowthRate;

  LogisticsAnalyticsModel({
    required this.totalRoutes,
    required this.completedRoutes,
    required this.totalPickups,
    required this.completedPickups,
    required this.totalDistance,
    required this.thisWeekPickups,
    required this.lastWeekPickups,
    required this.routeCompletionRate,
    required this.pickupCompletionRate,
    required this.weeklyGrowthRate,
  });

  factory LogisticsAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return LogisticsAnalyticsModel(
      totalRoutes: json['totalRoutes'] ?? 0,
      completedRoutes: json['completedRoutes'] ?? 0,
      totalPickups: json['totalPickups'] ?? 0,
      completedPickups: json['completedPickups'] ?? 0,
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      thisWeekPickups: json['thisWeekPickups'] ?? 0,
      lastWeekPickups: json['lastWeekPickups'] ?? 0,
      routeCompletionRate: (json['routeCompletionRate'] ?? 0).toDouble(),
      pickupCompletionRate: (json['pickupCompletionRate'] ?? 0).toDouble(),
      weeklyGrowthRate: (json['weeklyGrowthRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRoutes': totalRoutes,
      'completedRoutes': completedRoutes,
      'totalPickups': totalPickups,
      'completedPickups': completedPickups,
      'totalDistance': totalDistance,
      'thisWeekPickups': thisWeekPickups,
      'lastWeekPickups': lastWeekPickups,
      'routeCompletionRate': routeCompletionRate,
      'pickupCompletionRate': pickupCompletionRate,
      'weeklyGrowthRate': weeklyGrowthRate,
    };
  }

  String get formattedTotalDistance => '${totalDistance.toStringAsFixed(1)} km';
  int get pendingRoutes => totalRoutes - completedRoutes;
  int get pendingPickups => totalPickups - completedPickups;
  bool get isWeeklyGrowthPositive => weeklyGrowthRate > 0;
} 