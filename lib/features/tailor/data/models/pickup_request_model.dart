extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : word).join(' ');
  }
}

enum PickupStatus { 
  pending, 
  scheduled, 
  inProgress, 
  pickedUp, 
  inTransit, 
  delivered, 
  completed, 
  cancelled,
  rejected 
}

// New enum for tailor work progress
enum TailorWorkProgress {
  notStarted,
  workStarted,
  workInProgress,
  workCompleted,
  qualityCheck,
  readyForPickup,
  completed
}

enum FabricType {
  cotton,
  silk,
  wool,
  polyester,
  linen,
  denim,
  velvet,
  satin,
  chiffon,
  other
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded
}

class PickupRequestModel {
  final String id;
  final String tailorId;
  final String? logisticsId;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final FabricType fabricType;
  final String fabricDescription;
  final double estimatedWeight;
  final double actualWeight;
  final String pickupAddress;
  final String? deliveryAddress;
  final PickupStatus status;
  final PaymentStatus paymentStatus;
  final double estimatedValue;
  final double actualValue;
  final List<String> photos;
  final List<String>? fabricSamples;
  final DateTime? scheduledDate;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final String? rejectionReason;
  final String? progress; // Legacy field - keeping for backward compatibility
  final TailorWorkProgress? workProgress; // New field for proper progress tracking
  final Map<String, dynamic>? metadata;
  
  // Cancellation tracking fields
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;

  PickupRequestModel({
    required this.id,
    required this.tailorId,
    this.logisticsId,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.fabricType,
    required this.fabricDescription,
    required this.estimatedWeight,
    this.actualWeight = 0.0,
    required this.pickupAddress,
    this.deliveryAddress,
    required this.status,
    this.paymentStatus = PaymentStatus.pending,
    required this.estimatedValue,
    this.actualValue = 0.0,
    required this.photos,
    this.fabricSamples,
    this.scheduledDate,
    this.pickupDate,
    this.deliveryDate,
    this.completedDate,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.rejectionReason,
    this.progress,
    this.workProgress,
    this.metadata,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
  });

