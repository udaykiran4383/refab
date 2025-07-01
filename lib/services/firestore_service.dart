import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/data/models/user_model.dart';
import '../models/pickup_request_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  static Future<void> createUser(UserModel user) async {
    print('🔥 [FIRESTORE] Creating user: \\${user.name} (\\${user.email})');
    try {
      await _db.collection('users').doc(user.id).set(user.toJson());
      print('🔥 [FIRESTORE] ✅ User created successfully in Firestore');
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error creating user: $e');
      throw e;
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    print('🔥 [FIRESTORE] Fetching user with ID: $userId');
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final user = UserModel.fromJson(doc.data()!);
        print('🔥 [FIRESTORE] ✅ User found: \\${user.name} (\\${user.email})');
        return user;
      } else {
        print('🔥 [FIRESTORE] ⚠️ User document does not exist for ID: $userId');
        return null;
      }
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error fetching user: $e');
      throw e;
    }
  }

  static Future<void> deleteUser(String userId) async {
    print('🔥 [FIRESTORE] Deleting user with ID: $userId');
    try {
      await _db.collection('users').doc(userId).delete();
      print('🔥 [FIRESTORE] ✅ User deleted successfully from Firestore');
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error deleting user: $e');
      throw e;
    }
  }

  // Development cleanup method - use with caution!
  static Future<void> deleteAllUsers() async {
    print('🔥 [FIRESTORE] Deleting all users...');
    try {
      final users = await _db.collection('users').get();
      print('🔥 [FIRESTORE] Found ${users.docs.length} users to delete');
      
      final batch = _db.batch();
      
      for (var doc in users.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('🔥 [FIRESTORE] ✅ All users deleted successfully');
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error deleting all users: $e');
      throw e;
    }
  }

  // Comprehensive cleanup - deletes from both Firestore and Auth
  static Future<void> cleanupAllUsers() async {
    print('🧹 [CLEANUP] Starting comprehensive user cleanup...');
    try {
      // First, get all users from Firestore
      final users = await _db.collection('users').get();
      print('🧹 [CLEANUP] Found ${users.docs.length} users in Firestore');
      
      // Delete from Firestore
      if (users.docs.isNotEmpty) {
        final batch = _db.batch();
        for (var doc in users.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🧹 [CLEANUP] ✅ All users deleted from Firestore');
      }
      
      // Note: Firebase Auth users need to be deleted manually from console
      // or through the Auth SDK (which requires user authentication)
      print('🧹 [CLEANUP] ⚠️ Firebase Auth users must be deleted manually from console');
      print('🧹 [CLEANUP] Go to: Firebase Console → Authentication → Users');
      
    } catch (e) {
      print('🧹 [CLEANUP] ❌ Error during cleanup: $e');
      throw e;
    }
  }

  // Pickup Requests
  static Future<String> createPickupRequest(PickupRequestModel request) async {
    final docRef = await _db.collection('pickupRequests').add(request.toJson());
    return docRef.id;
  }

  static Stream<List<PickupRequestModel>> getPickupRequests(String tailorId) {
    return _db
        .collection('pickupRequests')
        .where('tailorId', isEqualTo: tailorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupRequestModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  static Stream<List<PickupRequestModel>> getAllPickupRequests() {
    return _db
        .collection('pickupRequests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupRequestModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  static Future<void> updatePickupStatus(String requestId, PickupStatus status) async {
    await _db.collection('pickupRequests').doc(requestId).update({
      'status': status.toString().split('.').last,
    });
  }

  // Products
  static Future<String> createProduct(ProductModel product) async {
    final docRef = await _db.collection('products').add(product.toJson());
    return docRef.id;
  }

  static Stream<List<ProductModel>> getProducts() {
    return _db
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    final pickupRequests = await _db.collection('pickupRequests').get();
    final products = await _db.collection('products').get();
    final users = await _db.collection('users').get();

    final completedPickups = pickupRequests.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .length;

    final totalWasteRecycled = pickupRequests.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .fold<double>(0, (sum, doc) => sum + (doc.data()['weight'] ?? 0));

    return {
      'totalUsers': users.docs.length,
      'totalPickupRequests': pickupRequests.docs.length,
      'completedPickups': completedPickups,
      'totalProducts': products.docs.length,
      'totalWasteRecycled': totalWasteRecycled,
    };
  }
}
