class ReportModel {
  final String id;
  final String reportType; // 'pickup_requests', 'orders', 'users', 'revenue', 'impact'
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;
  final String generatedBy;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? charts;
  final String? downloadUrl;
  final bool isScheduled;
  final String? scheduleFrequency; // 'daily', 'weekly', 'monthly'

  ReportModel({
    required this.id,
    required this.reportType,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.generatedBy,
    required this.data,
    this.charts,
    this.downloadUrl,
    this.isScheduled = false,
    this.scheduleFrequency,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reportType: json['reportType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      generatedAt: DateTime.parse(json['generatedAt']),
      generatedBy: json['generatedBy'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      charts: json['charts'] != null 
          ? Map<String, dynamic>.from(json['charts']) 
          : null,
      downloadUrl: json['downloadUrl'],
      isScheduled: json['isScheduled'] ?? false,
      scheduleFrequency: json['scheduleFrequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportType': reportType,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'data': data,
      'charts': charts,
      'downloadUrl': downloadUrl,
      'isScheduled': isScheduled,
      'scheduleFrequency': scheduleFrequency,
    };
  }

  ReportModel copyWith({
    String? id,
    String? reportType,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? generatedAt,
    String? generatedBy,
    Map<String, dynamic>? data,
    Map<String, dynamic>? charts,
    String? downloadUrl,
    bool? isScheduled,
    String? scheduleFrequency,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reportType: reportType ?? this.reportType,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
      data: data ?? this.data,
      charts: charts ?? this.charts,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduleFrequency: scheduleFrequency ?? this.scheduleFrequency,
    );
  }

  String get dateRange {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isPickupReport => reportType == 'pickup_requests';
  bool get isOrderReport => reportType == 'orders';
  bool get isUserReport => reportType == 'users';
  bool get isRevenueReport => reportType == 'revenue';
  bool get isImpactReport => reportType == 'impact';

  // Convenience getters for common report data
  int get totalCount => data['totalCount'] ?? 0;
  int get completedCount => data['completedCount'] ?? 0;
  double get completionRate => data['completionRate'] ?? 0.0;
  double get totalRevenue => (data['totalRevenue'] ?? 0).toDouble();
  double get totalWeight => (data['totalWeight'] ?? 0).toDouble();
  Map<String, int> get roleDistribution => 
      Map<String, int>.from(data['roleDistribution'] ?? {});
} 