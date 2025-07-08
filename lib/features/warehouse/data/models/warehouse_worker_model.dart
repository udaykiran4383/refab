enum WorkerStatus { active, inactive, onLeave, terminated }
enum WorkerRole { supervisor, operator, qualityController, maintenance, general }

class WarehouseWorkerModel {
  final String id;
  final String warehouseId;
  final String name;
  final String email;
  final String phone;
  final WorkerRole role;
  final WorkerStatus status;
  final List<String> skills;
  final List<String> certifications;
  final DateTime hireDate;
  final DateTime? terminationDate;
  final Map<String, dynamic>? schedule;
  final Map<String, dynamic>? performanceMetrics;
  final String? supervisorId;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WarehouseWorkerModel({
    required this.id,
    required this.warehouseId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.skills,
    required this.certifications,
    required this.hireDate,
    this.terminationDate,
    this.schedule,
    this.performanceMetrics,
    this.supervisorId,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory WarehouseWorkerModel.fromJson(Map<String, dynamic> json) {
    return WarehouseWorkerModel(
      id: json['id'],
      warehouseId: json['warehouseId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: WorkerRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => WorkerRole.general,
      ),
      status: WorkerStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => WorkerStatus.active,
      ),
      skills: List<String>.from(json['skills'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      hireDate: DateTime.parse(json['hireDate']),
      terminationDate: json['terminationDate'] != null 
          ? DateTime.parse(json['terminationDate']) 
          : null,
      schedule: json['schedule'],
      performanceMetrics: json['performanceMetrics'],
      supervisorId: json['supervisorId'],
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
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'skills': skills,
      'certifications': certifications,
      'hireDate': hireDate.toIso8601String(),
      'terminationDate': terminationDate?.toIso8601String(),
      'schedule': schedule,
      'performanceMetrics': performanceMetrics,
      'supervisorId': supervisorId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  WarehouseWorkerModel copyWith({
    String? id,
    String? warehouseId,
    String? name,
    String? email,
    String? phone,
    WorkerRole? role,
    WorkerStatus? status,
    List<String>? skills,
    List<String>? certifications,
    DateTime? hireDate,
    DateTime? terminationDate,
    Map<String, dynamic>? schedule,
    Map<String, dynamic>? performanceMetrics,
    String? supervisorId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseWorkerModel(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      hireDate: hireDate ?? this.hireDate,
      terminationDate: terminationDate ?? this.terminationDate,
      schedule: schedule ?? this.schedule,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      supervisorId: supervisorId ?? this.supervisorId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == WorkerStatus.active;
  bool get isSupervisor => role == WorkerRole.supervisor;
  bool get isOperator => role == WorkerRole.operator;
  bool get isQualityController => role == WorkerRole.qualityController;
  bool get isMaintenance => role == WorkerRole.maintenance;
  String get roleLabel => role.toString().split('.').last;
  String get statusLabel => status.toString().split('.').last;
  int get yearsOfService => DateTime.now().difference(hireDate).inDays ~/ 365;
  bool hasSkill(String skill) => skills.contains(skill);
  bool hasCertification(String cert) => certifications.contains(cert);
} 