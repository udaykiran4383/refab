import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/data/models/user_model.dart';
import '../models/pickup_request_model.dart';
import '../models/product_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  static Future<void> createUser(UserModel user) async {
    print('🔥 [FIRESTORE] Creating user: ${user.name} (${user.email}), role: ${user.role}');
    try {
      final userData = user.toJson();
      // Always use Firestore server timestamp for created_at
      userData['created_at'] = FieldValue.serverTimestamp();
      print('🔥 [FIRESTORE] User data to save: $userData');
      await _db.collection('users').doc(user.id).set(userData);
      print('🔥 [FIRESTORE] ✅ User created successfully in Firestore with role: ${user.role}');
      
      // Verify the save by reading it back
      try {
        final savedDoc = await _db.collection('users').doc(user.id).get();
        if (savedDoc.exists) {
          final savedData = savedDoc.data()!;
          print('🔥 [FIRESTORE] ✅ Verification: User saved successfully');
          print('🔥 [FIRESTORE] 📋 Saved data: $savedData');
          
          // Check if role was saved correctly
          final savedRole = savedData['role'];
          if (savedRole != null) {
            print('🔥 [FIRESTORE] 🎭 Role in Firestore: $savedRole');
            if (savedRole.toString().toLowerCase() == user.role.toString().split('.').last.toLowerCase()) {
              print('🔥 [FIRESTORE] ✅ Role saved correctly');
            } else {
              print('🔥 [FIRESTORE] ⚠️ Role mismatch! Expected: ${user.role}, Saved: $savedRole');
            }
          } else {
            print('🔥 [FIRESTORE] ⚠️ No role found in saved data');
          }
        } else {
          print('🔥 [FIRESTORE] ❌ Verification failed: User document not found after save');
        }
      } catch (verifyError) {
        print('🔥 [FIRESTORE] ⚠️ Verification error: $verifyError');
      }
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
        final data = doc.data()!;
        print('🔥 [FIRESTORE] ✅ User document found. Data: $data');
        
        // Ensure the data has the required fields
        if (data['id'] == null) {
          data['id'] = userId; // Add ID if missing
        }
        
        // Check role field specifically
        final roleField = data['role'];
        print('🔥 [FIRESTORE] 🎭 Raw role field from Firestore: "$roleField"');
        
        final user = UserModel.fromJson(data);
        print('🔥 [FIRESTORE] ✅ User loaded: ${user.name} (${user.email}), role: ${user.role}');
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
    print('🔥 [FIRESTORE] ⚠️ Deleting all users (development only)');
    try {
      final querySnapshot = await _db.collection('users').get();
      final batch = _db.batch();
      
      for (final doc in querySnapshot.docs) {
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
  static Future<void> createPickupRequest(PickupRequestModel request) async {
    try {
      await _db.collection('pickupRequests').doc(request.id).set(request.toJson());
      print('🔥 [FIRESTORE] ✅ Pickup request created successfully');
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error creating pickup request: $e');
      throw e;
    }
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
  static Future<List<ProductModel>> getProducts() async {
    try {
      final querySnapshot = await _db.collection('products').get();
      return querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error fetching products: $e');
      // Return mock data for now
      return [
        ProductModel(
          id: '1',
          name: 'Eco Tote Bag',
          description: 'Sustainable cotton tote bag',
          price: 299.0,
          imageUrl: 'https://picsum.photos/200/200?random=1',
          category: 'Bags',
          isAvailable: true,
          rating: 4.5,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '2',
          name: 'Recycled Toy Bear',
          description: 'Soft toy made from recycled materials',
          price: 199.0,
          imageUrl: 'https://picsum.photos/200/200?random=2',
          category: 'Toys',
          isAvailable: true,
          rating: 4.2,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '3',
          name: 'Wall Hanging',
          description: 'Beautiful wall decoration',
          price: 149.0,
          imageUrl: 'https://picsum.photos/200/200?random=3',
          category: 'Decor',
          isAvailable: true,
          rating: 4.0,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '4',
          name: 'Cotton Scarf',
          description: 'Handwoven cotton scarf',
          price: 99.0,
          imageUrl: 'https://picsum.photos/200/200?random=4',
          category: 'Clothing',
          isAvailable: true,
          rating: 4.3,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '5',
          name: 'Decorative Cushion',
          description: 'Eco-friendly cushion cover',
          price: 179.0,
          imageUrl: 'https://picsum.photos/200/200?random=5',
          category: 'Home',
          isAvailable: true,
          rating: 4.1,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '6',
          name: 'Recycled Notebook',
          description: 'Notebook made from recycled paper',
          price: 49.0,
          imageUrl: 'https://picsum.photos/200/200?random=6',
          category: 'Stationery',
          isAvailable: true,
          rating: 4.4,
          createdAt: DateTime.now(),
        ),
        ProductModel(
          id: '7',
          name: 'Bamboo Water Bottle',
          description: 'Sustainable bamboo water bottle',
          price: 399.0,
          imageUrl: 'https://picsum.photos/200/200?random=7',
          category: 'Kitchen',
          isAvailable: true,
          rating: 4.6,
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  static Future<void> createProduct(ProductModel product) async {
    try {
      print('🔥 [FIRESTORE] Starting createProduct...');
      print('🔥 [FIRESTORE] Product ID: ${product.id}');
      print('🔥 [FIRESTORE] Product data: ${product.toJson()}');
      
      final productData = {
        ...product.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }..remove('id');
      
      print('🔥 [FIRESTORE] Final data to write: $productData');
      print('🔥 [FIRESTORE] Writing to collection: products, document: ${product.id}');
      
      await _db.collection('products').doc(product.id).set(productData);
      
      print('🔥 [FIRESTORE] ✅ Product written successfully to Firestore');
      
      // Verify the write by reading it back
      final doc = await _db.collection('products').doc(product.id).get();
      if (doc.exists) {
        print('🔥 [FIRESTORE] ✅ Verification: Document exists in Firestore');
        print('🔥 [FIRESTORE] Document data: ${doc.data()}');
      } else {
        print('🔥 [FIRESTORE] ⚠️ Verification: Document does not exist after write');
      }
      
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error creating product: $e');
      print('🔥 [FIRESTORE] Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('🔥 [FIRESTORE] Firebase error code: ${e.code}');
        print('🔥 [FIRESTORE] Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  // Warehouses
  static Future<void> createWarehouse(Map<String, dynamic> warehouse) async {
    try {
      print('🔥 [FIRESTORE] Starting createWarehouse...');
      print('🔥 [FIRESTORE] Warehouse ID: ${warehouse['id']}');
      print('🔥 [FIRESTORE] Warehouse data: $warehouse');
      
      final warehouseData = {
        ...warehouse,
        'is_active': true, // Always set as active by default
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      }..remove('id');
      
      print('🔥 [FIRESTORE] Final data to write: $warehouseData');
      print('🔥 [FIRESTORE] Writing to collection: warehouses, document: ${warehouse['id']}');
      
      await _db.collection('warehouses').doc(warehouse['id']).set(warehouseData);
      
      print('🔥 [FIRESTORE] ✅ Warehouse written successfully to Firestore');
      
      // Verify the write by reading it back
      final doc = await _db.collection('warehouses').doc(warehouse['id']).get();
      if (doc.exists) {
        print('🔥 [FIRESTORE] ✅ Verification: Document exists in Firestore');
        print('🔥 [FIRESTORE] Document data: ${doc.data()}');
      } else {
        print('🔥 [FIRESTORE] ⚠️ Verification: Document does not exist after write');
      }
      
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error creating warehouse: $e');
      print('🔥 [FIRESTORE] Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('🔥 [FIRESTORE] Firebase error code: ${e.code}');
        print('🔥 [FIRESTORE] Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  // Warehouse Admin Users
  static Future<void> createWarehouseAdmin(Map<String, dynamic> adminData) async {
    try {
      print('🔥 [FIRESTORE] Starting createWarehouseAdmin...');
      print('🔥 [FIRESTORE] Admin ID: ${adminData['id']}');
      print('🔥 [FIRESTORE] Admin data: $adminData');
      
      // Create Firebase Auth user first
      final auth = FirebaseAuth.instance;
      final credential = await auth.createUserWithEmailAndPassword(
        email: adminData['email'],
        password: adminData['password'],
      );
      
      print('🔥 [FIRESTORE] ✅ Firebase Auth user created: ${credential.user?.uid}');
      
      // Create user document in Firestore
      final userData = {
        'id': credential.user!.uid, // Use Firebase Auth UID
        'email': adminData['email'],
        'name': adminData['name'],
        'phone': adminData['phone'],
        'role': adminData['role'],
        'warehouse_id': adminData['warehouse_id'],
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };
      
      print('🔥 [FIRESTORE] Final user data to write: $userData');
      print('🔥 [FIRESTORE] Writing to collection: users, document: ${credential.user!.uid}');
      
      await _db.collection('users').doc(credential.user!.uid).set(userData);
      
      print('🔥 [FIRESTORE] ✅ Warehouse admin user written successfully to Firestore');
      
      // Verify the write by reading it back
      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      if (doc.exists) {
        print('🔥 [FIRESTORE] ✅ Verification: User document exists in Firestore');
        print('🔥 [FIRESTORE] User document data: ${doc.data()}');
      } else {
        print('🔥 [FIRESTORE] ⚠️ Verification: User document does not exist after write');
      }
      
    } catch (e) {
      print('🔥 [FIRESTORE] ❌ Error creating warehouse admin: $e');
      print('🔥 [FIRESTORE] Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('🔥 [FIRESTORE] Firebase error code: ${e.code}');
        print('🔥 [FIRESTORE] Firebase error message: ${e.message}');
      }
      rethrow;
    }
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
