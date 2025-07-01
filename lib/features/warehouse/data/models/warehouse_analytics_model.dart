class WarehouseAnalyticsModel {
  final int totalInventory;
  final int processingInventory;
  final int readyInventory;
  final double totalWeight;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final Map<String, int> categoryDistribution;
  final Map<String, int> qualityDistribution;
  final double taskCompletionRate;

  WarehouseAnalyticsModel({
    required this.totalInventory,
    required this.processingInventory,
    required this.readyInventory,
    required this.totalWeight,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.categoryDistribution,
    required this.qualityDistribution,
    required this.taskCompletionRate,
  });

  factory WarehouseAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return WarehouseAnalyticsModel(
      totalInventory: json['totalInventory'] ?? 0,
      processingInventory: json['processingInventory'] ?? 0,
      readyInventory: json['readyInventory'] ?? 0,
      totalWeight: (json['totalWeight'] ?? 0).toDouble(),
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
      qualityDistribution: Map<String, int>.from(json['qualityDistribution'] ?? {}),
      taskCompletionRate: (json['taskCompletionRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInventory': totalInventory,
      'processingInventory': processingInventory,
      'readyInventory': readyInventory,
      'totalWeight': totalWeight,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'categoryDistribution': categoryDistribution,
      'qualityDistribution': qualityDistribution,
      'taskCompletionRate': taskCompletionRate,
    };
  }

  String get formattedTotalWeight => '${totalWeight.toStringAsFixed(2)} kg';
  int get usedInventory => totalInventory - processingInventory - readyInventory;
  double get processingRate => totalInventory > 0 ? (processingInventory / totalInventory) * 100 : 0;
  double get readyRate => totalInventory > 0 ? (readyInventory / totalInventory) * 100 : 0;
  int get inProgressTasks => totalTasks - completedTasks - pendingTasks;
} 