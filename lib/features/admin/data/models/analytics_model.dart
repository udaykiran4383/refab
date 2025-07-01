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
    };
  }

  double get userActivationRate => totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;
  double get pickupCompletionRate => totalPickupRequests > 0 ? (completedPickups / totalPickupRequests) * 100 : 0;
  String get formattedRevenue => '₹${totalRevenue.toStringAsFixed(2)}';
  bool get isPickupGrowthPositive => pickupGrowthRate > 0;
} 