enum UserRole { tailor, logistics, warehouse, customer, volunteer, admin }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String? address;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.address,
    this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safely extract and validate required fields
      final id = json['id']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final name = json['name']?.toString() ?? '';
      final phone = json['phone']?.toString() ?? '';
      
      if (id.isEmpty || email.isEmpty || name.isEmpty) {
        print('❌ [UserModel] Missing required fields in JSON: $json');
        throw Exception('Missing required user fields');
      }

      // Safely parse role with fallback
      UserRole parsedRole = UserRole.customer;
      final roleStr = json['role']?.toString();
      print('🔍 [UserModel] Raw role from JSON: "$roleStr"');
      
      if (roleStr != null && roleStr.isNotEmpty) {
        try {
          // Try exact match first
          parsedRole = UserRole.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == roleStr.toLowerCase(),
            orElse: () {
              print('⚠️ [UserModel] Exact match failed for "$roleStr", trying partial match');
              return UserRole.customer;
            },
          );
          print('✅ [UserModel] Successfully parsed role from JSON: $parsedRole');
        } catch (e) {
          print('❌ [UserModel] Error parsing role: $e, trying fallback methods');
          
          // Try partial matching as fallback
          final lowerRoleStr = roleStr.toLowerCase();
          if (lowerRoleStr.contains('tailor')) {
            parsedRole = UserRole.tailor;
            print('✅ [UserModel] Fallback: Detected tailor role');
          } else if (lowerRoleStr.contains('admin')) {
            parsedRole = UserRole.admin;
            print('✅ [UserModel] Fallback: Detected admin role');
          } else if (lowerRoleStr.contains('logistics')) {
            parsedRole = UserRole.logistics;
            print('✅ [UserModel] Fallback: Detected logistics role');
          } else if (lowerRoleStr.contains('warehouse')) {
            parsedRole = UserRole.warehouse;
            print('✅ [UserModel] Fallback: Detected warehouse role');
          } else if (lowerRoleStr.contains('volunteer')) {
            parsedRole = UserRole.volunteer;
            print('✅ [UserModel] Fallback: Detected volunteer role');
          } else {
            print('⚠️ [UserModel] No role match found for "$roleStr", defaulting to customer');
            parsedRole = UserRole.customer;
          }
        }
      } else {
        print('⚠️ [UserModel] No role in JSON, defaulting to customer');
      }

      // Safely parse address
      final address = json['address']?.toString();

      // Safely parse isActive
      bool isActive = true;
      if (json['is_active'] != null) {
        if (json['is_active'] is bool) {
          isActive = json['is_active'] as bool;
        } else if (json['is_active'] is String) {
          isActive = json['is_active'].toString().toLowerCase() == 'true';
        } else if (json['is_active'] is int) {
          isActive = json['is_active'] as int != 0;
        }
      }

      // Safely parse createdAt
      DateTime createdAt;
      try {
        if (json['created_at'] is String) {
          createdAt = DateTime.parse(json['created_at'] as String);
        } else if (json['created_at'] is DateTime) {
          createdAt = json['created_at'] as DateTime;
        } else {
          createdAt = DateTime.now();
          print('⚠️ [UserModel] Invalid created_at format, using current time');
        }
      } catch (e) {
        print('❌ [UserModel] Error parsing created_at: $e, using current time');
        createdAt = DateTime.now();
      }

      final user = UserModel(
        id: id,
        email: email,
        name: name,
        phone: phone,
        role: parsedRole,
        address: address,
        isActive: isActive,
        createdAt: createdAt,
      );
      
      print('✅ [UserModel] Successfully created user: ${user.name} (${user.role})');
      return user;
    } catch (e) {
      print('❌ [UserModel] Critical error in fromJson: $e');
      print('❌ [UserModel] JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
