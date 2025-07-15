class AnalyticsModel {
  final int totalUsers;
  final int activeUsers;
  final int totalPickupRequests;
  final int completedPickups;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final Map<String, int> roleDistribution;
  final int thisMonthPickups;
  final int lastMonthPickups;
  final double pickupGrowthRate;
  final int totalAssignments;
  final int pendingPickupRequests;
  final int completedPickupRequests;
  final double averageProcessingTime;
  final double systemUptime;

  AnalyticsModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPickupRequests,
    required this.completedPickups,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.roleDistribution,
    required this.thisMonthPickups,
    required this.lastMonthPickups,
    required this.pickupGrowthRate,
    required this.totalAssignments,
    required this.pendingPickupRequests,
    required this.completedPickupRequests,
    required this.averageProcessingTime,
    required this.systemUptime,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalPickupRequests: json['totalPickupRequests'] ?? 0,
      completedPickups: json['completedPickups'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      roleDistribution: Map<String, int>.from(json['roleDistribution'] ?? {}),
      thisMonthPickups: json['thisMonthPickups'] ?? 0,
      lastMonthPickups: json['lastMonthPickups'] ?? 0,
      pickupGrowthRate: (json['pickupGrowthRate'] ?? 0).toDouble(),
      totalAssignments: json['totalAssignments'] ?? 0,
      pendingPickupRequests: json['pendingPickupRequests'] ?? 0,
      completedPickupRequests: json['completedPickupRequests'] ?? 0,
      averageProcessingTime: (json['averageProcessingTime'] ?? 0).toDouble(),
      systemUptime: (json['systemUptime'] ?? 0).toDouble(),
    );
  }

  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      totalUsers: 0,
      activeUsers: 0,
      totalPickupRequests: 0,
      completedPickups: 0,
      totalProducts: 0,
      totalOrders: 0,
      totalRevenue: 0.0,
      roleDistribution: {},
      thisMonthPickups: 0,
      lastMonthPickups: 0,
      pickupGrowthRate: 0.0,
      totalAssignments: 0,
      pendingPickupRequests: 0,
      completedPickupRequests: 0,
      averageProcessingTime: 0.0,
      systemUptime: 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalPickupRequests': totalPickupRequests,
      'completedPickups': completedPickups,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'roleDistribution': roleDistribution,
      'thisMonthPickups': thisMonthPickups,
      'lastMonthPickups': lastMonthPickups,
      'pickupGrowthRate': pickupGrowthRate,
      'totalAssignments': totalAssignments,
      'pendingPickupRequests': pendingPickupRequests,
      'completedPickupRequests': completedPickupRequests,
      'averageProcessingTime': averageProcessingTime,
      'systemUptime': systemUptime,
    };
  }

  double get userActivationRate => totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;
  double get pickupCompletionRate => totalPickupRequests > 0 ? (completedPickups / totalPickupRequests) * 100 : 0;
  String get formattedRevenue => '₹${totalRevenue.toStringAsFixed(2)}';
  bool get isPickupGrowthPositive => pickupGrowthRate > 0;
} 