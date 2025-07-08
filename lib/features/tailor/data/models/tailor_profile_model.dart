import 'package:flutter/material.dart';

enum TailorSkillLevel { beginner, intermediate, advanced, expert }
enum AvailabilityStatus { available, busy, unavailable, onLeave }

class TailorProfileModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? profileImage;
  final String? bio;
  final List<String> skills;
  final Map<String, TailorSkillLevel> skillLevels;
  final List<String> certifications;
  final List<String> specializations;
  final AvailabilityStatus availabilityStatus;
  final Map<String, bool> workingDays;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final double hourlyRate;
  final double rating;
  final int totalReviews;
  final int completedOrders;
  final int totalExperienceYears;
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  TailorProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImage,
    this.bio,
    required this.skills,
    required this.skillLevels,
    required this.certifications,
    required this.specializations,
    required this.availabilityStatus,
    required this.workingDays,
    this.startTime,
    this.endTime,
    required this.hourlyRate,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.completedOrders = 0,
    this.totalExperienceYears = 0,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory TailorProfileModel.fromJson(Map<String, dynamic> json) {
    return TailorProfileModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profile_image'],
      bio: json['bio'],
      skills: List<String>.from(json['skills'] ?? []),
      skillLevels: Map<String, TailorSkillLevel>.from(
        (json['skill_levels'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            TailorSkillLevel.values.firstWhere(
              (e) => e.toString().split('.').last == value,
              orElse: () => TailorSkillLevel.beginner,
            ),
          ),
        ),
      ),
      certifications: List<String>.from(json['certifications'] ?? []),
      specializations: List<String>.from(json['specializations'] ?? []),
      availabilityStatus: AvailabilityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['availability_status'],
        orElse: () => AvailabilityStatus.available,
      ),
      workingDays: Map<String, bool>.from(json['working_days'] ?? {}),
      startTime: json['start_time'] != null 
          ? _timeFromString(json['start_time']) 
          : null,
      endTime: json['end_time'] != null 
          ? _timeFromString(json['end_time']) 
          : null,
      hourlyRate: json['hourly_rate']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      completedOrders: json['completed_orders'] ?? 0,
      totalExperienceYears: json['total_experience_years'] ?? 0,
      shopName: json['shop_name'],
      shopAddress: json['shop_address'],
      shopPhone: json['shop_phone'],
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'bio': bio,
      'skills': skills,
      'skill_levels': skillLevels.map(
        (key, value) => MapEntry(key, value.toString().split('.').last),
      ),
      'certifications': certifications,
      'specializations': specializations,
      'availability_status': availabilityStatus.toString().split('.').last,
      'working_days': workingDays,
      'start_time': startTime != null ? _timeToString(startTime!) : null,
      'end_time': endTime != null ? _timeToString(endTime!) : null,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'total_reviews': totalReviews,
      'completed_orders': completedOrders,
      'total_experience_years': totalExperienceYears,
      'shop_name': shopName,
      'shop_address': shopAddress,
      'shop_phone': shopPhone,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  TailorProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? bio,
    List<String>? skills,
    Map<String, TailorSkillLevel>? skillLevels,
    List<String>? certifications,
    List<String>? specializations,
    AvailabilityStatus? availabilityStatus,
    Map<String, bool>? workingDays,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? hourlyRate,
    double? rating,
    int? totalReviews,
    int? completedOrders,
    int? totalExperienceYears,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TailorProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      skillLevels: skillLevels ?? this.skillLevels,
      certifications: certifications ?? this.certifications,
      specializations: specializations ?? this.specializations,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      workingDays: workingDays ?? this.workingDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      completedOrders: completedOrders ?? this.completedOrders,
      totalExperienceYears: totalExperienceYears ?? this.totalExperienceYears,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  static TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool get isAvailable => availabilityStatus == AvailabilityStatus.available;
  bool get isBusy => availabilityStatus == AvailabilityStatus.busy;
  bool get isUnavailable => availabilityStatus == AvailabilityStatus.unavailable;
  bool get isOnLeave => availabilityStatus == AvailabilityStatus.onLeave;

  String get availabilityStatusDisplayName {
    switch (availabilityStatus) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.busy:
        return 'Busy';
      case AvailabilityStatus.unavailable:
        return 'Unavailable';
      case AvailabilityStatus.onLeave:
        return 'On Leave';
    }
  }

  static String getSkillLevelDisplayName(TailorSkillLevel level) {
    switch (level) {
      case TailorSkillLevel.beginner:
        return 'Beginner';
      case TailorSkillLevel.intermediate:
        return 'Intermediate';
      case TailorSkillLevel.advanced:
        return 'Advanced';
      case TailorSkillLevel.expert:
        return 'Expert';
    }
  }

  double get averageRating => totalReviews > 0 ? rating / totalReviews : 0.0;
} 