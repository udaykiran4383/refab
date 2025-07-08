enum InventoryStatus { processing, graded, ready, used, lowStock, reserved, damaged }

class InventoryModel {
  final String id;
  final String warehouseId;
  final String pickupId;
  final String fabricCategory;
  final String qualityGrade;
  final double actualWeight;
  final double estimatedWeight;
  final String? warehouseLocation;
  final String? supplierName;
  final String? batchNumber;
  final double? costPerKg;
  final InventoryStatus status;
  final Map<String, dynamic>? processingData;
  final Map<String, dynamic>? qualityData;
  final DateTime? processedDate;
  final DateTime? expiryDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InventoryModel({
    required this.id,
    required this.warehouseId,
    required this.pickupId,
    required this.fabricCategory,
    required this.qualityGrade,
    required this.actualWeight,
    required this.estimatedWeight,
    this.warehouseLocation,
    this.supplierName,
    this.batchNumber,
    this.costPerKg,
    required this.status,
    this.processingData,
    this.qualityData,
    this.processedDate,
    this.expiryDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      warehouseId: json['warehouseId'],
      pickupId: json['pickupId'],
      fabricCategory: json['fabricCategory'],
      qualityGrade: json['qualityGrade'],
      actualWeight: json['actualWeight'].toDouble(),
      estimatedWeight: json['estimatedWeight'].toDouble(),
      warehouseLocation: json['warehouseLocation'],
      supplierName: json['supplierName'],
      batchNumber: json['batchNumber'],
      costPerKg: json['costPerKg']?.toDouble(),
      status: InventoryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => InventoryStatus.processing,
      ),
      processingData: json['processingData'],
      qualityData: json['qualityData'],
      processedDate: json['processedDate'] != null 
          ? DateTime.parse(json['processedDate']) 
          : null,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseId': warehouseId,
      'pickupId': pickupId,
      'fabricCategory': fabricCategory,
      'qualityGrade': qualityGrade,
      'actualWeight': actualWeight,
      'estimatedWeight': estimatedWeight,
      'warehouseLocation': warehouseLocation,
      'supplierName': supplierName,
      'batchNumber': batchNumber,
      'costPerKg': costPerKg,
      'status': status.toString().split('.').last,
      'processingData': processingData,
      'qualityData': qualityData,
      'processedDate': processedDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  InventoryModel copyWith({
    String? id,
    String? warehouseId,
    String? pickupId,
    String? fabricCategory,
    String? qualityGrade,
    double? actualWeight,
    double? estimatedWeight,
    String? warehouseLocation,
    String? supplierName,
    String? batchNumber,
    double? costPerKg,
    InventoryStatus? status,
    Map<String, dynamic>? processingData,
    Map<String, dynamic>? qualityData,
    DateTime? processedDate,
    DateTime? expiryDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      pickupId: pickupId ?? this.pickupId,
      fabricCategory: fabricCategory ?? this.fabricCategory,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      actualWeight: actualWeight ?? this.actualWeight,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      supplierName: supplierName ?? this.supplierName,
      batchNumber: batchNumber ?? this.batchNumber,
      costPerKg: costPerKg ?? this.costPerKg,
      status: status ?? this.status,
      processingData: processingData ?? this.processingData,
      qualityData: qualityData ?? this.qualityData,
      processedDate: processedDate ?? this.processedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedWeight => '${actualWeight.toStringAsFixed(2)} kg';
  String get formattedEstimatedWeight => '${estimatedWeight.toStringAsFixed(2)} kg';
  String get formattedCost => costPerKg != null ? '\$${(costPerKg! * actualWeight).toStringAsFixed(2)}' : 'N/A';
  bool get isProcessing => status == InventoryStatus.processing;
  bool get isGraded => status == InventoryStatus.graded;
  bool get isReady => status == InventoryStatus.ready;
  bool get isUsed => status == InventoryStatus.used;
  bool get isLowStock => status == InventoryStatus.lowStock;
  bool get isReserved => status == InventoryStatus.reserved;
  bool get isDamaged => status == InventoryStatus.damaged;
  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get needsAttention => isLowStock || isDamaged || isExpired;

  String get statusLabel {
    switch (status) {
      case InventoryStatus.processing:
        return 'Processing';
      case InventoryStatus.graded:
        return 'Graded';
      case InventoryStatus.ready:
        return 'Ready';
      case InventoryStatus.used:
        return 'Used';
      case InventoryStatus.lowStock:
        return 'Low Stock';
      case InventoryStatus.reserved:
        return 'Reserved';
      case InventoryStatus.damaged:
        return 'Damaged';
    }
  }
} 