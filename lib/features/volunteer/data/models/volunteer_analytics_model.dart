class VolunteerAnalyticsModel {
  final double totalHours;
  final double verifiedHours;
  final double thisMonthHours;
  final double lastMonthHours;
  final double hoursGrowthRate;
  final double hoursToCertificate;

  VolunteerAnalyticsModel({
    required this.totalHours,
    required this.verifiedHours,
    required this.thisMonthHours,
    required this.lastMonthHours,
    required this.hoursGrowthRate,
    required this.hoursToCertificate,
  });

  factory VolunteerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return VolunteerAnalyticsModel(
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      verifiedHours: (json['verifiedHours'] ?? 0).toDouble(),
      thisMonthHours: (json['thisMonthHours'] ?? 0).toDouble(),
      lastMonthHours: (json['lastMonthHours'] ?? 0).toDouble(),
      hoursGrowthRate: (json['hoursGrowthRate'] ?? 0).toDouble(),
      hoursToCertificate: (json['hoursToCertificate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHours': totalHours,
      'verifiedHours': verifiedHours,
      'thisMonthHours': thisMonthHours,
      'lastMonthHours': lastMonthHours,
      'hoursGrowthRate': hoursGrowthRate,
      'hoursToCertificate': hoursToCertificate,
    };
  }

  String get formattedTotalHours => '${totalHours.toStringAsFixed(1)} hours';
  String get formattedVerifiedHours => '${verifiedHours.toStringAsFixed(1)} hours';
  String get formattedThisMonthHours => '${thisMonthHours.toStringAsFixed(1)} hours';
  double get unverifiedHours => totalHours - verifiedHours;
  bool get isHoursGrowthPositive => hoursGrowthRate > 0;
  bool get isCertificateEligible => hoursToCertificate <= 0;
  double get certificateProgress => (verifiedHours / 50) * 100; // Assuming 50 hours for certificate
} 