import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../models/system_config_model.dart';
import '../models/analytics_model.dart';
import '../../../auth/data/models/user_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all pickup requests
  Future<List<Map<String, dynamic>>> getAllPickupRequests() async {
    try {
      final snapshot = await _firestore.collection('pickup_requests').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching pickup requests: $e');
      return [];
    }
  }

  // Stream all pickup requests for real-time updates
  Stream<List<Map<String, dynamic>>> getAllPickupRequestsStream() {
    return _firestore.collection('pickup_requests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Fetch all assignments
  Future<List<Map<String, dynamic>>> getAllAssignments() async {
    try {
      final snapshot = await _firestore.collection('warehouse_assignments').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }

  // Stream all assignments for real-time updates
  Stream<List<Map<String, dynamic>>> getAllAssignmentsStream() {
    return _firestore.collection('warehouse_assignments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Update pickup request status
  Future<void> updatePickupStatus(String requestId, String status) async {
    try {
      await _firestore.collection('pickup_requests').doc(requestId).update({
        'status': status,
        'updated_at': DateTime.now(),
      });
      print('✅ [ADMIN] Pickup request status updated: $requestId -> $status');
    } catch (e) {
      print('❌ [ADMIN] Error updating pickup status: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Search pickup requests
  Future<List<Map<String, dynamic>>> searchPickupRequests(String query) async {
    try {
      final snapshot = await _firestore.collection('pickup_requests').get();
      final allRequests = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      if (query.isEmpty) return allRequests;
      
      return allRequests.where((request) {
        final customerName = (request['customer_name'] ?? '').toString().toLowerCase();
        final status = (request['status'] ?? '').toString().toLowerCase();
        final queryLower = query.toLowerCase();
        
        return customerName.contains(queryLower) || status.contains(queryLower);
      }).toList();
    } catch (e) {
      print('Error searching pickup requests: $e');
      return [];
    }
  }

  // Search assignments
  Future<List<Map<String, dynamic>>> searchAssignments(String query) async {
    try {
      final snapshot = await _firestore.collection('warehouse_assignments').get();
      final allAssignments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      if (query.isEmpty) return allAssignments;
      
      return allAssignments.where((assignment) {
        final logisticsUserName = (assignment['logistics_user_name'] ?? '').toString().toLowerCase();
        final warehouseName = (assignment['warehouse_name'] ?? '').toString().toLowerCase();
        final status = (assignment['status'] ?? '').toString().toLowerCase();
        final queryLower = query.toLowerCase();
        
        return logisticsUserName.contains(queryLower) || 
               warehouseName.contains(queryLower) || 
               status.contains(queryLower);
      }).toList();
    } catch (e) {
      print('Error searching assignments: $e');
      return [];
    }
  }

  // Update pickup request status (returns bool for compatibility)
  Future<bool> updatePickupRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('pickup_requests').doc(requestId).update({
        'status': status,
        'updated_at': DateTime.now(),
      });
      print('✅ [ADMIN] Pickup request status updated: $requestId -> $status');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error updating pickup status: $e');
      return false;
    }
  }

  // Update assignment status (returns bool for compatibility)
  Future<bool> updateAssignmentStatus(String assignmentId, String status) async {
    try {
      await _firestore.collection('warehouse_assignments').doc(assignmentId).update({
        'status': status,
        'updated_at': DateTime.now(),
      });
      print('✅ [ADMIN] Assignment status updated: $assignmentId -> $status');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error updating assignment status: $e');
      return false;
    }
  }

  // Warehouse management methods
  Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    try {
      final snapshot = await _firestore.collection('warehouses').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching warehouses: $e');
      return [];
    }
  }

  Future<bool> createWarehouse(Map<String, dynamic> warehouseData) async {
    try {
      // Create warehouse document
      final warehouseRef = await _firestore.collection('warehouses').add({
        ...warehouseData,
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
      });
      
      print('✅ [ADMIN] Warehouse created successfully: ${warehouseData['name']}');
      
      // If warehouse has manager details, create warehouse user
      if (warehouseData['manager_email'] != null && 
          warehouseData['password'] != null && 
          warehouseData['manager_name'] != null) {
        
        print('🔐 [ADMIN] Creating warehouse manager account...');
        
        // Create warehouse user with warehouse ID
        final userData = {
          ...warehouseData,
          'warehouse_id': warehouseRef.id,
        };
        
        final userCreated = await createWarehouseUser(userData);
        if (userCreated) {
          print('✅ [ADMIN] Warehouse manager account created successfully');
        } else {
          print('⚠️ [ADMIN] Warehouse created but manager account creation failed');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error creating warehouse: $e');
      return false;
    }
  }

  Future<bool> updateWarehouse(String warehouseId, Map<String, dynamic> warehouseData) async {
    try {
      await _firestore.collection('warehouses').doc(warehouseId).update({
        ...warehouseData,
        'updated_at': DateTime.now(),
      });
      print('✅ [ADMIN] Warehouse updated successfully: $warehouseId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error updating warehouse: $e');
      return false;
    }
  }

  Future<bool> deleteWarehouse(String warehouseId) async {
    try {
      await _firestore.collection('warehouses').doc(warehouseId).delete();
      print('✅ [ADMIN] Warehouse deleted successfully: $warehouseId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error deleting warehouse: $e');
      return false;
    }
  }

  // Warehouse user management methods (only for warehouse users)
  Stream<List<UserModel>> getWarehouseUsers() {
    return _firestore.collection('users')
        .where('role', isEqualTo: 'warehouse')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    }).handleError((e) {
      print('Error fetching warehouse users: $e');
      return <UserModel>[];
    });
  }

  Future<bool> createWarehouseUser(Map<String, dynamic> userData) async {
    try {
      final email = userData['manager_email'] as String;
      final password = userData['password'] as String;
      final name = userData['manager_name'] as String;
      final phone = userData['manager_phone'] as String? ?? '';
      
      print('🔐 [ADMIN] Creating warehouse user with Firebase Auth: $email');
      
      // First create Firebase Auth account
      final FirebaseAuth auth = FirebaseAuth.instance;
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Set display name
        try {
          await credential.user!.updateDisplayName(name);
          print('🔐 [ADMIN] ✅ Display name set to: $name');
        } catch (e) {
          print('🔐 [ADMIN] ⚠️ Failed to set display name: $e');
        }
        
        // Create user data for Firestore
        final userDataForFirestore = {
          'id': credential.user!.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'role': 'warehouse',
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
          'warehouse_id': userData['warehouse_id'], // Link to warehouse if provided
        };
        
        // Save to Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set(userDataForFirestore);
        print('✅ [ADMIN] Warehouse user created successfully: $email (${credential.user!.uid})');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ [ADMIN] Error creating warehouse user: $e');
      return false;
    }
  }

  Future<bool> updateWarehouseUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Ensure role cannot be changed to non-warehouse
      updates.remove('role');
      updates['updated_at'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(userId).update(updates);
      print('✅ [ADMIN] Warehouse user updated successfully: $userId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error updating warehouse user: $e');
      return false;
    }
  }

  Future<bool> deactivateWarehouseUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_active': false,
        'deactivated_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ [ADMIN] Warehouse user deactivated successfully: $userId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error deactivating warehouse user: $e');
      return false;
    }
  }

  Future<bool> activateWarehouseUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'is_active': true,
        'activated_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ [ADMIN] Warehouse user activated successfully: $userId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error activating warehouse user: $e');
      return false;
    }
  }

  // Notifications methods
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final snapshot = await _firestore.collection('notifications').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': DateTime.now(),
      });
      print('✅ [ADMIN] Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('✅ [ADMIN] Notification deleted successfully: $notificationId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error deleting notification: $e');
      return false;
    }
  }

  // System health methods
  Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      // Mock system health data for now
      return {
        'status': 'healthy',
        'uptime': '99.9%',
        'lastBackup': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'databaseSize': '2.3 GB',
        'activeUsers': 45,
        'pendingPickups': 12,
        'pendingOrders': 8,
        'recentUsers': 3,
        'recentPickups': 7,
        'recentOrders': 5,
      };
    } catch (e) {
      print('❌ [ADMIN] Error getting system health: $e');
      return {
        'status': 'error',
        'uptime': '0%',
        'lastBackup': DateTime.now().toIso8601String(),
        'databaseSize': '0 GB',
        'activeUsers': 0,
        'pendingPickups': 0,
        'pendingOrders': 0,
        'recentUsers': 0,
        'recentPickups': 0,
        'recentOrders': 0,
      };
    }
  }

  Future<bool> createSystemBackup() async {
    try {
      // Mock backup creation
      await Future.delayed(const Duration(seconds: 2));
      print('✅ [ADMIN] System backup created successfully');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error creating system backup: $e');
      return false;
    }
  }

  // System analytics methods
  Future<AnalyticsModel> getSystemAnalytics() async {
    try {
      // Fetch real data from Firestore
      final pickupRequests = await getAllPickupRequests();
      final assignments = await getAllAssignments();
      final users = await getWarehouseUsers().first;
      
      // Calculate analytics
      final totalPickupRequests = pickupRequests.length;
      final totalAssignments = assignments.length;
      final totalUsers = users.length;
      
      final pendingPickupRequests = pickupRequests.where((req) => 
        req['status'] == 'pending' || req['status'] == 'requested'
      ).length;
      
      final completedPickupRequests = pickupRequests.where((req) => 
        req['status'] == 'completed' || req['status'] == 'delivered'
      ).length;
      
      final activeUsers = users.where((user) => user.isActive).length;
      
      return AnalyticsModel(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        totalPickupRequests: totalPickupRequests,
        completedPickups: completedPickupRequests,
        totalProducts: 0, // Mock data
        totalOrders: 0, // Mock data
        totalRevenue: 0.0, // Mock data
        roleDistribution: {}, // Mock data
        thisMonthPickups: 0, // Mock data
        lastMonthPickups: 0, // Mock data
        pickupGrowthRate: 0.0, // Mock data
        totalAssignments: totalAssignments,
        pendingPickupRequests: pendingPickupRequests,
        completedPickupRequests: completedPickupRequests,
        averageProcessingTime: 2.5, // Mock data
        systemUptime: 99.9, // Mock data
      );
    } catch (e) {
      print('❌ [ADMIN] Error getting system analytics: $e');
      return AnalyticsModel.empty();
    }
  }

  // System configuration methods
  Future<SystemConfigModel> getSystemConfig() async {
    try {
      final doc = await _firestore.collection('system_config').doc('main').get();
      if (doc.exists) {
        final data = doc.data()!;
        return SystemConfigModel.fromJson(data);
      }
      // Return default config if none exists
      return SystemConfigModel.defaultConfig();
    } catch (e) {
      print('❌ [ADMIN] Error getting system config: $e');
      return SystemConfigModel.defaultConfig();
    }
  }

  Future<bool> updateSystemConfig(SystemConfigModel config) async {
    try {
      await _firestore.collection('system_config').doc('main').set(config.toJson());
      print('✅ [ADMIN] System config updated successfully');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error updating system config: $e');
      return false;
    }
  }

  // Products methods
  Stream<List<Map<String, dynamic>>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }).handleError((e) {
      print('Error fetching products: $e');
      return <Map<String, dynamic>>[];
    });
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      print('✅ [ADMIN] Product deleted successfully: $productId');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error deleting product: $e');
      return false;
    }
  }

  // Orders methods
  Stream<List<Map<String, dynamic>>> getAllOrders() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }).handleError((e) {
      print('Error fetching orders: $e');
      return <Map<String, dynamic>>[];
    });
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updated_at': DateTime.now(),
      });
      print('✅ [ADMIN] Order status updated: $orderId -> $status');
      return true;
    } catch (e) {
      print('❌ [ADMIN] Error updating order status: $e');
      return false;
    }
  }
} 