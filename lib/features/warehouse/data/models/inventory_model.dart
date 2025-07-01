enum InventoryStatus { processing, graded, ready, used }

class InventoryModel {
  final String id;
  final String pickupId;
  final String fabricCategory;
  final String qualityGrade;
  final double actualWeight;
  final String? warehouseLocation;
  final InventoryStatus status;
  final Map<String, dynamic>? processingData;
  final DateTime? processedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InventoryModel({
    required this.id,
    required this.pickupId,
    required this.fabricCategory,
    required this.qualityGrade,
    required this.actualWeight,
    this.warehouseLocation,
    required this.status,
    this.processingData,
    this.processedDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      pickupId: json['pickupId'],
      fabricCategory: json['fabricCategory'],
      qualityGrade: json['qualityGrade'],
      actualWeight: json['actualWeight'].toDouble(),
      warehouseLocation: json['warehouseLocation'],
      status: InventoryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      processingData: json['processingData'],
      processedDate: json['processedDate'] != null 
          ? DateTime.parse(json['processedDate']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickupId': pickupId,
      'fabricCategory': fabricCategory,
      'qualityGrade': qualityGrade,
      'actualWeight': actualWeight,
      'warehouseLocation': warehouseLocation,
      'status': status.toString().split('.').last,
      'processingData': processingData,
      'processedDate': processedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  InventoryModel copyWith({
    String? id,
    String? pickupId,
    String? fabricCategory,
    String? qualityGrade,
    double? actualWeight,
    String? warehouseLocation,
    InventoryStatus? status,
    Map<String, dynamic>? processingData,
    DateTime? processedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      pickupId: pickupId ?? this.pickupId,
      fabricCategory: fabricCategory ?? this.fabricCategory,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      actualWeight: actualWeight ?? this.actualWeight,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      status: status ?? this.status,
      processingData: processingData ?? this.processingData,
      processedDate: processedDate ?? this.processedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedWeight => '${actualWeight.toStringAsFixed(2)} kg';
  bool get isProcessing => status == InventoryStatus.processing;
  bool get isGraded => status == InventoryStatus.graded;
  bool get isReady => status == InventoryStatus.ready;
  bool get isUsed => status == InventoryStatus.used;
} 