  factory PickupRequestModel.fromJson(Map<String, dynamic> json) {
    // Parse work progress with fallback to legacy progress field
    TailorWorkProgress? workProgress;
    try {
      if (json['work_progress'] != null) {
        workProgress = TailorWorkProgress.values.firstWhere(
          (e) => e.toString().split('.').last == json['work_progress'],
          orElse: () => TailorWorkProgress.notStarted,
        );
      } else if (json['progress'] != null) {
        // Convert legacy progress to new enum
        workProgress = _convertLegacyProgressToEnum(json['progress']);
      }
    } catch (e) {
      workProgress = TailorWorkProgress.notStarted;
    }

    return PickupRequestModel(
      id: json['id'],
      tailorId: json['tailor_id'],
      logisticsId: json['logistics_id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerEmail: json['customer_email'],
      fabricType: FabricType.values.firstWhere(
        (e) => e.toString().split('.').last == json['fabric_type'],
        orElse: () => FabricType.other,
      ),
      fabricDescription: json['fabric_description'],
      estimatedWeight: json['estimated_weight'].toDouble(),
      actualWeight: json['actual_weight']?.toDouble() ?? 0.0,
      pickupAddress: json['pickup_address'],
      deliveryAddress: json['delivery_address'],
      status: PickupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PickupStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['payment_status'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      estimatedValue: json['estimated_value'].toDouble(),
      actualValue: json['actual_value']?.toDouble() ?? 0.0,
      photos: List<String>.from(json['photos'] ?? []),
      fabricSamples: json['fabric_samples'] != null 
          ? List<String>.from(json['fabric_samples']) 
          : null,
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date']) 
          : null,
      pickupDate: json['pickup_date'] != null 
          ? DateTime.parse(json['pickup_date']) 
          : null,
      deliveryDate: json['delivery_date'] != null 
          ? DateTime.parse(json['delivery_date']) 
          : null,
      completedDate: json['completed_date'] != null 
          ? DateTime.parse(json['completed_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      progress: json['progress'],
      workProgress: workProgress,
      metadata: json['metadata'],
      cancellationReason: json['cancellation_reason'],
      cancelledBy: json['cancelled_by'],
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tailor_id': tailorId,
      'logistics_id': logisticsId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'fabric_type': fabricType.toString().split('.').last,
      'fabric_description': fabricDescription,
      'estimated_weight': estimatedWeight,
      'actual_weight': actualWeight,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'status': status.toString().split('.').last,
      'payment_status': paymentStatus.toString().split('.').last,
      'estimated_value': estimatedValue,
      'actual_value': actualValue,
      'photos': photos,
      'fabric_samples': fabricSamples,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'pickup_date': pickupDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'rejection_reason': rejectionReason,
      'progress': progress,
      'work_progress': workProgress?.toString().split('.').last,
      'metadata': metadata,
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  PickupRequestModel copyWith({
    String? id,
    String? tailorId,
    String? logisticsId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    FabricType? fabricType,
    String? fabricDescription,
    double? estimatedWeight,
    double? actualWeight,
    String? pickupAddress,
    String? deliveryAddress,
    PickupStatus? status,
    PaymentStatus? paymentStatus,
    double? estimatedValue,
    double? actualValue,
    List<String>? photos,
    List<String>? fabricSamples,
    DateTime? scheduledDate,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    DateTime? completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? rejectionReason,
    String? progress,
    TailorWorkProgress? workProgress,
    Map<String, dynamic>? metadata,
  }) {
    return PickupRequestModel(
      id: id ?? this.id,
      tailorId: tailorId ?? this.tailorId,
      logisticsId: logisticsId ?? this.logisticsId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      fabricType: fabricType ?? this.fabricType,
      fabricDescription: fabricDescription ?? this.fabricDescription,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      actualValue: actualValue ?? this.actualValue,
      photos: photos ?? this.photos,
      fabricSamples: fabricSamples ?? this.fabricSamples,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      progress: progress ?? this.progress,
      workProgress: workProgress ?? this.workProgress,
      metadata: metadata ?? this.metadata,
    );
  }

  // Status getters
  bool get isPending => status == PickupStatus.pending;
  bool get isScheduled => status == PickupStatus.scheduled;
  bool get isInProgress => status == PickupStatus.inProgress;
  bool get isPickedUp => status == PickupStatus.pickedUp;
  bool get isInTransit => status == PickupStatus.inTransit;
  bool get isDelivered => status == PickupStatus.delivered;
  bool get isCompleted => status == PickupStatus.completed;
  bool get isCancelled => status == PickupStatus.cancelled;
  bool get isRejected => status == PickupStatus.rejected;

  // Work progress getters
  bool get isWorkNotStarted => workProgress == null || workProgress == TailorWorkProgress.notStarted;
  bool get isWorkStarted => workProgress == TailorWorkProgress.workStarted;
  bool get isWorkInProgress => workProgress == TailorWorkProgress.workInProgress;
  bool get isWorkCompleted => workProgress == TailorWorkProgress.workCompleted;
  bool get isQualityCheckDone => workProgress == TailorWorkProgress.qualityCheck;
  bool get isReadyForPickup => workProgress == TailorWorkProgress.readyForPickup;
  bool get isWorkFinished => workProgress == TailorWorkProgress.completed;

  // Progress calculation for progress bar
  double get workProgressPercentage {
    if (workProgress == null) return 0.0;
    
    switch (workProgress!) {
      case TailorWorkProgress.notStarted:
        return 0.0;
      case TailorWorkProgress.workStarted:
        return 20.0;
      case TailorWorkProgress.workInProgress:
        return 50.0;
      case TailorWorkProgress.workCompleted:
        return 70.0;
      case TailorWorkProgress.qualityCheck:
        return 85.0;
      case TailorWorkProgress.readyForPickup:
        return 95.0;
      case TailorWorkProgress.completed:
        return 100.0;
    }
  }

  // Business logic getters
  bool get canBeScheduled => isPending;
  bool get canBePickedUp => isScheduled || isInProgress;
  bool get canBeDelivered => isPickedUp || isInTransit;
  bool get canBeCompleted => isDelivered;
  bool get canBeCancelled => !isCompleted && !isCancelled && !isRejected;

  // Check if tailor can start work (fabric must be picked up)
  bool get canStartWork => isPickedUp || isInTransit || isDelivered;
  
  // Check if tailor can update work progress
  bool get canUpdateWorkProgress => canStartWork && !isWorkFinished;

  String get statusDisplayName {
    switch (status) {
      case PickupStatus.pending:
        return 'Pending';
      case PickupStatus.scheduled:
        return 'Scheduled';
      case PickupStatus.inProgress:
        return 'In Progress';
      case PickupStatus.pickedUp:
        return 'Picked Up';
      case PickupStatus.inTransit:
        return 'In Transit';
      case PickupStatus.delivered:
        return 'Delivered';
      case PickupStatus.completed:
        return 'Completed';
      case PickupStatus.cancelled:
        return 'Cancelled';
      case PickupStatus.rejected:
        return 'Rejected';
      default:
        return status.toString().split('.').last.replaceAll('_', ' ').toTitleCase();
    }
  }

  String get workProgressDisplayName {
    if (workProgress == null) return 'Not Started';
    
    switch (workProgress!) {
      case TailorWorkProgress.notStarted:
        return 'Not Started';
      case TailorWorkProgress.workStarted:
        return 'Work Started';
      case TailorWorkProgress.workInProgress:
        return 'Work In Progress';
      case TailorWorkProgress.workCompleted:
        return 'Work Completed';
      case TailorWorkProgress.qualityCheck:
        return 'Quality Check';
      case TailorWorkProgress.readyForPickup:
        return 'Ready for Pickup';
      case TailorWorkProgress.completed:
        return 'Completed';
    }
  }

  String get fabricTypeDisplayName {
    switch (fabricType) {
      case FabricType.cotton:
        return 'Cotton';
      case FabricType.silk:
        return 'Silk';
      case FabricType.wool:
        return 'Wool';
      case FabricType.polyester:
        return 'Polyester';
      case FabricType.linen:
        return 'Linen';
      case FabricType.denim:
        return 'Denim';
      case FabricType.velvet:
        return 'Velvet';
      case FabricType.satin:
        return 'Satin';
      case FabricType.chiffon:
        return 'Chiffon';
      case FabricType.other:
        return 'Other';
    }
  }
}

// Helper function to convert legacy progress strings to new enum
TailorWorkProgress _convertLegacyProgressToEnum(String? legacyProgress) {
  if (legacyProgress == null) return TailorWorkProgress.notStarted;
  
  switch (legacyProgress.toLowerCase()) {
    case 'not started':
      return TailorWorkProgress.notStarted;
    case 'started work':
    case 'work started':
      return TailorWorkProgress.workStarted;
    case 'work in progress':
    case 'in progress':
      return TailorWorkProgress.workInProgress;
    case 'work completed':
    case 'completed':
      return TailorWorkProgress.workCompleted;
    case 'quality check done':
    case 'quality check':
      return TailorWorkProgress.qualityCheck;
    case 'ready for pickup':
      return TailorWorkProgress.readyForPickup;
    default:
      return TailorWorkProgress.notStarted;
  }
}
