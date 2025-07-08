class SystemConfigModel {
  final bool maintenanceMode;
  final String minAppVersion;
  final String apiBaseUrl;
  final String supportEmail;
  final String supportPhone;
  final double maxPickupWeight;
  final double minOrderAmount;
  final int volunteerCertificateHours;
  final int maxPickupRequests;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final Map<String, dynamic> customSettings;
  final DateTime updatedAt;

  SystemConfigModel({
    required this.maintenanceMode,
    required this.minAppVersion,
    required this.apiBaseUrl,
    required this.supportEmail,
    required this.supportPhone,
    required this.maxPickupWeight,
    required this.minOrderAmount,
    required this.volunteerCertificateHours,
    required this.maxPickupRequests,
    required this.enableAnalytics,
    required this.enableCrashlytics,
    required this.customSettings,
    required this.updatedAt,
  });

  factory SystemConfigModel.fromJson(Map<String, dynamic> json) {
    return SystemConfigModel(
      maintenanceMode: json['maintenanceMode'] ?? false,
      minAppVersion: json['minAppVersion'] ?? '1.0.0',
      apiBaseUrl: json['apiBaseUrl'] ?? 'https://your-api-url.com/api',
      supportEmail: json['supportEmail'] ?? 'support@refab.com',
      supportPhone: json['supportPhone'] ?? '+91-1234567890',
      maxPickupWeight: (json['maxPickupWeight'] ?? 1000.0).toDouble(),
      minOrderAmount: (json['minOrderAmount'] ?? 50.0).toDouble(),
      volunteerCertificateHours: json['volunteerCertificateHours'] ?? 50,
      maxPickupRequests: json['maxPickupRequests'] ?? 100,
      enableAnalytics: json['enableAnalytics'] ?? true,
      enableCrashlytics: json['enableCrashlytics'] ?? true,
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory SystemConfigModel.defaultConfig() {
    return SystemConfigModel(
      maintenanceMode: false,
      minAppVersion: '1.0.0',
      apiBaseUrl: 'https://your-api-url.com/api',
      supportEmail: 'support@refab.com',
      supportPhone: '+91-1234567890',
      maxPickupWeight: 1000.0,
      minOrderAmount: 50.0,
      volunteerCertificateHours: 50,
      maxPickupRequests: 100,
      enableAnalytics: true,
      enableCrashlytics: true,
      customSettings: {},
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenanceMode': maintenanceMode,
      'minAppVersion': minAppVersion,
      'apiBaseUrl': apiBaseUrl,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'maxPickupWeight': maxPickupWeight,
      'minOrderAmount': minOrderAmount,
      'volunteerCertificateHours': volunteerCertificateHours,
      'maxPickupRequests': maxPickupRequests,
      'enableAnalytics': enableAnalytics,
      'enableCrashlytics': enableCrashlytics,
      'customSettings': customSettings,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SystemConfigModel copyWith({
    bool? maintenanceMode,
    String? minAppVersion,
    String? apiBaseUrl,
    String? supportEmail,
    String? supportPhone,
    double? maxPickupWeight,
    double? minOrderAmount,
    int? volunteerCertificateHours,
    int? maxPickupRequests,
    bool? enableAnalytics,
    bool? enableCrashlytics,
    Map<String, dynamic>? customSettings,
    DateTime? updatedAt,
  }) {
    return SystemConfigModel(
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      maxPickupWeight: maxPickupWeight ?? this.maxPickupWeight,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      volunteerCertificateHours: volunteerCertificateHours ?? this.volunteerCertificateHours,
      maxPickupRequests: maxPickupRequests ?? this.maxPickupRequests,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashlytics: enableCrashlytics ?? this.enableCrashlytics,
      customSettings: customSettings ?? this.customSettings,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 