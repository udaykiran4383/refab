class TailorAnalyticsModel {
  final String tailorId;
  final DateTime date;
  final int totalPickupRequests;
  final int completedPickupRequests;
  final int pendingPickupRequests;
  final int cancelledPickupRequests;
  final double totalWeightCollected;
  final double totalEarnings;
  final double averageRating;
  final int totalReviews;
  final int totalCustomers;
  final int repeatCustomers;
  final double customerSatisfactionScore;
  final Map<String, int> fabricTypeDistribution;
  final Map<String, double> monthlyEarnings;
  final Map<String, int> dailyPickupRequests;
  final double averagePickupValue;
  final double averageProcessingTime;
  final int totalWorkingHours;
  final double efficiencyScore;
  final List<String> topPerformingMonths;
  final List<String> areasForImprovement;
  final Map<String, dynamic>? metadata;

  TailorAnalyticsModel({
    required this.tailorId,
    required this.date,
    required this.totalPickupRequests,
    required this.completedPickupRequests,
    required this.pendingPickupRequests,
    required this.cancelledPickupRequests,
    required this.totalWeightCollected,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalReviews,
    required this.totalCustomers,
    required this.repeatCustomers,
    required this.customerSatisfactionScore,
    required this.fabricTypeDistribution,
    required this.monthlyEarnings,
    required this.dailyPickupRequests,
    required this.averagePickupValue,
    required this.averageProcessingTime,
    required this.totalWorkingHours,
    required this.efficiencyScore,
    required this.topPerformingMonths,
    required this.areasForImprovement,
    this.metadata,
  });

  factory TailorAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return TailorAnalyticsModel(
      tailorId: json['tailor_id'],
      date: DateTime.parse(json['date']),
      totalPickupRequests: json['total_pickup_requests'] ?? 0,
      completedPickupRequests: json['completed_pickup_requests'] ?? 0,
      pendingPickupRequests: json['pending_pickup_requests'] ?? 0,
      cancelledPickupRequests: json['cancelled_pickup_requests'] ?? 0,
      totalWeightCollected: json['total_weight_collected']?.toDouble() ?? 0.0,
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      totalCustomers: json['total_customers'] ?? 0,
      repeatCustomers: json['repeat_customers'] ?? 0,
      customerSatisfactionScore: json['customer_satisfaction_score']?.toDouble() ?? 0.0,
      fabricTypeDistribution: Map<String, int>.from(json['fabric_type_distribution'] ?? {}),
      monthlyEarnings: Map<String, double>.from(
        (json['monthly_earnings'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      dailyPickupRequests: Map<String, int>.from(json['daily_pickup_requests'] ?? {}),
      averagePickupValue: json['average_pickup_value']?.toDouble() ?? 0.0,
      averageProcessingTime: json['average_processing_time']?.toDouble() ?? 0.0,
      totalWorkingHours: json['total_working_hours'] ?? 0,
      efficiencyScore: json['efficiency_score']?.toDouble() ?? 0.0,
      topPerformingMonths: List<String>.from(json['top_performing_months'] ?? []),
      areasForImprovement: List<String>.from(json['areas_for_improvement'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tailor_id': tailorId,
      'date': date.toIso8601String(),
      'total_pickup_requests': totalPickupRequests,
      'completed_pickup_requests': completedPickupRequests,
      'pending_pickup_requests': pendingPickupRequests,
      'cancelled_pickup_requests': cancelledPickupRequests,
      'total_weight_collected': totalWeightCollected,
      'total_earnings': totalEarnings,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'total_customers': totalCustomers,
      'repeat_customers': repeatCustomers,
      'customer_satisfaction_score': customerSatisfactionScore,
      'fabric_type_distribution': fabricTypeDistribution,
      'monthly_earnings': monthlyEarnings,
      'daily_pickup_requests': dailyPickupRequests,
      'average_pickup_value': averagePickupValue,
      'average_processing_time': averageProcessingTime,
      'total_working_hours': totalWorkingHours,
      'efficiency_score': efficiencyScore,
      'top_performing_months': topPerformingMonths,
      'areas_for_improvement': areasForImprovement,
      'metadata': metadata,
    };
  }

  TailorAnalyticsModel copyWith({
    String? tailorId,
    DateTime? date,
    int? totalPickupRequests,
    int? completedPickupRequests,
    int? pendingPickupRequests,
    int? cancelledPickupRequests,
    double? totalWeightCollected,
    double? totalEarnings,
    double? averageRating,
    int? totalReviews,
    int? totalCustomers,
    int? repeatCustomers,
    double? customerSatisfactionScore,
    Map<String, int>? fabricTypeDistribution,
    Map<String, double>? monthlyEarnings,
    Map<String, int>? dailyPickupRequests,
    double? averagePickupValue,
    double? averageProcessingTime,
    int? totalWorkingHours,
    double? efficiencyScore,
    List<String>? topPerformingMonths,
    List<String>? areasForImprovement,
    Map<String, dynamic>? metadata,
  }) {
    return TailorAnalyticsModel(
      tailorId: tailorId ?? this.tailorId,
      date: date ?? this.date,
      totalPickupRequests: totalPickupRequests ?? this.totalPickupRequests,
      completedPickupRequests: completedPickupRequests ?? this.completedPickupRequests,
      pendingPickupRequests: pendingPickupRequests ?? this.pendingPickupRequests,
      cancelledPickupRequests: cancelledPickupRequests ?? this.cancelledPickupRequests,
      totalWeightCollected: totalWeightCollected ?? this.totalWeightCollected,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      repeatCustomers: repeatCustomers ?? this.repeatCustomers,
      customerSatisfactionScore: customerSatisfactionScore ?? this.customerSatisfactionScore,
      fabricTypeDistribution: fabricTypeDistribution ?? this.fabricTypeDistribution,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      dailyPickupRequests: dailyPickupRequests ?? this.dailyPickupRequests,
      averagePickupValue: averagePickupValue ?? this.averagePickupValue,
      averageProcessingTime: averageProcessingTime ?? this.averageProcessingTime,
      totalWorkingHours: totalWorkingHours ?? this.totalWorkingHours,
      efficiencyScore: efficiencyScore ?? this.efficiencyScore,
      topPerformingMonths: topPerformingMonths ?? this.topPerformingMonths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      metadata: metadata ?? this.metadata,
    );
  }

  // Computed properties
  double get completionRate => 
      totalPickupRequests > 0 ? (completedPickupRequests / totalPickupRequests) * 100 : 0.0;
  
  double get cancellationRate => 
      totalPickupRequests > 0 ? (cancelledPickupRequests / totalPickupRequests) * 100 : 0.0;
  
  double get customerRetentionRate => 
      totalCustomers > 0 ? (repeatCustomers / totalCustomers) * 100 : 0.0;
  
  double get averageWeightPerPickup => 
      completedPickupRequests > 0 ? totalWeightCollected / completedPickupRequests : 0.0;
  
  double get earningsPerHour => 
      totalWorkingHours > 0 ? totalEarnings / totalWorkingHours : 0.0;
  
  double get earningsPerPickup => 
      completedPickupRequests > 0 ? totalEarnings / completedPickupRequests : 0.0;

  // Performance indicators
  bool get isHighPerformer => completionRate >= 90 && averageRating >= 4.5;
  bool get isEfficient => efficiencyScore >= 80;
  bool get hasGoodCustomerRetention => customerRetentionRate >= 70;
  bool get isProfitable => earningsPerHour >= 100;

  // Performance level
  String get performanceLevel {
    if (isHighPerformer && isEfficient && isProfitable) return 'Excellent';
    if (isHighPerformer || isEfficient) return 'Good';
    if (completionRate >= 70 && averageRating >= 4.0) return 'Average';
    return 'Needs Improvement';
  }

  // Recommendations
  List<String> get recommendations {
    final recommendations = <String>[];
    
    if (completionRate < 80) {
      recommendations.add('Focus on completing more pickup requests on time');
    }
    
    if (averageRating < 4.0) {
      recommendations.add('Work on improving customer satisfaction');
    }
    
    if (customerRetentionRate < 60) {
      recommendations.add('Implement customer retention strategies');
    }
    
    if (earningsPerHour < 80) {
      recommendations.add('Optimize pricing and efficiency to increase earnings');
    }
    
    if (efficiencyScore < 70) {
      recommendations.add('Streamline processes to improve efficiency');
    }
    
    return recommendations;
  }
} 