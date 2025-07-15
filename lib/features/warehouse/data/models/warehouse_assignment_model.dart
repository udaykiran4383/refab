enum WarehouseAssignmentStatus {
  scheduled,
  inTransit,
  arrived,
  processing,
  completed,
  cancelled
}

enum WarehouseSection {
  receivingArea,
  sortingArea,
  processingArea,
  storageArea,
  qualityCheckArea,
  dispatchArea
}

class WarehouseAssignmentModel {
  final String? id; // Make id optional
  final String logisticsAssignmentId;
  final String warehouseId;
  final String logisticsId;
  final String logisticsName;
  final String logisticsPhone;
  final String pickupRequestId;
  final String tailorId;
  final String tailorName;
  final String tailorAddress;
  final String tailorPhone;
  final String fabricType;
  final String fabricDescription;
  final double estimatedWeight;
  final double actualWeight;
  final double estimatedValue;
  final double actualValue;
  final WarehouseAssignmentStatus status;
  final DateTime? scheduledArrivalTime;
  final DateTime? actualArrivalTime;
  final WarehouseSection? warehouseSection;
  final String? notes;
  final String? specialInstructions;
  final List<String>? photos;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WarehouseAssignmentModel({
    this.id,
    required this.logisticsAssignmentId,
    required this.warehouseId,
    required this.logisticsId,
    required this.logisticsName,
    required this.logisticsPhone,
    required this.pickupRequestId,
    required this.tailorId,
    required this.tailorName,
    required this.tailorAddress,
    required this.tailorPhone,
    required this.fabricType,
    required this.fabricDescription,
    required this.estimatedWeight,
    this.actualWeight = 0.0,
    required this.estimatedValue,
    this.actualValue = 0.0,
    required this.status,
    this.scheduledArrivalTime,
    this.actualArrivalTime,
    this.warehouseSection,
    this.notes,
    this.specialInstructions,
    this.photos,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters for easy access
  String get statusDisplayName {
    switch (status) {
      case WarehouseAssignmentStatus.scheduled:
        return 'Scheduled';
      case WarehouseAssignmentStatus.inTransit:
        return 'In Transit';
      case WarehouseAssignmentStatus.arrived:
        return 'Arrived';
      case WarehouseAssignmentStatus.processing:
        return 'Processing';
      case WarehouseAssignmentStatus.completed:
        return 'Completed';
      case WarehouseAssignmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get warehouseSectionDisplayName {
    switch (warehouseSection) {
      case WarehouseSection.receivingArea:
        return 'Receiving Area';
      case WarehouseSection.sortingArea:
        return 'Sorting Area';
      case WarehouseSection.processingArea:
        return 'Processing Area';
      case WarehouseSection.storageArea:
        return 'Storage Area';
      case WarehouseSection.qualityCheckArea:
        return 'Quality Check Area';
      case WarehouseSection.dispatchArea:
        return 'Dispatch Area';
      default:
        return 'Not Assigned';
    }
  }

  String get formattedEstimatedWeight => '${estimatedWeight.toStringAsFixed(1)} kg';
  String get formattedActualWeight => '${actualWeight.toStringAsFixed(1)} kg';
  String get formattedEstimatedValue => '₹${estimatedValue.toStringAsFixed(2)}';
  String get formattedActualValue => '₹${actualValue.toStringAsFixed(2)}';

  bool get isScheduled => status == WarehouseAssignmentStatus.scheduled;
  bool get isInTransit => status == WarehouseAssignmentStatus.inTransit;
  bool get isArrived => status == WarehouseAssignmentStatus.arrived;
  bool get isProcessing => status == WarehouseAssignmentStatus.processing;
  bool get isCompleted => status == WarehouseAssignmentStatus.completed;
  bool get isCancelled => status == WarehouseAssignmentStatus.cancelled;

  String get formattedScheduledTime {
    if (scheduledArrivalTime == null) return 'Not scheduled';
    return '${scheduledArrivalTime!.day}/${scheduledArrivalTime!.month}/${scheduledArrivalTime!.year} at ${scheduledArrivalTime!.hour}:${scheduledArrivalTime!.minute.toString().padLeft(2, '0')}';
  }

  String get formattedActualTime {
    if (actualArrivalTime == null) return 'Not arrived yet';
    return '${actualArrivalTime!.day}/${actualArrivalTime!.month}/${actualArrivalTime!.year} at ${actualArrivalTime!.hour}:${actualArrivalTime!.minute.toString().padLeft(2, '0')}';
  }

  bool get isOverdue {
    if (scheduledArrivalTime == null) return false;
    return DateTime.now().isAfter(scheduledArrivalTime!) && !isArrived && !isCompleted;
  }

  Duration? get delayDuration {
    if (scheduledArrivalTime == null || actualArrivalTime == null) return null;
    return actualArrivalTime!.difference(scheduledArrivalTime!);
  }

  String get delayDisplay {
    final delay = delayDuration;
    if (delay == null) return 'On time';
    if (delay.isNegative) return 'Early by ${delay.inMinutes.abs()} minutes';
    return 'Delayed by ${delay.inMinutes} minutes';
  }

  factory WarehouseAssignmentModel.fromJson(Map<String, dynamic> json) {
    return WarehouseAssignmentModel(
      id: json['id'],
      logisticsAssignmentId: json['logisticsAssignmentId'],
      warehouseId: json['warehouseId'],
      logisticsId: json['logisticsId'],
      logisticsName: json['logisticsName'],
      logisticsPhone: json['logisticsPhone'],
      pickupRequestId: json['pickupRequestId'],
      tailorId: json['tailorId'],
      tailorName: json['tailorName'],
      tailorAddress: json['tailorAddress'],
      tailorPhone: json['tailorPhone'],
      fabricType: json['fabricType'],
      fabricDescription: json['fabricDescription'],
      estimatedWeight: json['estimatedWeight'].toDouble(),
      actualWeight: json['actualWeight']?.toDouble() ?? 0.0,
      estimatedValue: json['estimatedValue'].toDouble(),
      actualValue: json['actualValue']?.toDouble() ?? 0.0,
      status: WarehouseAssignmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => WarehouseAssignmentStatus.scheduled,
      ),
      scheduledArrivalTime: json['scheduledArrivalTime'] != null 
          ? DateTime.parse(json['scheduledArrivalTime']) 
          : null,
      actualArrivalTime: json['actualArrivalTime'] != null 
          ? DateTime.parse(json['actualArrivalTime']) 
          : null,
      warehouseSection: json['warehouseSection'] != null 
          ? WarehouseSection.values.firstWhere(
              (e) => e.toString().split('.').last == json['warehouseSection'],
              orElse: () => WarehouseSection.receivingArea,
            )
          : null,
      notes: json['notes'],
      specialInstructions: json['specialInstructions'],
      photos: json['photos'] != null 
          ? List<String>.from(json['photos'])
          : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'logisticsAssignmentId': logisticsAssignmentId,
      'warehouseId': warehouseId,
      'logisticsId': logisticsId,
      'logisticsName': logisticsName,
      'logisticsPhone': logisticsPhone,
      'pickupRequestId': pickupRequestId,
      'tailorId': tailorId,
      'tailorName': tailorName,
      'tailorAddress': tailorAddress,
      'tailorPhone': tailorPhone,
      'fabricType': fabricType,
      'fabricDescription': fabricDescription,
      'estimatedWeight': estimatedWeight,
      'actualWeight': actualWeight,
      'estimatedValue': estimatedValue,
      'actualValue': actualValue,
      'status': status.toString().split('.').last,
      'scheduledArrivalTime': scheduledArrivalTime?.toIso8601String(),
      'actualArrivalTime': actualArrivalTime?.toIso8601String(),
      'warehouseSection': warehouseSection?.toString().split('.').last,
      'notes': notes,
      'specialInstructions': specialInstructions,
      'photos': photos,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
    if (id != null && id!.isNotEmpty) {
      data['id'] = id;
    }
    return data;
  }

  WarehouseAssignmentModel copyWith({
    String? id,
    String? logisticsAssignmentId,
    String? warehouseId,
    String? logisticsId,
    String? logisticsName,
    String? logisticsPhone,
    String? pickupRequestId,
    String? tailorId,
    String? tailorName,
    String? tailorAddress,
    String? tailorPhone,
    String? fabricType,
    String? fabricDescription,
    double? estimatedWeight,
    double? actualWeight,
    double? estimatedValue,
    double? actualValue,
    WarehouseAssignmentStatus? status,
    DateTime? scheduledArrivalTime,
    DateTime? actualArrivalTime,
    WarehouseSection? warehouseSection,
    String? notes,
    String? specialInstructions,
    List<String>? photos,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseAssignmentModel(
      id: id ?? this.id,
      logisticsAssignmentId: logisticsAssignmentId ?? this.logisticsAssignmentId,
      warehouseId: warehouseId ?? this.warehouseId,
      logisticsId: logisticsId ?? this.logisticsId,
      logisticsName: logisticsName ?? this.logisticsName,
      logisticsPhone: logisticsPhone ?? this.logisticsPhone,
      pickupRequestId: pickupRequestId ?? this.pickupRequestId,
      tailorId: tailorId ?? this.tailorId,
      tailorName: tailorName ?? this.tailorName,
      tailorAddress: tailorAddress ?? this.tailorAddress,
      tailorPhone: tailorPhone ?? this.tailorPhone,
      fabricType: fabricType ?? this.fabricType,
      fabricDescription: fabricDescription ?? this.fabricDescription,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      actualValue: actualValue ?? this.actualValue,
      status: status ?? this.status,
      scheduledArrivalTime: scheduledArrivalTime ?? this.scheduledArrivalTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      warehouseSection: warehouseSection ?? this.warehouseSection,
      notes: notes ?? this.notes,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      photos: photos ?? this.photos,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 