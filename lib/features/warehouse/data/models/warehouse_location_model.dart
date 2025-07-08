enum LocationType { zone, section, shelf, bin, pallet }
enum LocationStatus { available, occupied, reserved, maintenance, blocked }

class WarehouseLocationModel {
  final String id;
  final String warehouseId;
  final String name;
  final String code;
  final LocationType type;
  final LocationStatus status;
  final String? parentLocationId;
  final double? capacity;
  final double? currentOccupancy;
  final List<String>? allowedCategories;
  final Map<String, dynamic>? dimensions;
  final Map<String, dynamic>? environmentalConditions;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WarehouseLocationModel({
    required this.id,
    required this.warehouseId,
    required this.name,
    required this.code,
    required this.type,
    required this.status,
    this.parentLocationId,
    this.capacity,
    this.currentOccupancy,
    this.allowedCategories,
    this.dimensions,
    this.environmentalConditions,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory WarehouseLocationModel.fromJson(Map<String, dynamic> json) {
    return WarehouseLocationModel(
      id: json['id'],
      warehouseId: json['warehouseId'],
      name: json['name'],
      code: json['code'],
      type: LocationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => LocationType.section,
      ),
      status: LocationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => LocationStatus.available,
      ),
      parentLocationId: json['parentLocationId'],
      capacity: json['capacity']?.toDouble(),
      currentOccupancy: json['currentOccupancy']?.toDouble(),
      allowedCategories: json['allowedCategories'] != null 
          ? List<String>.from(json['allowedCategories'])
          : null,
      dimensions: json['dimensions'],
      environmentalConditions: json['environmentalConditions'],
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
      'name': name,
      'code': code,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'parentLocationId': parentLocationId,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'allowedCategories': allowedCategories,
      'dimensions': dimensions,
      'environmentalConditions': environmentalConditions,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  WarehouseLocationModel copyWith({
    String? id,
    String? warehouseId,
    String? name,
    String? code,
    LocationType? type,
    LocationStatus? status,
    String? parentLocationId,
    double? capacity,
    double? currentOccupancy,
    List<String>? allowedCategories,
    Map<String, dynamic>? dimensions,
    Map<String, dynamic>? environmentalConditions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseLocationModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      status: status ?? this.status,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      allowedCategories: allowedCategories ?? this.allowedCategories,
      dimensions: dimensions ?? this.dimensions,
      environmentalConditions: environmentalConditions ?? this.environmentalConditions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => status == LocationStatus.available;
  bool get isOccupied => status == LocationStatus.occupied;
  bool get isReserved => status == LocationStatus.reserved;
  bool get isMaintenance => status == LocationStatus.maintenance;
  bool get isBlocked => status == LocationStatus.blocked;
  bool get isZone => type == LocationType.zone;
  bool get isSection => type == LocationType.section;
  bool get isShelf => type == LocationType.shelf;
  bool get isBin => type == LocationType.bin;
  bool get isPallet => type == LocationType.pallet;
  String get typeLabel => type.toString().split('.').last;
  String get statusLabel => status.toString().split('.').last;
  double get occupancyRate => capacity != null && capacity! > 0 
      ? (currentOccupancy ?? 0) / capacity! * 100 
      : 0;
  bool get isFull => capacity != null && currentOccupancy != null 
      ? currentOccupancy! >= capacity! 
      : false;
  bool canAcceptCategory(String category) {
    return allowedCategories == null || allowedCategories!.contains(category);
  }
} 