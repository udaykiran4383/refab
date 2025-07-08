class CustomerAnalyticsModel {
  final String customerId;
  final Map<String, dynamic> orderMetrics;
  final Map<String, dynamic> productMetrics;
  final Map<String, dynamic> engagementMetrics;
  final Map<String, dynamic> financialMetrics;
  final Map<String, dynamic> behavioralMetrics;
  final Map<String, dynamic> loyaltyMetrics;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CustomerAnalyticsModel({
    required this.customerId,
    this.orderMetrics = const {},
    this.productMetrics = const {},
    this.engagementMetrics = const {},
    this.financialMetrics = const {},
    this.behavioralMetrics = const {},
    this.loyaltyMetrics = const {},
    required this.createdAt,
    this.updatedAt,
  });

  factory CustomerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CustomerAnalyticsModel(
      customerId: json['customerId'],
      orderMetrics: Map<String, dynamic>.from(json['orderMetrics'] ?? {}),
      productMetrics: Map<String, dynamic>.from(json['productMetrics'] ?? {}),
      engagementMetrics: Map<String, dynamic>.from(json['engagementMetrics'] ?? {}),
      financialMetrics: Map<String, dynamic>.from(json['financialMetrics'] ?? {}),
      behavioralMetrics: Map<String, dynamic>.from(json['behavioralMetrics'] ?? {}),
      loyaltyMetrics: Map<String, dynamic>.from(json['loyaltyMetrics'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'orderMetrics': orderMetrics,
      'productMetrics': productMetrics,
      'engagementMetrics': engagementMetrics,
      'financialMetrics': financialMetrics,
      'behavioralMetrics': behavioralMetrics,
      'loyaltyMetrics': loyaltyMetrics,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CustomerAnalyticsModel copyWith({
    String? customerId,
    Map<String, dynamic>? orderMetrics,
    Map<String, dynamic>? productMetrics,
    Map<String, dynamic>? engagementMetrics,
    Map<String, dynamic>? financialMetrics,
    Map<String, dynamic>? behavioralMetrics,
    Map<String, dynamic>? loyaltyMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerAnalyticsModel(
      customerId: customerId ?? this.customerId,
      orderMetrics: orderMetrics ?? this.orderMetrics,
      productMetrics: productMetrics ?? this.productMetrics,
      engagementMetrics: engagementMetrics ?? this.engagementMetrics,
      financialMetrics: financialMetrics ?? this.financialMetrics,
      behavioralMetrics: behavioralMetrics ?? this.behavioralMetrics,
      loyaltyMetrics: loyaltyMetrics ?? this.loyaltyMetrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Order Metrics
  int get totalOrders => orderMetrics['totalOrders'] ?? 0;
  int get completedOrders => orderMetrics['completedOrders'] ?? 0;
  int get cancelledOrders => orderMetrics['cancelledOrders'] ?? 0;
  int get pendingOrders => orderMetrics['pendingOrders'] ?? 0;
  double get orderCompletionRate => totalOrders > 0 ? completedOrders / totalOrders : 0.0;
  DateTime? get firstOrderDate {
    final timestamp = orderMetrics['firstOrderDate'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  DateTime? get lastOrderDate {
    final timestamp = orderMetrics['lastOrderDate'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  int get daysSinceLastOrder {
    if (lastOrderDate == null) return 0;
    return DateTime.now().difference(lastOrderDate!).inDays;
  }

  // Product Metrics
  int get totalProductsPurchased => productMetrics['totalProductsPurchased'] ?? 0;
  int get uniqueProductsPurchased => productMetrics['uniqueProductsPurchased'] ?? 0;
  List<String> get topCategories => List<String>.from(productMetrics['topCategories'] ?? []);
  List<String> get favoriteProducts => List<String>.from(productMetrics['favoriteProducts'] ?? []);
  Map<String, int> get categoryPreferences {
    final data = productMetrics['categoryPreferences'];
    if (data is Map) {
      return Map<String, int>.from(data);
    }
    return {};
  }

  // Engagement Metrics
  int get totalLogins => engagementMetrics['totalLogins'] ?? 0;
  int get totalSessions => engagementMetrics['totalSessions'] ?? 0;
  double get averageSessionDuration => (engagementMetrics['averageSessionDuration'] ?? 0.0).toDouble();
  DateTime? get lastLoginDate {
    final timestamp = engagementMetrics['lastLoginDate'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  int get daysSinceLastLogin {
    if (lastLoginDate == null) return 0;
    return DateTime.now().difference(lastLoginDate!).inDays;
  }
  List<String> get visitedPages => List<String>.from(engagementMetrics['visitedPages'] ?? []);
  Map<String, int> get pageVisits {
    final data = engagementMetrics['pageVisits'];
    if (data is Map) {
      return Map<String, int>.from(data);
    }
    return {};
  }

  // Financial Metrics
  double get totalSpent => (financialMetrics['totalSpent'] ?? 0.0).toDouble();
  double get averageOrderValue => totalOrders > 0 ? totalSpent / totalOrders : 0.0;
  double get highestOrderValue => (financialMetrics['highestOrderValue'] ?? 0.0).toDouble();
  double get lowestOrderValue => (financialMetrics['lowestOrderValue'] ?? 0.0).toDouble();
  List<double> get monthlySpending => List<double>.from(financialMetrics['monthlySpending'] ?? []);
  Map<String, double> get spendingByCategory {
    final data = financialMetrics['spendingByCategory'];
    if (data is Map) {
      return Map<String, double>.from(data);
    }
    return {};
  }

  // Behavioral Metrics
  int get wishlistItems => behavioralMetrics['wishlistItems'] ?? 0;
  int get cartAbandonments => behavioralMetrics['cartAbandonments'] ?? 0;
  double get cartAbandonmentRate => totalOrders > 0 ? cartAbandonments / (totalOrders + cartAbandonments) : 0.0;
  int get productReviews => behavioralMetrics['productReviews'] ?? 0;
  double get averageRating => (behavioralMetrics['averageRating'] ?? 0.0).toDouble();
  List<String> get searchTerms => List<String>.from(behavioralMetrics['searchTerms'] ?? []);
  Map<String, int> get searchFrequency {
    final data = behavioralMetrics['searchFrequency'];
    if (data is Map) {
      return Map<String, int>.from(data);
    }
    return {};
  }

  // Loyalty Metrics
  int get loyaltyPoints => loyaltyMetrics['loyaltyPoints'] ?? 0;
  int get loyaltyTier => loyaltyMetrics['loyaltyTier'] ?? 1;
  String get loyaltyStatus => loyaltyMetrics['loyaltyStatus'] ?? 'Bronze';
  int get referralCount => loyaltyMetrics['referralCount'] ?? 0;
  double get referralValue => (loyaltyMetrics['referralValue'] ?? 0.0).toDouble();
  List<String> get referralHistory => List<String>.from(loyaltyMetrics['referralHistory'] ?? []);
  DateTime? get loyaltyJoinDate {
    final timestamp = loyaltyMetrics['loyaltyJoinDate'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // Computed Properties
  bool get isActiveCustomer => daysSinceLastOrder <= 90;
  bool get isEngagedCustomer => daysSinceLastLogin <= 30;
  bool get isHighValueCustomer => totalSpent >= 10000;
  bool get isLoyalCustomer => totalOrders >= 5;
  bool get isAtRiskCustomer => daysSinceLastOrder > 180 && totalSpent > 0;

  String get customerSegment {
    if (isHighValueCustomer && isLoyalCustomer) return 'VIP';
    if (isHighValueCustomer) return 'High Value';
    if (isLoyalCustomer) return 'Loyal';
    if (isActiveCustomer) return 'Active';
    if (isAtRiskCustomer) return 'At Risk';
    return 'New';
  }

  double get customerLifetimeValue => totalSpent + (referralValue * 0.1);
  double get customerRetentionScore {
    if (totalOrders == 0) return 0.0;
    if (totalOrders == 1) return 0.3;
    if (totalOrders <= 3) return 0.6;
    if (totalOrders <= 10) return 0.8;
    return 1.0;
  }

  // Risk Assessment
  double get churnRisk {
    if (isAtRiskCustomer) return 0.8;
    if (daysSinceLastOrder > 90) return 0.6;
    if (daysSinceLastOrder > 60) return 0.4;
    if (daysSinceLastOrder > 30) return 0.2;
    return 0.1;
  }

  // Engagement Score
  double get engagementScore {
    double score = 0.0;
    
    // Login frequency
    if (daysSinceLastLogin <= 7) score += 0.3;
    else if (daysSinceLastLogin <= 30) score += 0.2;
    else if (daysSinceLastLogin <= 90) score += 0.1;
    
    // Order frequency
    if (daysSinceLastOrder <= 30) score += 0.3;
    else if (daysSinceLastOrder <= 90) score += 0.2;
    else if (daysSinceLastOrder <= 180) score += 0.1;
    
    // Interaction depth
    if (productReviews > 0) score += 0.2;
    if (wishlistItems > 0) score += 0.1;
    if (referralCount > 0) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  // Recommendations
  List<String> get recommendations {
    final recommendations = <String>[];
    
    if (isAtRiskCustomer) {
      recommendations.add('Send re-engagement campaign');
      recommendations.add('Offer personalized discount');
    }
    
    if (cartAbandonmentRate > 0.5) {
      recommendations.add('Implement cart recovery emails');
      recommendations.add('Simplify checkout process');
    }
    
    if (engagementScore < 0.3) {
      recommendations.add('Increase communication frequency');
      recommendations.add('Personalize content');
    }
    
    if (totalOrders == 1) {
      recommendations.add('Send welcome series');
      recommendations.add('Offer second purchase incentive');
    }
    
    if (referralCount == 0 && totalSpent > 5000) {
      recommendations.add('Launch referral program');
      recommendations.add('Offer referral rewards');
    }
    
    return recommendations;
  }
} 