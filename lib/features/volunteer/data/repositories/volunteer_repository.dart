import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer_hours_model.dart';
import '../models/volunteer_task_model.dart';
import '../models/volunteer_analytics_model.dart';

class VolunteerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hour Logging
  Future<String> logVolunteerHours(VolunteerHoursModel hours) async {
    try {
      final docRef = await _firestore.collection('volunteerHours').add(hours.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to log volunteer hours: $e');
    }
  }

  Stream<List<VolunteerHoursModel>> getVolunteerHours(String volunteerId) {
    return _firestore
        .collection('volunteerHours')
        .where('volunteerId', isEqualTo: volunteerId)
        .orderBy('logDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VolunteerHoursModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  Future<VolunteerHoursModel?> getVolunteerHoursEntry(String entryId) async {
    try {
      final doc = await _firestore.collection('volunteerHours').doc(entryId).get();
      if (doc.exists) {
        return VolunteerHoursModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get volunteer hours entry: $e');
    }
  }

  Future<void> updateVolunteerHours(String entryId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('volunteerHours').doc(entryId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update volunteer hours: $e');
    }
  }

  Future<void> deleteVolunteerHours(String entryId) async {
    try {
      await _firestore.collection('volunteerHours').doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete volunteer hours: $e');
    }
  }

  // Get volunteer hours by date range
  Future<List<VolunteerHoursModel>> getVolunteerHoursByDateRange(String volunteerId, DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('volunteerHours')
        .where('volunteerId', isEqualTo: volunteerId)
        .where('logDate', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('logDate', isLessThanOrEqualTo: end.toIso8601String())
        .get();
    return snapshot.docs.map((doc) => VolunteerHoursModel.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  // Volunteer Task CRUD
  Future<String> createVolunteerTask(VolunteerTaskModel task) async {
    final docRef = await _firestore.collection('volunteerTasks').add(task.toJson());
    return docRef.id;
  }

  Stream<List<VolunteerTaskModel>> getVolunteerTasks(String volunteerId) {
    return _firestore
        .collection('volunteerTasks')
        .where('assignedVolunteerId', isEqualTo: volunteerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VolunteerTaskModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> updateTaskStatus(String taskId, VolunteerTaskStatus status) async {
    await _firestore.collection('volunteerTasks').doc(taskId).update({
      'status': status.toString().split('.').last,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<VolunteerTaskModel>> getTasksByType(String volunteerId, String taskCategory) async {
    final snapshot = await _firestore
        .collection('volunteerTasks')
        .where('assignedVolunteerId', isEqualTo: volunteerId)
        .where('taskCategory', isEqualTo: taskCategory)
        .get();
    return snapshot.docs.map((doc) => VolunteerTaskModel.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  // Analytics
  Future<VolunteerAnalyticsModel> getVolunteerAnalytics(String volunteerId) async {
    try {
      final volunteerHours = await _firestore
          .collection('volunteerHours')
          .where('volunteerId', isEqualTo: volunteerId)
          .get();

      final totalHours = volunteerHours.docs
          .fold<double>(0, (sum, doc) => sum + (doc.data()['hoursLogged'] ?? 0));
      final verifiedHours = volunteerHours.docs
          .where((doc) => doc.data()['isVerified'] == true)
          .fold<double>(0, (sum, doc) => sum + (doc.data()['hoursLogged'] ?? 0));

      // Monthly trends
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      final thisMonthHours = volunteerHours.docs
          .where((doc) {
            final logDate = DateTime.parse(doc.data()['logDate']);
            return logDate.isAfter(thisMonth);
          })
          .fold<double>(0, (sum, doc) => sum + (doc.data()['hoursLogged'] ?? 0));

      final lastMonthHours = volunteerHours.docs
          .where((doc) {
            final logDate = DateTime.parse(doc.data()['logDate']);
            return logDate.isAfter(lastMonth) && logDate.isBefore(thisMonth);
          })
          .fold<double>(0, (sum, doc) => sum + (doc.data()['hoursLogged'] ?? 0));

      return VolunteerAnalyticsModel(
        totalHours: totalHours,
        verifiedHours: verifiedHours,
        thisMonthHours: thisMonthHours,
        lastMonthHours: lastMonthHours,
        hoursGrowthRate: lastMonthHours > 0 
            ? ((thisMonthHours - lastMonthHours) / lastMonthHours) * 100 
            : 0,
        hoursToCertificate: 50 - verifiedHours, // Assuming 50 hours for certificate
      );
    } catch (e) {
      throw Exception('Failed to get volunteer analytics: $e');
    }
  }

  // Certificate Management
  Future<bool> checkCertificateEligibility(String volunteerId) async {
    try {
      final volunteerHours = await _firestore
          .collection('volunteerHours')
          .where('volunteerId', isEqualTo: volunteerId)
          .where('isVerified', isEqualTo: true)
          .get();

      final totalVerifiedHours = volunteerHours.docs
          .fold<double>(0, (sum, doc) => sum + (doc.data()['hoursLogged'] ?? 0));

      return totalVerifiedHours >= 50; // Certificate threshold
    } catch (e) {
      throw Exception('Failed to check certificate eligibility: $e');
    }
  }

  Future<void> requestCertificate(String volunteerId) async {
    try {
      await _firestore.collection('certificateRequests').add({
        'volunteerId': volunteerId,
        'status': 'pending',
        'requestedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to request certificate: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getCertificateRequests(String volunteerId) {
    return _firestore
        .collection('certificateRequests')
        .where('volunteerId', isEqualTo: volunteerId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Profile Management
  Future<void> updateVolunteerProfile(String volunteerId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(volunteerId).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update volunteer profile: $e');
    }
  }

  // Hour Verification
  Future<void> verifyHours(String entryId, String supervisorId, String notes) async {
    try {
      await _firestore.collection('volunteerHours').doc(entryId).update({
        'isVerified': true,
        'supervisorId': supervisorId,
        'verificationNotes': notes,
        'verifiedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to verify hours: $e');
    }
  }

  // Certificate generation (mock)
  Future<Map<String, dynamic>> generateVolunteerCertificate(String volunteerId) async {
    // In a real app, this would generate a PDF or similar
    return {
      'certificateId': 'cert_${DateTime.now().millisecondsSinceEpoch}',
      'volunteerId': volunteerId,
      'issuedAt': DateTime.now().toIso8601String(),
      'totalHours': 50.0,
      'volunteerName': 'John Volunteer',
    };
  }

  // Achievements (mock)
  Future<List<Map<String, dynamic>>> getVolunteerAchievements(String volunteerId) async {
    // In a real app, this would query a collection
    return [
      {'title': '50 Hours Milestone', 'date': DateTime.now().toIso8601String()},
      {'title': 'First Task Completed', 'date': DateTime.now().toIso8601String()},
    ];
  }

  // Profile (mock)
  Future<Map<String, dynamic>> getVolunteerProfile(String volunteerId) async {
    // In a real app, this would query the users collection
    return {
      'id': volunteerId,
      'name': 'John Volunteer',
      'email': 'john@example.com',
      'totalHours': 50.0,
      'achievements': ['50 Hours Milestone', 'First Task Completed'],
    };
  }
} 