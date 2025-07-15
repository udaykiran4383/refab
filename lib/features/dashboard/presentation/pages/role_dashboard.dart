import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../tailor/presentation/pages/tailor_dashboard.dart';
import '../../../logistics/presentation/pages/logistics_dashboard.dart';
import '../../../warehouse/presentation/pages/warehouse_dashboard.dart';
import '../../../customer/presentation/pages/customer_dashboard.dart';
import '../../../volunteer/presentation/pages/volunteer_dashboard.dart';
import '../../../admin/presentation/pages/admin_page.dart';

class RoleDashboard extends StatelessWidget {
  final UserModel user;

  const RoleDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    print('🎭 [ROLE_DASHBOARD] Building dashboard for user: ${user.name}');
    print('🎭 [ROLE_DASHBOARD] User role: ${user.role}');
    print('🎭 [ROLE_DASHBOARD] User details: ${user.toJson()}');

    switch (user.role) {
      case UserRole.tailor:
        print('🎭 [ROLE_DASHBOARD] ✅ Routing to TailorDashboard');
        return TailorDashboard(user: user);
      case UserRole.logistics:
        print('🎭 [ROLE_DASHBOARD] ✅ Routing to LogisticsDashboard');
        return LogisticsDashboard(user: user);
      case UserRole.warehouse:
        print('🎭 [ROLE_DASHBOARD] ✅ Routing to WarehouseDashboard');
        return const WarehouseDashboard();
      case UserRole.customer:
        print('🎭 [ROLE_DASHBOARD] ✅ Routing to CustomerDashboard');
        return CustomerDashboard(user: user);
      case UserRole.volunteer:
        print('🎭 [ROLE_DASHBOARD] ✅ Routing to VolunteerDashboard');
        return VolunteerDashboard(user: user);
      case UserRole.admin:
        print('🎭 [ROLE_DASHBOARD] ✅ Routing to AdminPage');
        return const AdminPage();
    }
  }
}
