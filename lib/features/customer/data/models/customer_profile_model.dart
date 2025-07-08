import 'package:flutter/material.dart';

enum CustomerTier { bronze, silver, gold, platinum }
enum CustomerStatus { active, inactive, suspended, premium }

class CustomerProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? profileImage;
  final CustomerTier tier;
  final CustomerStatus status;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> preferences;
  final List<String> wishlist;
  final Map<String, dynamic> analytics;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? referralCode;
  final String? referredBy;
  final List<String> referralHistory;
  final Map<String, dynamic> socialLinks;
  final String? emergencyContact;
  final String? emergencyPhone;
  final Map<String, dynamic> customFields;

  CustomerProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.profileImage,
    this.tier = CustomerTier.bronze,
    this.status = CustomerStatus.active,
    this.dateOfBirth,
    this.gender,
    this.preferences = const [],
    this.wishlist = const [],
    this.analytics = const {},
    this.settings = const {},
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.referralCode,
    this.referredBy,
    this.referralHistory = const [],
    this.socialLinks = const {},
    this.emergencyContact,
    this.emergencyPhone,
    this.customFields = const {},
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      profileImage: json['profileImage'],
      tier: CustomerTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
        orElse: () => CustomerTier.bronze,
      ),
      status: CustomerStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CustomerStatus.active,
      ),
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      gender: json['gender'],
      preferences: List<String>.from(json['preferences'] ?? []),
      wishlist: List<String>.from(json['wishlist'] ?? []),
      analytics: Map<String, dynamic>.from(json['analytics'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      referralCode: json['referralCode'],
      referredBy: json['referredBy'],
      referralHistory: List<String>.from(json['referralHistory'] ?? []),
      socialLinks: Map<String, dynamic>.from(json['socialLinks'] ?? {}),
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'profileImage': profileImage,
      'tier': tier.toString().split('.').last,
      'status': status.toString().split('.').last,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'preferences': preferences,
      'wishlist': wishlist,
      'analytics': analytics,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'referralHistory': referralHistory,
      'socialLinks': socialLinks,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'customFields': customFields,
    };
  }

  CustomerProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? profileImage,
    CustomerTier? tier,
    CustomerStatus? status,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? preferences,
    List<String>? wishlist,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? referralCode,
    String? referredBy,
    List<String>? referralHistory,
    Map<String, dynamic>? socialLinks,
    String? emergencyContact,
    String? emergencyPhone,
    Map<String, dynamic>? customFields,
  }) {
    return CustomerProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      profileImage: profileImage ?? this.profileImage,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferences: preferences ?? this.preferences,
      wishlist: wishlist ?? this.wishlist,
      analytics: analytics ?? this.analytics,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      referralHistory: referralHistory ?? this.referralHistory,
      socialLinks: socialLinks ?? this.socialLinks,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      customFields: customFields ?? this.customFields,
    );
  }

  // Computed properties
  bool get isPremium => tier == CustomerTier.platinum || tier == CustomerTier.gold;
  bool get isActive => status == CustomerStatus.active;
  bool get isSuspended => status == CustomerStatus.suspended;
  bool get hasCompleteProfile => phone != null && address != null && city != null;
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get tierDisplayName {
    switch (tier) {
      case CustomerTier.bronze:
        return 'Bronze';
      case CustomerTier.silver:
        return 'Silver';
      case CustomerTier.gold:
        return 'Gold';
      case CustomerTier.platinum:
        return 'Platinum';
    }
  }

  Color get tierColor {
    switch (tier) {
      case CustomerTier.bronze:
        return Colors.brown;
      case CustomerTier.silver:
        return Colors.grey;
      case CustomerTier.gold:
        return Colors.amber;
      case CustomerTier.platinum:
        return Colors.blueGrey;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.suspended:
        return 'Suspended';
      case CustomerStatus.premium:
        return 'Premium';
    }
  }

  Color get statusColor {
    switch (status) {
      case CustomerStatus.active:
        return Colors.green;
      case CustomerStatus.inactive:
        return Colors.grey;
      case CustomerStatus.suspended:
        return Colors.red;
      case CustomerStatus.premium:
        return Colors.purple;
    }
  }

  // Analytics getters
  int get totalOrders => analytics['totalOrders'] ?? 0;
  double get totalSpent => (analytics['totalSpent'] ?? 0.0).toDouble();
  double get averageOrderValue => totalOrders > 0 ? totalSpent / totalOrders : 0.0;
  int get wishlistItems => wishlist.length;
  int get referralCount => referralHistory.length;
  DateTime? get lastOrderDate {
    final timestamp = analytics['lastOrderDate'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  // Settings getters
  bool get emailNotifications => settings['emailNotifications'] ?? true;
  bool get smsNotifications => settings['smsNotifications'] ?? false;
  bool get pushNotifications => settings['pushNotifications'] ?? true;
  String get language => settings['language'] ?? 'en';
  String get currency => settings['currency'] ?? 'INR';
  bool get darkMode => settings['darkMode'] ?? false;
} 