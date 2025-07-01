enum PickupStatus { pending, scheduled, inProgress, completed, cancelled }

class PickupRequestModel {
  final String id;
  final String tailorId;
  final String? logisticsId;
  final String fabricType;
  final double estimatedWeight;
  final String pickupAddress;
  final PickupStatus status;
  final List<String> photos;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final DateTime createdAt;

  PickupRequestModel({
    required this.id,
    required this.tailorId,
    this.logisticsId,
    required this.fabricType,
    required this.estimatedWeight,
    required this.pickupAddress,
    required this.status,
    required this.photos,
    this.scheduledDate,
    this.completedDate,
    required this.createdAt,
  });

  factory PickupRequestModel.fromJson(Map<String, dynamic> json) {
    return PickupRequestModel(
      id: json['id'],
      tailorId: json['tailor_id'],
      logisticsId: json['logistics_id'],
      fabricType: json['fabric_type'],
      estimatedWeight: json['estimated_weight'].toDouble(),
      pickupAddress: json['pickup_address'],
      status: PickupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      photos: List<String>.from(json['photos'] ?? []),
      scheduledDate: json['scheduled_date'] != null 
          ? DateTime.parse(json['scheduled_date']) 
          : null,
      completedDate: json['completed_date'] != null 
          ? DateTime.parse(json['completed_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tailor_id': tailorId,
      'logistics_id': logisticsId,
      'fabric_type': fabricType,
      'estimated_weight': estimatedWeight,
      'pickup_address': pickupAddress,
      'status': status.toString().split('.').last,
      'photos': photos,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
