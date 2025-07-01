enum AssignmentStatus { pending, assigned, inProgress, completed, cancelled }

class PickupAssignmentModel {
  final String id;
  final String logisticsId;
  final String pickupId;
  final String tailorId;
  final String pickupAddress;
  final double estimatedWeight;
  final String fabricType;
  final AssignmentStatus status;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? completedTime;
  final Map<String, dynamic>? completionData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PickupAssignmentModel({
    required this.id,
    required this.logisticsId,
    required this.pickupId,
    required this.tailorId,
    required this.pickupAddress,
    required this.estimatedWeight,
    required this.fabricType,
    required this.status,
    this.scheduledTime,
    this.startTime,
    this.completedTime,
    this.completionData,
    required this.createdAt,
    this.updatedAt,
  });

  factory PickupAssignmentModel.fromJson(Map<String, dynamic> json) {
    return PickupAssignmentModel(
      id: json['id'],
      logisticsId: json['logisticsId'],
      pickupId: json['pickupId'],
      tailorId: json['tailorId'],
      pickupAddress: json['pickupAddress'],
      estimatedWeight: json['estimatedWeight'].toDouble(),
      fabricType: json['fabricType'],
      status: AssignmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime']) 
          : null,
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : null,
      completedTime: json['completedTime'] != null 
          ? DateTime.parse(json['completedTime']) 
          : null,
      completionData: json['completionData'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logisticsId': logisticsId,
      'pickupId': pickupId,
      'tailorId': tailorId,
      'pickupAddress': pickupAddress,
      'estimatedWeight': estimatedWeight,
      'fabricType': fabricType,
      'status': status.toString().split('.').last,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'completionData': completionData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  PickupAssignmentModel copyWith({
    String? id,
    String? logisticsId,
    String? pickupId,
    String? tailorId,
    String? pickupAddress,
    double? estimatedWeight,
    String? fabricType,
    AssignmentStatus? status,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? completedTime,
    Map<String, dynamic>? completionData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PickupAssignmentModel(
      id: id ?? this.id,
      logisticsId: logisticsId ?? this.logisticsId,
      pickupId: pickupId ?? this.pickupId,
      tailorId: tailorId ?? this.tailorId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      fabricType: fabricType ?? this.fabricType,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      completionData: completionData ?? this.completionData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == AssignmentStatus.pending;
  bool get isAssigned => status == AssignmentStatus.assigned;
  bool get isInProgress => status == AssignmentStatus.inProgress;
  bool get isCompleted => status == AssignmentStatus.completed;
  bool get isCancelled => status == AssignmentStatus.cancelled;
  String get formattedWeight => '${estimatedWeight.toStringAsFixed(2)} kg';
  String get formattedScheduledTime => scheduledTime != null 
      ? '${scheduledTime!.day}/${scheduledTime!.month}/${scheduledTime!.year} ${scheduledTime!.hour}:${scheduledTime!.minute.toString().padLeft(2, '0')}'
      : 'Not scheduled';
} 