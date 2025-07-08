import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request_model.dart';
import '../models/tailor_profile_model.dart';
import '../models/tailor_analytics_model.dart';
import '../../../auth/data/models/user_model.dart';

class TailorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Pickup Requests Management
  Future<String> createPickupRequest(PickupRequestModel request) async {
    try {
      print('🔥 [TAILOR_REPO] Creating pickup request: ${request.id}');
      print('🔥 [TAILOR_REPO] Tailor ID: ${request.tailorId}');
      print('🔥 [TAILOR_REPO] Customer: ${request.customerName}');
      print('🔥 [TAILOR_REPO] Fabric Type: ${request.fabricTypeDisplayName}');
      print('🔥 [TAILOR_REPO] Address: ${request.pickupAddress}');
      print('🔥 [TAILOR_REPO] Status: ${request.status.toString().split('.').last}');
      
      final requestData = request.toJson();
      print('🔥 [TAILOR_REPO] Request data keys: ${requestData.keys.toList()}');
      
      final docRef = await _firestore.collection('pickupRequests').add(requestData);
      print('🔥 [TAILOR_REPO] ✅ Pickup request created with ID: ${docRef.id}');
      
      // Verify the data was saved correctly
      final savedDoc = await _firestore.collection('pickupRequests').doc(docRef.id).get();
      if (savedDoc.exists) {
        print('🔥 [TAILOR_REPO] ✅ Verified data saved correctly');
        print('🔥 [TAILOR_REPO] Saved data keys: ${savedDoc.data()!.keys.toList()}');
      }
      
      return docRef.id;
    } catch (e) {
      print('🔥 [TAILOR_REPO] ❌ Error creating pickup request: $e');
      throw Exception('Failed to create pickup request: $e');
    }
  }

  // Get all pickup requests (for admin dashboard)
  Future<List<PickupRequestModel>> getAllPickupRequests() async {
    try {
      print('🔥 [TAILOR_REPO] Getting all pickup requests for admin dashboard');
      final snapshot = await _firestore
          .collection('pickupRequests')
          .orderBy('created_at', descending: true)
          .get();
      
      final requests = snapshot.docs.map((doc) {
        try {
          return PickupRequestModel.fromJson({
            ...(doc.data() as Map<String, dynamic>),
            'id': doc.id,
          });
        } catch (e) {
          print('🔥 [TAILOR_REPO] ❌ Error parsing pickup request ${doc.id}: $e');
          return null;
        }
      }).where((request) => request != null).cast<PickupRequestModel>().toList();
      
      print('🔥 [TAILOR_REPO] ✅ Found ${requests.length} pickup requests');
      return requests;
    } catch (e) {
      print('🔥 [TAILOR_REPO] ❌ Error getting all pickup requests: $e');
      throw Exception('Failed to get all pickup requests: $e');
    }
  }

  // Get pickup requests for a tailor
  Stream<List<PickupRequestModel>> getPickupRequests(String tailorId) {
    print('🔥 [TAILOR_REPO] Getting pickup requests for tailor: $tailorId');
    return _firestore
        .collection('pickupRequests')
        .where('tailor_id', isEqualTo: tailorId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔥 [TAILOR_REPO] Found ${snapshot.docs.length} pickup requests for tailor $tailorId');
          return snapshot.docs.map((doc) {
            try {
              final data = {
                ...(doc.data() as Map<String, dynamic>),
                'id': doc.id,
              };
              print('🔥 [TAILOR_REPO] Processing request ${doc.id}: ${data['customer_name']} - ${data['fabric_type']}');
              return PickupRequestModel.fromJson(data);
            } catch (e) {
              print('🔥 [TAILOR_REPO] ❌ Error processing pickup request ${doc.id}: $e');
              print('🔥 [TAILOR_REPO] Raw data: ${doc.data()}');
              rethrow;
            }
          }).toList();
        });
  }

  Stream<List<PickupRequestModel>> getPickupRequestsByStatus(String tailorId, PickupStatus status) {
    print('🔥 [TAILOR_REPO] Getting pickup requests for tailor: $tailorId with status: ${status.toString().split('.').last}');
    return _firestore
        .collection('pickupRequests')
        .where('tailor_id', isEqualTo: tailorId)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔥 [TAILOR_REPO] Found ${snapshot.docs.length} pickup requests with status ${status.toString().split('.').last}');
          return snapshot.docs
              .map((doc) => PickupRequestModel.fromJson({
                    ...(doc.data() as Map<String, dynamic>),
                    'id': doc.id,
                  }))
              .toList();
        });
  }

  Future<PickupRequestModel?> getPickupRequest(String requestId) async {
    try {
      print('🔥 [TAILOR_REPO] Getting pickup request: $requestId');
      final doc = await _firestore.collection('pickupRequests').doc(requestId).get();
      if (doc.exists) {
        final request = PickupRequestModel.fromJson({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
        print('🔥 [TAILOR_REPO] ✅ Found pickup request: ${request.customerName}');
        return request;
      }
      print('🔥 [TAILOR_REPO] ❌ Pickup request not found: $requestId');
      return null;
    } catch (e) {
      print('🔥 [TAILOR_REPO] ❌ Error getting pickup request: $e');
      throw Exception('Failed to get pickup request: $e');
    }
  }

  Future<void> updatePickupStatus(String requestId, PickupStatus status) async {
    try {
      print('🔥 [TAILOR_REPO] Updating pickup status: $requestId to ${status.toString().split('.').last}');
      final updates = {
        'status': status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add specific date fields based on status
      switch (status) {
        case PickupStatus.scheduled:
          updates['scheduled_date'] = DateTime.now().toIso8601String();
          break;
        case PickupStatus.pickedUp:
          updates['pickup_date'] = DateTime.now().toIso8601String();
          break;
        case PickupStatus.delivered:
          updates['delivery_date'] = DateTime.now().toIso8601String();
          break;
        case PickupStatus.completed:
          updates['completed_date'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _firestore.collection('pickupRequests').doc(requestId).update(updates);
      print('🔥 [TAILOR_REPO] ✅ Pickup status updated successfully');
    } catch (e) {
      print('🔥 [TAILOR_REPO] ❌ Error updating pickup status: $e');
      throw Exception('Failed to update pickup status: $e');
    }
  }

  Future<void> updatePickupProgress(String requestId, String progress) async {
    try {
      print('🧵 [TAILOR_REPO] Updating progress for request $requestId to: $progress');
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'progress': progress,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('🧵 [TAILOR_REPO] ✅ Progress updated successfully');
    } catch (e) {
      print('🧵 [TAILOR_REPO] ❌ Error updating progress: $e');
      throw Exception('Failed to update pickup progress: $e');
    }
  }

  // New method for updating work progress using the enum
  Future<void> updateWorkProgress(String requestId, TailorWorkProgress workProgress) async {
    try {
      print('🧵 [TAILOR_REPO] Updating work progress for request $requestId to: ${workProgress.toString().split('.').last}');
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'work_progress': workProgress.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('🧵 [TAILOR_REPO] ✅ Work progress updated successfully');
    } catch (e) {
      print('🧵 [TAILOR_REPO] ❌ Error updating work progress: $e');
      throw Exception('Failed to update work progress: $e');
    }
  }

  Future<void> updatePickupRequest(String requestId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await _firestore.collection('pickupRequests').doc(requestId).update(updates);
    } catch (e) {
      throw Exception('Failed to update pickup request: $e');
    }
  }

  Future<void> cancelPickupRequest(String requestId, String reason) async {
    try {
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'status': PickupStatus.cancelled.toString().split('.').last,
        'rejection_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to cancel pickup request: $e');
    }
  }

  Future<void> rejectPickupRequest(String requestId, String reason) async {
    try {
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'status': PickupStatus.rejected.toString().split('.').last,
        'rejection_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to reject pickup request: $e');
    }
  }

  // Profile Management
  Future<void> createTailorProfile(TailorProfileModel profile) async {
    try {
      await _firestore.collection('tailorProfiles').doc(profile.id).set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to create tailor profile: $e');
    }
  }

  Future<TailorProfileModel?> getTailorProfile(String tailorId) async {
    try {
      final doc = await _firestore.collection('tailorProfiles').doc(tailorId).get();
      if (doc.exists) {
        return TailorProfileModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tailor profile: $e');
    }
  }

  Future<void> updateTailorProfile(String tailorId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('tailorProfiles').doc(tailorId).update(updates);
    } catch (e) {
      throw Exception('Failed to update tailor profile: $e');
    }
  }

  Future<void> updateAvailabilityStatus(String tailorId, AvailabilityStatus status) async {
    try {
      await _firestore.collection('tailorProfiles').doc(tailorId).update({
        'availabilityStatus': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update availability status: $e');
    }
  }

  // Analytics
  Future<TailorAnalyticsModel> getTailorAnalytics(String tailorId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      print('📊 [TAILOR_REPO] Getting analytics for tailor: $tailorId');
      print('📊 [TAILOR_REPO] Start date: $startDate, End date: $endDate');
      
      Query query = _firestore.collection('pickupRequests').where('tailor_id', isEqualTo: tailorId);
      
      if (startDate != null) {
        query = query.where('created_at', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.where('created_at', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      
      final snapshot = await query.get();
      print('📊 [TAILOR_REPO] Found ${snapshot.docs.length} pickup requests for analytics');
      
      final requests = snapshot.docs.map((doc) {
        try {
          return PickupRequestModel.fromJson({
            ...(doc.data() as Map<String, dynamic>),
            'id': doc.id,
          });
        } catch (e) {
          print('📊 [TAILOR_REPO] ❌ Error parsing request ${doc.id}: $e');
          return null;
        }
      }).where((request) => request != null).cast<PickupRequestModel>().toList();
      
      // Calculate analytics
      final totalPickupRequests = requests.length;
      final completedPickupRequests = requests.where((r) => r.status == PickupStatus.completed).length;
      final pendingPickupRequests = requests.where((r) => r.status == PickupStatus.pending).length;
      final cancelledPickupRequests = requests.where((r) => r.status == PickupStatus.cancelled).length;
      
      final totalWeightCollected = requests
          .where((r) => r.status == PickupStatus.completed)
          .fold(0.0, (sum, r) => sum + r.actualWeight);
      
      final totalEarnings = requests
          .where((r) => r.status == PickupStatus.completed)
          .fold(0.0, (sum, r) => sum + r.actualValue);
      
      // Fabric type distribution
      final fabricTypeDistribution = <String, int>{};
      for (final request in requests) {
        final fabricType = request.fabricTypeDisplayName;
        fabricTypeDistribution[fabricType] = (fabricTypeDistribution[fabricType] ?? 0) + 1;
      }
      
      // Monthly earnings
      final monthlyEarnings = <String, double>{};
      for (final request in requests.where((r) => r.status == PickupStatus.completed)) {
        final month = '${request.completedDate?.year}-${request.completedDate?.month.toString().padLeft(2, '0')}';
        monthlyEarnings[month] = (monthlyEarnings[month] ?? 0.0) + request.actualValue;
      }
      
      // Daily pickup requests
      final dailyPickupRequests = <String, int>{};
      for (final request in requests) {
        final day = '${request.createdAt.year}-${request.createdAt.month.toString().padLeft(2, '0')}-${request.createdAt.day.toString().padLeft(2, '0')}';
        dailyPickupRequests[day] = (dailyPickupRequests[day] ?? 0) + 1;
      }
      
      // Calculate averages
      final averagePickupValue = completedPickupRequests > 0 ? totalEarnings / completedPickupRequests : 0.0;
      final averageProcessingTime = completedPickupRequests > 0 ? 2.5 : 0.0; // Placeholder
      final totalWorkingHours = completedPickupRequests * 2; // Placeholder: 2 hours per pickup
      final efficiencyScore = completedPickupRequests > 0 ? (completedPickupRequests / totalPickupRequests) * 100 : 0.0;
      
      // Customer analysis
      final uniqueCustomers = requests.map((r) => r.customerEmail).toSet();
      final totalCustomers = uniqueCustomers.length;
      final repeatCustomers = requests
          .where((r) => requests.where((r2) => r2.customerEmail == r.customerEmail).length > 1)
          .map((r) => r.customerEmail)
          .toSet()
          .length;
      
      // Fix for topPerformingMonths
      final sortedMonths = monthlyEarnings.entries.toList();
      sortedMonths.sort((a, b) => b.value.compareTo(a.value));
      
      final analytics = TailorAnalyticsModel(
        tailorId: tailorId,
        date: DateTime.now(),
        totalPickupRequests: totalPickupRequests,
        completedPickupRequests: completedPickupRequests,
        pendingPickupRequests: pendingPickupRequests,
        cancelledPickupRequests: cancelledPickupRequests,
        totalWeightCollected: totalWeightCollected,
        totalEarnings: totalEarnings,
        averageRating: 4.5, // Placeholder
        totalReviews: completedPickupRequests, // Placeholder
        totalCustomers: totalCustomers,
        repeatCustomers: repeatCustomers,
        customerSatisfactionScore: 85.0, // Placeholder
        fabricTypeDistribution: fabricTypeDistribution,
        monthlyEarnings: monthlyEarnings,
        dailyPickupRequests: dailyPickupRequests,
        averagePickupValue: averagePickupValue,
        averageProcessingTime: averageProcessingTime,
        totalWorkingHours: totalWorkingHours,
        efficiencyScore: efficiencyScore,
        topPerformingMonths: sortedMonths.take(3).map((e) => e.key).toList(),
        areasForImprovement: <String>[],
      );
      
      print('📊 [TAILOR_REPO] ✅ Analytics calculated successfully');
      print('📊 [TAILOR_REPO] Total requests: $totalPickupRequests');
      print('📊 [TAILOR_REPO] Completed: $completedPickupRequests');
      print('📊 [TAILOR_REPO] Total earnings: $totalEarnings');
      
      return analytics;
    } catch (e) {
      print('📊 [TAILOR_REPO] ❌ Error getting analytics: $e');
      throw Exception('Failed to get tailor analytics: $e');
    }
  }

  List<String> _generateImprovementAreas(List<PickupRequestModel> requests) {
    final areas = <String>[];
    
    final completionRate = requests.isNotEmpty 
        ? requests.where((r) => r.isCompleted).length / requests.length 
        : 0.0;
    
    if (completionRate < 0.8) {
      areas.add('Improve completion rate');
    }
    
    if (requests.where((r) => r.isCancelled).length > requests.length * 0.1) {
      areas.add('Reduce cancellation rate');
    }
    
    return areas;
  }

  // Scheduling
  Future<void> schedulePickup(String requestId, DateTime scheduledDate) async {
    try {
      await _firestore.collection('pickupRequests').doc(requestId).update({
        'status': PickupStatus.scheduled.toString().split('.').last,
        'scheduled_date': scheduledDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to schedule pickup: $e');
    }
  }

  Stream<List<PickupRequestModel>> getScheduledPickups(String tailorId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('pickupRequests')
        .where('tailor_id', isEqualTo: tailorId)
        .where('status', isEqualTo: PickupStatus.scheduled.toString().split('.').last)
        .where('scheduled_date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('scheduled_date', isLessThan: endOfDay.toIso8601String())
        .orderBy('scheduled_date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PickupRequestModel.fromJson({
                  ...(doc.data() as Map<String, dynamic>),
                  'id': doc.id,
                }))
            .toList());
  }

  // Notifications
  Future<void> sendNotification(String tailorId, String title, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'tailor_id': tailorId,
        'title': title,
        'message': message,
        'isRead': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String tailorId) {
    return _firestore
        .collection('notifications')
        .where('tailor_id', isEqualTo: tailorId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Search and Filter
  Stream<List<PickupRequestModel>> searchPickupRequests(
    String tailorId, {
    String? searchQuery,
    PickupStatus? status,
    FabricType? fabricType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('pickupRequests').where('tailor_id', isEqualTo: tailorId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString().split('.').last);
    }

    if (fabricType != null) {
      query = query.where('fabric_type', isEqualTo: fabricType.toString().split('.').last);
    }

    if (startDate != null) {
      query = query.where('created_at', isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('created_at', isLessThanOrEqualTo: endDate.toIso8601String());
    }

    return query
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          var requests = snapshot.docs
              .map((doc) => PickupRequestModel.fromJson({
                    ...(doc.data() as Map<String, dynamic>),
                    'id': doc.id,
                  }))
              .toList();

          if (searchQuery != null && searchQuery.isNotEmpty) {
            requests = requests.where((request) {
              return request.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                     request.fabricDescription.toLowerCase().contains(searchQuery.toLowerCase()) ||
                     request.pickupAddress.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();
          }

          return requests;
        });
  }

  // Bulk Operations
  Future<void> bulkUpdateStatus(List<String> requestIds, PickupStatus status) async {
    try {
      final batch = _firestore.batch();
      
      for (final requestId in requestIds) {
        final docRef = _firestore.collection('pickupRequests').doc(requestId);
        batch.update(docRef, {
          'status': status.toString().split('.').last,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk update status: $e');
    }
  }

  // Performance Metrics
  Future<Map<String, dynamic>> getPerformanceMetrics(String tailorId) async {
    try {
      final analytics = await getTailorAnalytics(tailorId);
      
      return {
        'completionRate': analytics.completionRate,
        'averageRating': analytics.averageRating,
        'totalEarnings': analytics.totalEarnings,
        'efficiencyScore': analytics.efficiencyScore,
        'customerRetentionRate': analytics.customerRetentionRate,
        'performanceLevel': analytics.performanceLevel,
        'recommendations': analytics.recommendations,
      };
    } catch (e) {
      throw Exception('Failed to get performance metrics: $e');
    }
  }

  // Customer Management
  Future<List<Map<String, dynamic>>> getTopCustomers(String tailorId, {int limit = 10}) async {
    try {
      final requests = await _firestore
          .collection('pickupRequests')
          .where('tailor_id', isEqualTo: tailorId)
          .where('status', isEqualTo: PickupStatus.completed.toString().split('.').last)
          .get();

      final customerStats = <String, Map<String, dynamic>>{};
      
      for (final doc in requests.docs) {
        final request = PickupRequestModel.fromJson({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
        
        final customerId = request.customerId ?? request.customerEmail;
        if (customerStats.containsKey(customerId)) {
          customerStats[customerId]!['totalOrders'] = (customerStats[customerId]!['totalOrders'] as int) + 1;
          customerStats[customerId]!['totalValue'] = (customerStats[customerId]!['totalValue'] as double) + request.actualValue;
        } else {
          customerStats[customerId] = {
            'customerId': customerId,
            'customerName': request.customerName,
            'customerEmail': request.customerEmail,
            'totalOrders': 1,
            'totalValue': request.actualValue,
            'lastOrderDate': request.completedDate,
          };
        }
      }

      final sortedCustomers = customerStats.values.toList()
        ..sort((a, b) => (b['totalValue'] as double).compareTo(a['totalValue'] as double));

      return sortedCustomers.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get top customers: $e');
    }
  }
} 