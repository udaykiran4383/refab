import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:refab_app/features/volunteer/data/repositories/volunteer_repository.dart';
import 'package:refab_app/features/volunteer/data/models/volunteer_hours_model.dart';
import 'package:refab_app/features/volunteer/data/models/volunteer_task_model.dart';
import 'package:refab_app/features/volunteer/data/models/volunteer_analytics_model.dart';

void main() {
  group('VolunteerRepository Tests', () {
    late VolunteerRepository repository;
    late String testVolunteerId;
    setUp(() {
      repository = VolunteerRepository();
      testVolunteerId = 'test_volunteer_${DateTime.now().millisecondsSinceEpoch}';
    });
    // Only keep tests for fields that exist in the current models
    // Example: Test VolunteerHoursModel creation
    test('should create VolunteerHoursModel', () {
      final hours = VolunteerHoursModel(
        id: '1',
          volunteerId: testVolunteerId,
        taskCategory: 'Sorting',
        hoursLogged: 4.0,
        description: 'Sorted fabrics',
        isVerified: false,
        logDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
      expect(hours.volunteerId, testVolunteerId);
      expect(hours.taskCategory, 'Sorting');
      expect(hours.hoursLogged, 4.0);
      expect(hours.isVerified, false);
    });
    // Example: Test VolunteerTaskModel creation
    test('should create VolunteerTaskModel', () {
        final task = VolunteerTaskModel(
        id: '1',
        taskTitle: 'Quality Check',
        taskDescription: 'Check fabric quality',
        taskCategory: 'Quality',
        status: VolunteerTaskStatus.assigned,
        priority: 2,
          createdAt: DateTime.now(),
        );
      expect(task.taskTitle, 'Quality Check');
      expect(task.status, VolunteerTaskStatus.assigned);
      expect(task.priority, 2);
    });
    // Example: Test VolunteerAnalyticsModel creation
    test('should create VolunteerAnalyticsModel', () {
      final analytics = VolunteerAnalyticsModel(
        totalHours: 20.0,
        verifiedHours: 15.0,
        thisMonthHours: 5.0,
        lastMonthHours: 10.0,
        hoursGrowthRate: 0.5,
        hoursToCertificate: 30.0,
      );
      expect(analytics.totalHours, 20.0);
      expect(analytics.verifiedHours, 15.0);
      expect(analytics.thisMonthHours, 5.0);
      expect(analytics.lastMonthHours, 10.0);
      expect(analytics.hoursGrowthRate, 0.5);
      expect(analytics.hoursToCertificate, 30.0);
    });
  });
} 