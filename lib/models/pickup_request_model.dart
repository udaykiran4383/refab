enum PickupStatus { pending, completed }

class PickupRequestModel {
  final String id;
  final String tailorId;
  final String fabricType;
  final double weight;
  final String address;
  final List<String> photos;
  final PickupStatus status;
  final DateTime createdAt;

  PickupRequestModel({
    required this.id,
    required this.tailorId,
    required this.fabricType,
    required this.weight,
    required this.address,
    required this.photos,
    required this.status,
    required this.createdAt,
  });

  factory PickupRequestModel.fromJson(Map<String, dynamic> json) {
    return PickupRequestModel(
      id: json['id'],
      tailorId: json['tailorId'],
      fabricType: json['fabricType'],
      weight: json['weight'].toDouble(),
      address: json['address'],
      photos: List<String>.from(json['photos'] ?? []),
      status: PickupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tailorId': tailorId,
      'fabricType': fabricType,
      'weight': weight,
      'address': address,
      'photos': photos,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
