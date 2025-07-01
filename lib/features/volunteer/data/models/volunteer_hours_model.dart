class VolunteerHoursModel {
  final String id;
  final String volunteerId;
  final String taskCategory;
  final double hoursLogged;
  final String description;
  final String? supervisorId;
  final bool isVerified;
  final String? verificationNotes;
  final DateTime? verifiedAt;
  final DateTime logDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VolunteerHoursModel({
    required this.id,
    required this.volunteerId,
    required this.taskCategory,
    required this.hoursLogged,
    required this.description,
    this.supervisorId,
    required this.isVerified,
    this.verificationNotes,
    this.verifiedAt,
    required this.logDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory VolunteerHoursModel.fromJson(Map<String, dynamic> json) {
    return VolunteerHoursModel(
      id: json['id'],
      volunteerId: json['volunteerId'],
      taskCategory: json['taskCategory'],
      hoursLogged: json['hoursLogged'].toDouble(),
      description: json['description'],
      supervisorId: json['supervisorId'],
      isVerified: json['isVerified'] ?? false,
      verificationNotes: json['verificationNotes'],
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      logDate: DateTime.parse(json['logDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'taskCategory': taskCategory,
      'hoursLogged': hoursLogged,
      'description': description,
      'supervisorId': supervisorId,
      'isVerified': isVerified,
      'verificationNotes': verificationNotes,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'logDate': logDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  VolunteerHoursModel copyWith({
    String? id,
    String? volunteerId,
    String? taskCategory,
    double? hoursLogged,
    String? description,
    String? supervisorId,
    bool? isVerified,
    String? verificationNotes,
    DateTime? verifiedAt,
    DateTime? logDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VolunteerHoursModel(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      taskCategory: taskCategory ?? this.taskCategory,
      hoursLogged: hoursLogged ?? this.hoursLogged,
      description: description ?? this.description,
      supervisorId: supervisorId ?? this.supervisorId,
      isVerified: isVerified ?? this.isVerified,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      logDate: logDate ?? this.logDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedHours => '${hoursLogged.toStringAsFixed(1)} hours';
  String get formattedDate => '${logDate.day}/${logDate.month}/${logDate.year}';
  bool get isPendingVerification => !isVerified;
} 