import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/analytics_model.dart';
import '../models/system_config_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Management
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deactivateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to activate user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Analytics
  Future<AnalyticsModel> getSystemAnalytics() async {
    try {
      final users = await _firestore.collection('users').get();
      final pickupRequests = await _firestore.collection('pickupRequests').get();
      final products = await _firestore.collection('products').get();
      final orders = await _firestore.collection('orders').get();

      final totalUsers = users.docs.length;
      final activeUsers = users.docs.where((doc) => doc.data()['isActive'] == true).length;
      final totalPickupRequests = pickupRequests.docs.length;
      final completedPickups = pickupRequests.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final totalProducts = products.docs.length;
      final totalOrders = orders.docs.length;
      final totalRevenue = orders.docs
          .where((doc) => doc.data()['status'] == 'delivered')
          .fold<double>(0, (sum, doc) => sum + (doc.data()['totalAmount'] ?? 0));

      // Role distribution
      final roleDistribution = <String, int>{};
      for (final doc in users.docs) {
        final role = doc.data()['role'] ?? 'unknown';
        roleDistribution[role] = (roleDistribution[role] ?? 0) + 1;
      }

      // Monthly trends
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      final thisMonthPickups = pickupRequests.docs
          .where((doc) {
            final createdAt = DateTime.parse(doc.data()['createdAt']);
            return createdAt.isAfter(thisMonth);
          })
          .length;

      final lastMonthPickups = pickupRequests.docs
          .where((doc) {
            final createdAt = DateTime.parse(doc.data()['createdAt']);
            return createdAt.isAfter(lastMonth) && createdAt.isBefore(thisMonth);
          })
          .length;

      return AnalyticsModel(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        totalPickupRequests: totalPickupRequests,
        completedPickups: completedPickups,
        totalProducts: totalProducts,
        totalOrders: totalOrders,
        totalRevenue: totalRevenue,
        roleDistribution: roleDistribution,
        thisMonthPickups: thisMonthPickups,
        lastMonthPickups: lastMonthPickups,
        pickupGrowthRate: lastMonthPickups > 0 
            ? ((thisMonthPickups - lastMonthPickups) / lastMonthPickups) * 100 
            : 0,
      );
    } catch (e) {
      throw Exception('Failed to get system analytics: $e');
    }
  }

  // System Configuration
  Future<SystemConfigModel> getSystemConfig() async {
    try {
      final doc = await _firestore.collection('systemConfig').doc('main').get();
      if (doc.exists) {
        return SystemConfigModel.fromJson(doc.data()!);
      }
      return SystemConfigModel.defaultConfig();
    } catch (e) {
      throw Exception('Failed to get system config: $e');
    }
  }

  Future<void> updateSystemConfig(SystemConfigModel config) async {
    try {
      await _firestore.collection('systemConfig').doc('main').set(config.toJson());
    } catch (e) {
      throw Exception('Failed to update system config: $e');
    }
  }

  // Notifications
  Future<void> sendSystemNotification({
    required String title,
    required String message,
    required List<String> targetRoles,
    String? targetUserId,
  }) async {
    try {
      final notificationData = {
        'title': title,
        'message': message,
        'type': 'system',
        'targetRoles': targetRoles,
        'targetUserId': targetUserId,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (targetUserId != null) {
        // Send to specific user
        await _firestore.collection('notifications').add(notificationData);
      } else {
        // Send to all users with target roles
        final users = await _firestore
            .collection('users')
            .where('role', whereIn: targetRoles)
            .get();

        final batch = _firestore.batch();
        for (final user in users.docs) {
          final notificationRef = _firestore.collection('notifications').doc();
          batch.set(notificationRef, {
            ...notificationData,
            'userId': user.id,
          });
        }
        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to send system notification: $e');
    }
  }

  // Reports
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      switch (reportType) {
        case 'pickup_requests':
          return await _generatePickupReport(startDate, endDate);
        case 'orders':
          return await _generateOrderReport(startDate, endDate);
        case 'users':
          return await _generateUserReport(startDate, endDate);
        default:
          throw Exception('Unknown report type: $reportType');
      }
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  Future<Map<String, dynamic>> _generatePickupReport(DateTime startDate, DateTime endDate) async {
    final pickupRequests = await _firestore
        .collection('pickupRequests')
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final totalRequests = pickupRequests.docs.length;
    final completedRequests = pickupRequests.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .length;
    final totalWeight = pickupRequests.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .fold<double>(0, (sum, doc) => sum + (doc.data()['estimatedWeight'] ?? 0));

    return {
      'reportType': 'pickup_requests',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalRequests': totalRequests,
      'completedRequests': completedRequests,
      'totalWeight': totalWeight,
      'completionRate': totalRequests > 0 ? (completedRequests / totalRequests) * 100 : 0,
    };
  }

  Future<Map<String, dynamic>> _generateOrderReport(DateTime startDate, DateTime endDate) async {
    final orders = await _firestore
        .collection('orders')
        .where('orderDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('orderDate', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final totalOrders = orders.docs.length;
    final deliveredOrders = orders.docs
        .where((doc) => doc.data()['status'] == 'delivered')
        .length;
    final totalRevenue = orders.docs
        .where((doc) => doc.data()['status'] == 'delivered')
        .fold<double>(0, (sum, doc) => sum + (doc.data()['totalAmount'] ?? 0));

    return {
      'reportType': 'orders',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalOrders': totalOrders,
      'deliveredOrders': deliveredOrders,
      'totalRevenue': totalRevenue,
      'deliveryRate': totalOrders > 0 ? (deliveredOrders / totalOrders) * 100 : 0,
    };
  }

  Future<Map<String, dynamic>> _generateUserReport(DateTime startDate, DateTime endDate) async {
    final users = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    final totalUsers = users.docs.length;
    final activeUsers = users.docs.where((doc) => doc.data()['isActive'] == true).length;

    final roleDistribution = <String, int>{};
    for (final doc in users.docs) {
      final role = doc.data()['role'] ?? 'unknown';
      roleDistribution[role] = (roleDistribution[role] ?? 0) + 1;
    }

    return {
      'reportType': 'users',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'roleDistribution': roleDistribution,
      'activationRate': totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0,
    };
  }
} 