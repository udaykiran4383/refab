import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/analytics_model.dart';
import '../models/system_config_model.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';

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

  // Enhanced Notification Management
  Stream<List<NotificationModel>> getAllNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<NotificationModel>> getNotificationsByType(String type) {
    return _firestore
        .collection('notifications')
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Enhanced Report Management
  Future<List<ReportModel>> getAllReports() async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('generatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  Future<List<ReportModel>> getReportsByType(String reportType) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('reportType', isEqualTo: reportType)
          .orderBy('generatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports by type: $e');
    }
  }

  Future<void> saveReport(ReportModel report) async {
    try {
      await _firestore.collection('reports').doc(report.id).set(report.toJson());
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Product Management
  Stream<List<Map<String, dynamic>>> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('products').add({
        ...productData,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Order Management
  Stream<List<Map<String, dynamic>>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Pickup Request Management
  Stream<List<Map<String, dynamic>>> getAllPickupRequests() {
    print('🔥 [ADMIN_REPO] Getting all pickup requests...');
    return _firestore
        .collection('pickupRequests')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔥 [ADMIN_REPO] Found ${snapshot.docs.length} pickup requests');
          final requests = snapshot.docs.map((doc) {
            try {
              final data = {
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              };
              print('🔥 [ADMIN_REPO] Processing request: ${doc.id}');
              print('🔥 [ADMIN_REPO]   - Customer: ${data['customer_name']}');
              print('🔥 [ADMIN_REPO]   - Fabric: ${data['fabric_type']}');
              print('🔥 [ADMIN_REPO]   - Status: ${data['status']}');
              print('🔥 [ADMIN_REPO]   - Address: ${data['pickup_address']}');
              print('🔥 [ADMIN_REPO]   - Tailor ID: ${data['tailor_id']}');
              
              // Check for field name inconsistencies
              final rawData = doc.data();
              if (rawData.containsKey('customerName') || rawData.containsKey('pickupAddress') || rawData.containsKey('tailorId')) {
                print('🔥 [ADMIN_REPO] ⚠️ Found camelCase fields in request ${doc.id}');
                print('🔥 [ADMIN_REPO] Raw fields: ${rawData.keys.toList()}');
              }
              
              return data;
            } catch (e) {
              print('🔥 [ADMIN_REPO] ❌ Error processing request ${doc.id}: $e');
              print('🔥 [ADMIN_REPO] Raw data: ${doc.data()}');
              return {
                'id': doc.id,
                'error': 'Failed to parse data',
                ...doc.data(),
              };
            }
          }).toList();
          print('🔥 [ADMIN_REPO] ✅ Successfully processed ${requests.length} pickup requests');
          return requests;
        });
  }

  Future<void> updatePickupStatus(String pickupId, String status) async {
    try {
      print('🔥 [ADMIN_REPO] Updating pickup status: $pickupId to $status');
      await _firestore.collection('pickupRequests').doc(pickupId).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('🔥 [ADMIN_REPO] ✅ Pickup status updated successfully');
    } catch (e) {
      print('🔥 [ADMIN_REPO] ❌ Error updating pickup status: $e');
      throw Exception('Failed to update pickup status: $e');
    }
  }

  Future<void> assignPickupToVolunteer(String pickupId, String volunteerId) async {
    try {
      await _firestore.collection('pickupRequests').doc(pickupId).update({
        'assigned_volunteer_id': volunteerId,
        'status': 'assigned',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to assign pickup: $e');
    }
  }

  // System Health Monitoring
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      final users = await _firestore.collection('users').get();
      final pickupRequests = await _firestore.collection('pickupRequests').get();
      final orders = await _firestore.collection('orders').get();
      final products = await _firestore.collection('products').get();

      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));

      final recentUsers = users.docs
          .where((doc) => DateTime.parse(doc.data()['createdAt']).isAfter(last24Hours))
          .length;

      final recentPickups = pickupRequests.docs
          .where((doc) => DateTime.parse(doc.data()['createdAt']).isAfter(last24Hours))
          .length;

      final recentOrders = orders.docs
          .where((doc) => DateTime.parse(doc.data()['orderDate']).isAfter(last24Hours))
          .length;

      final pendingPickups = pickupRequests.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      final pendingOrders = orders.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;

      return {
        'totalUsers': users.docs.length,
        'totalPickupRequests': pickupRequests.docs.length,
        'totalOrders': orders.docs.length,
        'totalProducts': products.docs.length,
        'recentUsers': recentUsers,
        'recentPickups': recentPickups,
        'recentOrders': recentOrders,
        'pendingPickups': pendingPickups,
        'pendingOrders': pendingOrders,
        'systemStatus': 'healthy',
        'lastUpdated': now.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get system health: $e');
    }
  }

  // Backup and Maintenance
  Future<void> createSystemBackup() async {
    try {
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'system_backup',
        'collections': ['users', 'pickupRequests', 'orders', 'products', 'notifications'],
      };

      await _firestore.collection('systemBackups').add(backupData);
    } catch (e) {
      throw Exception('Failed to create system backup: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSystemBackups() async {
    try {
      final snapshot = await _firestore
          .collection('systemBackups')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get system backups: $e');
    }
  }
} 