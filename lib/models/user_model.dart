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
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      address: json['address'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
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
}
