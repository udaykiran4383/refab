enum RouteStatus { planned, inProgress, completed, cancelled }

class RouteModel {
  final String id;
  final String logisticsId;
  final String routeName;
  final List<String> pickupIds;
  final List<RouteStop> stops;
  final double totalDistance;
  final int estimatedDuration;
  final RouteStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RouteModel({
    required this.id,
    required this.logisticsId,
    required this.routeName,
    required this.pickupIds,
    required this.stops,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.status,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      logisticsId: json['logisticsId'],
      routeName: json['routeName'],
      pickupIds: List<String>.from(json['pickupIds'] ?? []),
      stops: (json['stops'] as List)
          .map((stop) => RouteStop.fromJson(stop))
          .toList(),
      totalDistance: (json['totalDistance'] ?? 0).toDouble(),
      estimatedDuration: json['estimatedDuration'] ?? 0,
      status: RouteStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : null,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
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
      'logisticsId': logisticsId,
      'routeName': routeName,
      'pickupIds': pickupIds,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'status': status.toString().split('.').last,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? logisticsId,
    String? routeName,
    List<String>? pickupIds,
    List<RouteStop>? stops,
    double? totalDistance,
    int? estimatedDuration,
    RouteStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      logisticsId: logisticsId ?? this.logisticsId,
      routeName: routeName ?? this.routeName,
      pickupIds: pickupIds ?? this.pickupIds,
      stops: stops ?? this.stops,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPlanned => status == RouteStatus.planned;
  bool get isInProgress => status == RouteStatus.inProgress;
  bool get isCompleted => status == RouteStatus.completed;
  bool get isCancelled => status == RouteStatus.cancelled;
  String get formattedDistance => '${totalDistance.toStringAsFixed(1)} km';
  String get formattedDuration => '${estimatedDuration} min';
}

class RouteStop {
  final String pickupId;
  final String address;
  final double latitude;
  final double longitude;
  final int sequence;
  final DateTime? estimatedTime;
  final DateTime? actualTime;

  RouteStop({
    required this.pickupId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.estimatedTime,
    this.actualTime,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      pickupId: json['pickupId'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickupId': pickupId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'estimatedTime': estimatedTime?.toIso8601String(),
      'actualTime': actualTime?.toIso8601String(),
    };
  }
} 