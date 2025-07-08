import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/user_management_card.dart';
import '../../../customer/presentation/pages/profile_page.dart';
import '../../pages/admin_page.dart';
import 'comprehensive_admin_dashboard.dart';

class AdminDashboard extends ConsumerWidget {
  final UserModel user;

  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComprehensiveAdminDashboard(user: user);
  }
}
