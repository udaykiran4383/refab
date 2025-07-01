import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request_model.dart';
import '../../../auth/data/models/user_model.dart';

class TailorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pickup Requests
  Future<String> createPickupRequest(PickupRequestModel request) async {
    try {
      final docRef = await _firestore.collection('pickupRequests').add(request.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pickup request: $e');
    }
  }

  Stream<List<PickupRequestModel>> getPickupRequests(String tailorId) {
    return _firestore
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

  Future<void> updatePickupStatus(String requestId, PickupStatus status) async {
    try {
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update pickup status: $e');
    }
  }

  Future<void> cancelPickupRequest(String requestId) async {
    try {
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to cancel pickup request: $e');
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getTailorAnalytics(String tailorId) async {
    try {
      final pickupRequests = await _firestore
          .collection('pickupRequests')
          .where('tailorId', isEqualTo: tailorId)
          .get();

      final totalRequests = pickupRequests.docs.length;
      final completedRequests = pickupRequests.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;
      final pendingRequests = pickupRequests.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;
      final totalWeight = pickupRequests.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .fold<double>(0, (sum, doc) => sum + (doc.data()['estimatedWeight'] ?? 0));

      return {
        'totalRequests': totalRequests,
        'completedRequests': completedRequests,
        'pendingRequests': pendingRequests,
        'totalWeight': totalWeight,
        'completionRate': totalRequests > 0 ? (completedRequests / totalRequests) * 100 : 0,
      };
    } catch (e) {
      throw Exception('Failed to get tailor analytics: $e');
    }
  }

  // Profile Management
  Future<void> updateTailorProfile(String tailorId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(tailorId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update tailor profile: $e');
    }
  }

  Future<UserModel?> getTailorProfile(String tailorId) async {
    try {
      final doc = await _firestore.collection('users').doc(tailorId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tailor profile: $e');
    }
  }
} 