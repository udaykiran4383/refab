enum LogisticsAssignmentType {
  pickup,    // Tailor → Logistics → Warehouse
  delivery   // Warehouse → Logistics → Customer
}

enum LogisticsAssignmentStatus { 
  pending, 
  assigned, 
  inProgress, 
  completed, 
  cancelled 
}

enum WarehouseType {
  mainWarehouse,
  processingWarehouse,
  distributionWarehouse,
  regionalWarehouse
}

class LogisticsAssignmentModel {
  final String id;
  final String logisticsId;
  final String pickupRequestId;
  final LogisticsAssignmentType type; // pickup or delivery
  
  // For pickup assignments (tailor to warehouse)
  final String? tailorId;
  final String? tailorName;
  final String? tailorAddress;
  final String? tailorPhone;
  
  // For delivery assignments (warehouse to customer)
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  
  // Common fields
  final String fabricType;
  final String fabricDescription;
  final double estimatedWeight;
  final double actualWeight;
  final LogisticsAssignmentStatus status;
  
  // Warehouse information
  final String? assignedWarehouseId;
  final String? assignedWarehouseName;
  final WarehouseType? warehouseType;
  final String? warehouseAddress;
  
  // Timing fields
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? completedTime;
  
  // Additional data
  final Map<String, dynamic>? assignmentData;
  final String? notes;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LogisticsAssignmentModel({
    required this.id,
    required this.logisticsId,
    required this.pickupRequestId,
    required this.type,
    this.tailorId,
    this.tailorName,
    this.tailorAddress,
    this.tailorPhone,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    required this.fabricType,
    required this.fabricDescription,
    required this.estimatedWeight,
    this.actualWeight = 0.0,
    required this.status,
    this.assignedWarehouseId,
    this.assignedWarehouseName,
    this.warehouseType,
    this.warehouseAddress,
    this.scheduledTime,
    this.startTime,
    this.completedTime,
    this.assignmentData,
    this.notes,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters for easy access
  String get assignmentTypeDisplayName => type == LogisticsAssignmentType.pickup ? 'Pickup' : 'Delivery';
  String get sourceName => type == LogisticsAssignmentType.pickup ? (tailorName ?? 'Unknown Tailor') : (assignedWarehouseName ?? 'Unknown Warehouse');
  String get destinationName => type == LogisticsAssignmentType.pickup ? (assignedWarehouseName ?? 'Unknown Warehouse') : (customerName ?? 'Unknown Customer');
  String get sourceAddress => type == LogisticsAssignmentType.pickup ? (tailorAddress ?? '') : (warehouseAddress ?? '');
  String get destinationAddress => type == LogisticsAssignmentType.pickup ? (warehouseAddress ?? '') : (customerAddress ?? '');
  String get formattedWeight => '${estimatedWeight.toStringAsFixed(1)} kg';
  double get progressPercentage {
    switch (status) {
      case LogisticsAssignmentStatus.pending:
        return 0.0;
      case LogisticsAssignmentStatus.assigned:
        return 25.0;
      case LogisticsAssignmentStatus.inProgress:
        return 75.0;
      case LogisticsAssignmentStatus.completed:
        return 100.0;
      case LogisticsAssignmentStatus.cancelled:
        return 0.0;
    }
  }

  // Status check methods
  bool get isPending => status == LogisticsAssignmentStatus.pending;
  bool get isAssigned => status == LogisticsAssignmentStatus.assigned;
  bool get isInProgress => status == LogisticsAssignmentStatus.inProgress;
  bool get isCompleted => status == LogisticsAssignmentStatus.completed;
  bool get isCancelled => status == LogisticsAssignmentStatus.cancelled;

  String get statusDisplayName {
    switch (status) {
      case LogisticsAssignmentStatus.pending:
        return 'Pending';
      case LogisticsAssignmentStatus.assigned:
        return 'Assigned';
      case LogisticsAssignmentStatus.inProgress:
        return 'In Progress';
      case LogisticsAssignmentStatus.completed:
        return 'Completed';
      case LogisticsAssignmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get warehouseTypeDisplayName {
    switch (warehouseType) {
      case WarehouseType.mainWarehouse:
        return 'Main Warehouse';
      case WarehouseType.processingWarehouse:
        return 'Processing Warehouse';
      case WarehouseType.distributionWarehouse:
        return 'Distribution Warehouse';
      case WarehouseType.regionalWarehouse:
        return 'Regional Warehouse';
      default:
        return 'Unknown Warehouse';
    }
  }

  factory LogisticsAssignmentModel.fromJson(Map<String, dynamic> json) {
    return LogisticsAssignmentModel(
      id: json['id'],
      logisticsId: json['logistics_id'],
      pickupRequestId: json['pickup_request_id'],
      type: LogisticsAssignmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LogisticsAssignmentType.pickup,
      ),
      tailorId: json['tailor_id'],
      tailorName: json['tailor_name'],
      tailorAddress: json['tailor_address'],
      tailorPhone: json['tailor_phone'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerEmail: json['customer_email'],
      customerAddress: json['customer_address'],
      fabricType: json['fabric_type'],
      fabricDescription: json['fabric_description'],
      estimatedWeight: json['estimated_weight'].toDouble(),
      actualWeight: json['actual_weight']?.toDouble() ?? 0.0,
      status: LogisticsAssignmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LogisticsAssignmentStatus.pending,
      ),
      assignedWarehouseId: json['assigned_warehouse_id'],
      assignedWarehouseName: json['assigned_warehouse_name'],
      warehouseType: json['warehouse_type'] != null 
          ? WarehouseType.values.firstWhere(
              (e) => e.toString().split('.').last == json['warehouse_type'],
              orElse: () => WarehouseType.mainWarehouse,
            )
          : null,
      warehouseAddress: json['warehouse_address'],
      scheduledTime: json['scheduled_time'] != null 
          ? DateTime.parse(json['scheduled_time']) 
          : null,
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : null,
      completedTime: json['completed_time'] != null 
          ? DateTime.parse(json['completed_time']) 
          : null,
      assignmentData: json['assignment_data'],
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logistics_id': logisticsId,
      'pickup_request_id': pickupRequestId,
      'type': type.toString().split('.').last,
      'tailor_id': tailorId,
      'tailor_name': tailorName,
      'tailor_address': tailorAddress,
      'tailor_phone': tailorPhone,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'customer_address': customerAddress,
      'fabric_type': fabricType,
      'fabric_description': fabricDescription,
      'estimated_weight': estimatedWeight,
      'actual_weight': actualWeight,
      'status': status.toString().split('.').last,
      'assigned_warehouse_id': assignedWarehouseId,
      'assigned_warehouse_name': assignedWarehouseName,
      'warehouse_type': warehouseType?.toString().split('.').last,
      'warehouse_address': warehouseAddress,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'start_time': startTime?.toIso8601String(),
      'completed_time': completedTime?.toIso8601String(),
      'assignment_data': assignmentData,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  LogisticsAssignmentModel copyWith({
    String? id,
    String? logisticsId,
    String? pickupRequestId,
    LogisticsAssignmentType? type,
    String? tailorId,
    String? tailorName,
    String? tailorAddress,
    String? tailorPhone,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? fabricType,
    String? fabricDescription,
    double? estimatedWeight,
    double? actualWeight,
    LogisticsAssignmentStatus? status,
    String? assignedWarehouseId,
    String? assignedWarehouseName,
    WarehouseType? warehouseType,
    String? warehouseAddress,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? completedTime,
    Map<String, dynamic>? assignmentData,
    String? notes,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LogisticsAssignmentModel(
      id: id ?? this.id,
      logisticsId: logisticsId ?? this.logisticsId,
      pickupRequestId: pickupRequestId ?? this.pickupRequestId,
      type: type ?? this.type,
      tailorId: tailorId ?? this.tailorId,
      tailorName: tailorName ?? this.tailorName,
      tailorAddress: tailorAddress ?? this.tailorAddress,
      tailorPhone: tailorPhone ?? this.tailorPhone,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      fabricType: fabricType ?? this.fabricType,
      fabricDescription: fabricDescription ?? this.fabricDescription,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      status: status ?? this.status,
      assignedWarehouseId: assignedWarehouseId ?? this.assignedWarehouseId,
      assignedWarehouseName: assignedWarehouseName ?? this.assignedWarehouseName,
      warehouseType: warehouseType ?? this.warehouseType,
      warehouseAddress: warehouseAddress ?? this.warehouseAddress,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      assignmentData: assignmentData ?? this.assignmentData,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 