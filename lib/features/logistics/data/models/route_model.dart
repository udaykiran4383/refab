enum RouteStatus { planned, inProgress, completed, cancelled, delayed, rerouted }

class RouteModel {
  final String id;
  final String logisticsId;
  final String routeName;
  final List<String> pickupIds;
  final List<String> warehouseIds;
  final List<RouteStop> stops;
  final double totalDistance;
  final int estimatedDuration;
  final RouteStatus status;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final String? vehicleId;
  final String? vehicleType;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final Map<String, dynamic>? realTimeData;
  final Map<String, dynamic>? routeOptimization;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RouteModel({
    required this.id,
    required this.logisticsId,
    required this.routeName,
    required this.pickupIds,
    this.warehouseIds = const [],
    required this.stops,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.status,
    this.assignedDriverId,
    this.assignedDriverName,
    this.vehicleId,
    this.vehicleType,
    this.startTime,
    this.endTime,
    this.actualStartTime,
    this.actualEndTime,
    this.realTimeData,
    this.routeOptimization,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      logisticsId: json['logisticsId'],
      routeName: json['routeName'],
      pickupIds: List<String>.from(json['pickupIds'] ?? []),
      warehouseIds: json['warehouseIds'] != null 
          ? List<String>.from(json['warehouseIds'])
          : [],
      stops: (json['stops'] as List?)
          ?.map((stop) => RouteStop.fromJson(stop))
          .toList() ?? [],
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      status: RouteStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => RouteStatus.planned,
      ),
      assignedDriverId: json['assignedDriverId'],
      assignedDriverName: json['assignedDriverName'],
      vehicleId: json['vehicleId'],
      vehicleType: json['vehicleType'],
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : null,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : null,
      actualStartTime: json['actualStartTime'] != null 
          ? DateTime.parse(json['actualStartTime']) 
          : null,
      actualEndTime: json['actualEndTime'] != null 
          ? DateTime.parse(json['actualEndTime']) 
          : null,
      realTimeData: json['realTimeData'],
      routeOptimization: json['routeOptimization'],
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
      'logisticsId': logisticsId,
      'routeName': routeName,
      'pickupIds': pickupIds,
      'warehouseIds': warehouseIds,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'status': status.toString().split('.').last,
      'assignedDriverId': assignedDriverId,
      'assignedDriverName': assignedDriverName,
      'vehicleId': vehicleId,
      'vehicleType': vehicleType,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'actualStartTime': actualStartTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'realTimeData': realTimeData,
      'routeOptimization': routeOptimization,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? logisticsId,
    String? routeName,
    List<String>? pickupIds,
    List<String>? warehouseIds,
    List<RouteStop>? stops,
    double? totalDistance,
    int? estimatedDuration,
    RouteStatus? status,
    String? assignedDriverId,
    String? assignedDriverName,
    String? vehicleId,
    String? vehicleType,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    Map<String, dynamic>? realTimeData,
    Map<String, dynamic>? routeOptimization,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      logisticsId: logisticsId ?? this.logisticsId,
      routeName: routeName ?? this.routeName,
      pickupIds: pickupIds ?? this.pickupIds,
      warehouseIds: warehouseIds ?? this.warehouseIds,
      stops: stops ?? this.stops,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleType: vehicleType ?? this.vehicleType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      realTimeData: realTimeData ?? this.realTimeData,
      routeOptimization: routeOptimization ?? this.routeOptimization,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPlanned => status == RouteStatus.planned;
  bool get isInProgress => status == RouteStatus.inProgress;
  bool get isCompleted => status == RouteStatus.completed;
  bool get isCancelled => status == RouteStatus.cancelled;
  bool get isDelayed => status == RouteStatus.delayed;
  bool get isRerouted => status == RouteStatus.rerouted;
  bool get isAssigned => assignedDriverId != null;
  bool get isStarted => actualStartTime != null;
  bool get isFinished => actualEndTime != null;
  String get formattedDistance => '${totalDistance.toStringAsFixed(1)} km';
  String get formattedDuration => '${estimatedDuration} min';
  String get statusLabel => status.toString().split('.').last;
  Duration? get actualDuration => actualStartTime != null && actualEndTime != null 
      ? actualEndTime!.difference(actualStartTime!)
      : null;
  String get formattedActualDuration => actualDuration != null 
      ? '${actualDuration!.inHours}h ${actualDuration!.inMinutes % 60}m'
      : 'N/A';
  bool get isOnTime => actualDuration != null 
      ? actualDuration!.inMinutes <= estimatedDuration
      : true;
  bool get hasWarehouseStops => warehouseIds.isNotEmpty;
  bool get hasPickupStops => pickupIds.isNotEmpty;
}

class RouteStop {
  final String stopId;
  final String stopType; // 'pickup', 'warehouse', 'delivery'
  final String address;
  final double latitude;
  final double longitude;
  final int sequence;
  final DateTime? estimatedTime;
  final DateTime? actualTime;
  final String? contactPerson;
  final String? contactPhone;
  final Map<String, dynamic>? stopData;
  final String? notes;

  RouteStop({
    required this.stopId,
    required this.stopType,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.estimatedTime,
    this.actualTime,
    this.contactPerson,
    this.contactPhone,
    this.stopData,
    this.notes,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      stopId: json['stopId'],
      stopType: json['stopType'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      sequence: json['sequence'],
      estimatedTime: json['estimatedTime'] != null 
          ? DateTime.parse(json['estimatedTime']) 
          : null,
      actualTime: json['actualTime'] != null 
          ? DateTime.parse(json['actualTime']) 
          : null,
      contactPerson: json['contactPerson'],
      contactPhone: json['contactPhone'],
      stopData: json['stopData'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stopId': stopId,
      'stopType': stopType,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'estimatedTime': estimatedTime?.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'stopData': stopData,
      'notes': notes,
    };
  }

  bool get isPickup => stopType == 'pickup';
  bool get isWarehouse => stopType == 'warehouse';
  bool get isDelivery => stopType == 'delivery';
  bool get isCompleted => actualTime != null;
  bool get isOnTime => estimatedTime != null && actualTime != null 
      ? actualTime!.difference(estimatedTime!).inMinutes.abs() <= 15
      : true;
} 