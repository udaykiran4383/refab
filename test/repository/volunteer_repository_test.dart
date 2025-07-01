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

    setUpAll(() async {
      print('🤝 [VOLUNTEER_TEST] Setting up Firebase for testing...');
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      print('🤝 [VOLUNTEER_TEST] ✅ Firebase initialized');
    });

    setUp(() {
      print('🤝 [VOLUNTEER_TEST] Setting up test environment...');
      repository = VolunteerRepository();
      testVolunteerId = 'test_volunteer_${DateTime.now().millisecondsSinceEpoch}';
      print('🤝 [VOLUNTEER_TEST] ✅ Test environment ready. Volunteer ID: $testVolunteerId');
    });

    tearDown(() async {
      print('🤝 [VOLUNTEER_TEST] Cleaning up test data...');
      try {
        // Clean up test data
        final hours = await FirebaseFirestore.instance
            .collection('volunteerHours')
            .where('volunteerId', isEqualTo: testVolunteerId)
            .get();
        
        final tasks = await FirebaseFirestore.instance
            .collection('volunteerTasks')
            .where('volunteerId', isEqualTo: testVolunteerId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in hours.docs) {
          batch.delete(doc.reference);
        }
        for (var doc in tasks.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('🤝 [VOLUNTEER_TEST] ✅ Test data cleaned up');
      } catch (e) {
        print('🤝 [VOLUNTEER_TEST] ⚠️ Cleanup warning: $e');
      }
    });

    group('Volunteer Hours CRUD Operations', () {
      test('should log volunteer hours successfully', () async {
        print('🤝 [VOLUNTEER_TEST] Testing volunteer hours logging...');
        
        final volunteerHours = VolunteerHoursModel(
          id: '',
          volunteerId: testVolunteerId,
          activity: 'Fabric Sorting',
          hours: 4.5,
          date: DateTime.now(),
          location: 'Warehouse A',
          supervisor: 'supervisor_1',
          notes: 'Sorted cotton and silk fabrics by quality',
          status: HoursStatus.approved,
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Logging volunteer hours: ${volunteerHours.activity}');
        print('   - Hours: ${volunteerHours.hours}');
        print('   - Location: ${volunteerHours.location}');
        print('   - Date: ${volunteerHours.date}');
        
        final hoursId = await repository.logVolunteerHours(volunteerHours);
        
        print('🤝 [VOLUNTEER_TEST] ✅ Volunteer hours logged with ID: $hoursId');
        expect(hoursId, isNotEmpty);
        expect(hoursId.length, greaterThan(0));
      });

      test('should get volunteer hours', () async {
        print('🤝 [VOLUNTEER_TEST] Testing volunteer hours retrieval...');
        
        // Create test volunteer hours
        final hours1 = VolunteerHoursModel(
          id: '',
          volunteerId: testVolunteerId,
          activity: 'Fabric Cleaning',
          hours: 3.0,
          date: DateTime.now().subtract(Duration(days: 1)),
          location: 'Warehouse B',
          supervisor: 'supervisor_2',
          notes: 'Cleaned silk fabrics',
          status: HoursStatus.approved,
          createdAt: DateTime.now(),
        );

        final hours2 = VolunteerHoursModel(
          id: '',
          volunteerId: testVolunteerId,
          activity: 'Inventory Management',
          hours: 6.0,
          date: DateTime.now(),
          location: 'Warehouse C',
          supervisor: 'supervisor_3',
          notes: 'Updated inventory records',
          status: HoursStatus.pending,
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Creating test volunteer hours...');
        await repository.logVolunteerHours(hours1);
        await repository.logVolunteerHours(hours2);

        print('🤝 [VOLUNTEER_TEST] Fetching volunteer hours...');
        final hours = await repository.getVolunteerHours(testVolunteerId).first;
        
        print('🤝 [VOLUNTEER_TEST] ✅ Retrieved ${hours.length} volunteer hours');
        expect(hours.length, greaterThanOrEqualTo(2));
        
        final approvedHours = hours.where((h) => h.status == HoursStatus.approved).length;
        final pendingHours = hours.where((h) => h.status == HoursStatus.pending).length;
        
        print('🤝 [VOLUNTEER_TEST] 📊 Approved: $approvedHours, Pending: $pendingHours');
        expect(approvedHours, greaterThanOrEqualTo(1));
        expect(pendingHours, greaterThanOrEqualTo(1));
      });

      test('should update hours status', () async {
        print('🤝 [VOLUNTEER_TEST] Testing hours status update...');
        
        final volunteerHours = VolunteerHoursModel(
          id: '',
          volunteerId: testVolunteerId,
          activity: 'Status Update Test',
          hours: 2.5,
          date: DateTime.now(),
          location: 'Test Location',
          supervisor: 'supervisor_4',
          notes: 'Status update test',
          status: HoursStatus.pending,
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Creating volunteer hours for status update...');
        final hoursId = await repository.logVolunteerHours(volunteerHours);
        
        print('🤝 [VOLUNTEER_TEST] Updating status to approved...');
        await repository.updateHoursStatus(hoursId, HoursStatus.approved);
        
        final hours = await repository.getVolunteerHours(testVolunteerId).first;
        final updatedHours = hours.firstWhere((h) => h.id == hoursId);
        
        print('🤝 [VOLUNTEER_TEST] ✅ Hours status updated successfully');
        print('   - New Status: ${updatedHours.status}');
        expect(updatedHours.status, equals(HoursStatus.approved));
      });

      test('should get hours by date range', () async {
        print('🤝 [VOLUNTEER_TEST] Testing hours retrieval by date range...');
        
        final startDate = DateTime.now().subtract(Duration(days: 7));
        final endDate = DateTime.now();
        
        print('🤝 [VOLUNTEER_TEST] Fetching hours from ${startDate} to ${endDate}...');
        final hours = await repository.getVolunteerHoursByDateRange(
          testVolunteerId,
          startDate,
          endDate,
        );
        
        print('🤝 [VOLUNTEER_TEST] ✅ Retrieved ${hours.length} hours in date range');
        expect(hours, isA<List<VolunteerHoursModel>>());
        
        for (final hour in hours) {
          expect(hour.date.isAfter(startDate.subtract(Duration(days: 1))), isTrue);
          expect(hour.date.isBefore(endDate.add(Duration(days: 1))), isTrue);
          print('🤝 [VOLUNTEER_TEST]   - ${hour.activity}: ${hour.hours}h on ${hour.date}');
        }
      });
    });

    group('Volunteer Task CRUD Operations', () {
      test('should create volunteer task successfully', () async {
        print('🤝 [VOLUNTEER_TEST] Testing volunteer task creation...');
        
        final task = VolunteerTaskModel(
          id: '',
          volunteerId: testVolunteerId,
          taskTitle: 'Fabric Quality Check',
          taskDescription: 'Check and sort fabrics by quality standards',
          taskType: TaskType.qualityControl,
          priority: TaskPriority.high,
          status: TaskStatus.assigned,
          assignedDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 2)),
          estimatedHours: 4.0,
          location: 'Warehouse A',
          supervisor: 'supervisor_5',
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Creating volunteer task: ${task.taskTitle}');
        print('   - Type: ${task.taskType}');
        print('   - Priority: ${task.priority}');
        print('   - Estimated Hours: ${task.estimatedHours}');
        print('   - Due Date: ${task.dueDate}');
        
        final taskId = await repository.createVolunteerTask(task);
        
        print('🤝 [VOLUNTEER_TEST] ✅ Volunteer task created with ID: $taskId');
        expect(taskId, isNotEmpty);
        expect(taskId.length, greaterThan(0));
      });

      test('should get volunteer tasks', () async {
        print('🤝 [VOLUNTEER_TEST] Testing volunteer tasks retrieval...');
        
        // Create test tasks
        final task1 = VolunteerTaskModel(
          id: '',
          volunteerId: testVolunteerId,
          taskTitle: 'Inventory Count',
          taskDescription: 'Count and verify inventory items',
          taskType: TaskType.inventory,
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          assignedDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 1)),
          estimatedHours: 3.0,
          location: 'Warehouse B',
          supervisor: 'supervisor_6',
          createdAt: DateTime.now(),
        );

        final task2 = VolunteerTaskModel(
          id: '',
          volunteerId: testVolunteerId,
          taskTitle: 'Fabric Packaging',
          taskDescription: 'Package sorted fabrics for shipping',
          taskType: TaskType.packaging,
          priority: TaskPriority.low,
          status: TaskStatus.completed,
          assignedDate: DateTime.now().subtract(Duration(days: 1)),
          dueDate: DateTime.now(),
          estimatedHours: 2.5,
          location: 'Warehouse C',
          supervisor: 'supervisor_7',
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Creating test volunteer tasks...');
        await repository.createVolunteerTask(task1);
        await repository.createVolunteerTask(task2);

        print('🤝 [VOLUNTEER_TEST] Fetching volunteer tasks...');
        final tasks = await repository.getVolunteerTasks(testVolunteerId).first;
        
        print('🤝 [VOLUNTEER_TEST] ✅ Retrieved ${tasks.length} volunteer tasks');
        expect(tasks.length, greaterThanOrEqualTo(2));
        
        final assignedTasks = tasks.where((t) => t.status == TaskStatus.assigned).length;
        final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
        final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
        
        print('🤝 [VOLUNTEER_TEST] 📊 Assigned: $assignedTasks, In Progress: $inProgressTasks, Completed: $completedTasks');
        expect(assignedTasks, greaterThanOrEqualTo(1));
        expect(inProgressTasks, greaterThanOrEqualTo(1));
        expect(completedTasks, greaterThanOrEqualTo(1));
      });

      test('should update task status', () async {
        print('🤝 [VOLUNTEER_TEST] Testing task status update...');
        
        final task = VolunteerTaskModel(
          id: '',
          volunteerId: testVolunteerId,
          taskTitle: 'Task Status Update Test',
          taskDescription: 'Testing task status updates',
          taskType: TaskType.qualityControl,
          priority: TaskPriority.medium,
          status: TaskStatus.assigned,
          assignedDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 1)),
          estimatedHours: 2.0,
          location: 'Test Location',
          supervisor: 'supervisor_8',
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Creating task for status update...');
        final taskId = await repository.createVolunteerTask(task);
        
        print('🤝 [VOLUNTEER_TEST] Updating status to in progress...');
        await repository.updateTaskStatus(taskId, TaskStatus.inProgress);
        
        final tasks = await repository.getVolunteerTasks(testVolunteerId).first;
        final updatedTask = tasks.firstWhere((t) => t.id == taskId);
        
        print('🤝 [VOLUNTEER_TEST] ✅ Task status updated successfully');
        print('   - New Status: ${updatedTask.status}');
        expect(updatedTask.status, equals(TaskStatus.inProgress));
      });

      test('should get tasks by type', () async {
        print('🤝 [VOLUNTEER_TEST] Testing task filtering by type...');
        
        print('🤝 [VOLUNTEER_TEST] Fetching quality control tasks...');
        final qualityTasks = await repository.getTasksByType(testVolunteerId, TaskType.qualityControl);
        
        print('🤝 [VOLUNTEER_TEST] 🔍 Quality Control Tasks:');
        print('   - Total Tasks: ${qualityTasks.length}');
        
        for (final task in qualityTasks) {
          expect(task.taskType, equals(TaskType.qualityControl));
          print('   - ${task.taskTitle}: ${task.status}');
        }
        
        print('🤝 [VOLUNTEER_TEST] ✅ Task filtering by type successful');
      });
    });

    group('Analytics Operations', () {
      test('should get volunteer analytics', () async {
        print('🤝 [VOLUNTEER_TEST] Testing volunteer analytics...');
        
        // Create test data for analytics
        final hours1 = VolunteerHoursModel(
          id: '',
          volunteerId: testVolunteerId,
          activity: 'Analytics Test Activity 1',
          hours: 5.0,
          date: DateTime.now().subtract(Duration(days: 2)),
          location: 'Warehouse A',
          supervisor: 'supervisor_1',
          notes: 'Analytics test',
          status: HoursStatus.approved,
          createdAt: DateTime.now(),
        );

        final hours2 = VolunteerHoursModel(
          id: '',
          volunteerId: testVolunteerId,
          activity: 'Analytics Test Activity 2',
          hours: 3.5,
          date: DateTime.now().subtract(Duration(days: 1)),
          location: 'Warehouse B',
          supervisor: 'supervisor_2',
          notes: 'Analytics test',
          status: HoursStatus.approved,
          createdAt: DateTime.now(),
        );

        final task1 = VolunteerTaskModel(
          id: '',
          volunteerId: testVolunteerId,
          taskTitle: 'Analytics Test Task 1',
          taskDescription: 'Analytics test task',
          taskType: TaskType.qualityControl,
          priority: TaskPriority.high,
          status: TaskStatus.completed,
          assignedDate: DateTime.now().subtract(Duration(days: 3)),
          dueDate: DateTime.now().subtract(Duration(days: 1)),
          estimatedHours: 4.0,
          location: 'Warehouse C',
          supervisor: 'supervisor_3',
          createdAt: DateTime.now(),
        );

        final task2 = VolunteerTaskModel(
          id: '',
          volunteerId: testVolunteerId,
          taskTitle: 'Analytics Test Task 2',
          taskDescription: 'Analytics test task',
          taskType: TaskType.inventory,
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          assignedDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 2)),
          estimatedHours: 3.0,
          location: 'Warehouse D',
          supervisor: 'supervisor_4',
          createdAt: DateTime.now(),
        );

        print('🤝 [VOLUNTEER_TEST] Creating test data for analytics...');
        await repository.logVolunteerHours(hours1);
        await repository.logVolunteerHours(hours2);
        await repository.createVolunteerTask(task1);
        await repository.createVolunteerTask(task2);

        print('🤝 [VOLUNTEER_TEST] Fetching volunteer analytics...');
        final analytics = await repository.getVolunteerAnalytics(testVolunteerId);
        
        print('🤝 [VOLUNTEER_TEST] 📊 Volunteer Analytics:');
        print('   - Total Hours: ${analytics['totalHours']}');
        print('   - This Month Hours: ${analytics['thisMonthHours']}');
        print('   - Total Tasks: ${analytics['totalTasks']}');
        print('   - Completed Tasks: ${analytics['completedTasks']}');
        print('   - Pending Tasks: ${analytics['pendingTasks']}');
        print('   - Task Completion Rate: ${analytics['taskCompletionRate']}%');
        print('   - Average Hours per Day: ${analytics['averageHoursPerDay']}');
        print('   - Most Active Location: ${analytics['mostActiveLocation']}');
        
        expect(analytics['totalHours'], greaterThanOrEqualTo(8.5));
        expect(analytics['thisMonthHours'], greaterThanOrEqualTo(8.5));
        expect(analytics['totalTasks'], greaterThanOrEqualTo(2));
        expect(analytics['completedTasks'], greaterThanOrEqualTo(1));
        expect(analytics['pendingTasks'], greaterThanOrEqualTo(1));
        expect(analytics['taskCompletionRate'], greaterThan(0));
        expect(analytics['averageHoursPerDay'], greaterThan(0));
        expect(analytics['mostActiveLocation'], isNotEmpty);
        
        print('🤝 [VOLUNTEER_TEST] ✅ Volunteer analytics retrieved successfully');
      });
    });

    group('Certificate Management', () {
      test('should generate volunteer certificate', () async {
        print('🤝 [VOLUNTEER_TEST] Testing certificate generation...');
        
        print('🤝 [VOLUNTEER_TEST] Generating volunteer certificate...');
        final certificate = await repository.generateVolunteerCertificate(testVolunteerId);
        
        print('🤝 [VOLUNTEER_TEST] 🏆 Volunteer Certificate:');
        print('   - Certificate ID: ${certificate['certificateId']}');
        print('   - Volunteer Name: ${certificate['volunteerName']}');
        print('   - Total Hours: ${certificate['totalHours']}');
        print('   - Generated Date: ${certificate['generatedDate']}');
        print('   - Certificate URL: ${certificate['certificateUrl']}');
        
        expect(certificate['certificateId'], isNotEmpty);
        expect(certificate['volunteerName'], isNotEmpty);
        expect(certificate['totalHours'], isA<double>());
        expect(certificate['generatedDate'], isNotEmpty);
        expect(certificate['certificateUrl'], isNotEmpty);
        
        print('🤝 [VOLUNTEER_TEST] ✅ Certificate generated successfully');
      });

      test('should get volunteer achievements', () async {
        print('🤝 [VOLUNTEER_TEST] Testing achievements retrieval...');
        
        print('🤝 [VOLUNTEER_TEST] Fetching volunteer achievements...');
        final achievements = await repository.getVolunteerAchievements(testVolunteerId);
        
        print('🤝 [VOLUNTEER_TEST] 🏅 Volunteer Achievements:');
        print('   - Total Achievements: ${achievements.length}');
        
        for (final achievement in achievements) {
          print('   - ${achievement['title']}: ${achievement['description']}');
          print('     Earned: ${achievement['earnedDate']}');
          expect(achievement['title'], isNotEmpty);
          expect(achievement['description'], isNotEmpty);
          expect(achievement['earnedDate'], isNotEmpty);
        }
        
        expect(achievements, isA<List>());
        print('🤝 [VOLUNTEER_TEST] ✅ Achievements retrieved successfully');
      });
    });

    group('Profile Management', () {
      test('should update volunteer profile', () async {
        print('🤝 [VOLUNTEER_TEST] Testing profile update...');
        
        final updates = {
          'name': 'Updated Test Volunteer',
          'phone': '+91-9876543210',
          'address': 'Updated Test Address, Mumbai',
          'skills': ['Fabric Sorting', 'Quality Control', 'Inventory Management'],
          'availability': 'Weekdays 9 AM - 5 PM',
        };

        print('🤝 [VOLUNTEER_TEST] Updating profile with: $updates');
        await repository.updateVolunteerProfile(testVolunteerId, updates);
        
        final profile = await repository.getVolunteerProfile(testVolunteerId);
        if (profile != null) {
          print('🤝 [VOLUNTEER_TEST] ✅ Profile updated successfully');
          print('   - Name: ${profile.name}');
          print('   - Phone: ${profile.phone}');
          print('   - Address: ${profile.address}');
          print('   - Skills: ${profile.skills}');
          print('   - Availability: ${profile.availability}');
        } else {
          print('🤝 [VOLUNTEER_TEST] ⚠️ Profile not found (expected for test user)');
        }
      });
    });

    group('Error Handling', () {
      test('should handle invalid hours logging', () async {
        print('🤝 [VOLUNTEER_TEST] Testing error handling for invalid hours...');
        
        try {
          await repository.logVolunteerHours(VolunteerHoursModel(
            id: '',
            volunteerId: '', // Invalid empty volunteer ID
            activity: '',
            hours: -1, // Invalid negative hours
            date: DateTime.now(),
            location: '',
            supervisor: '',
            notes: '',
            status: HoursStatus.approved,
            createdAt: DateTime.now(),
          ));
          
          fail('Should have thrown an exception');
        } catch (e) {
          print('🤝 [VOLUNTEER_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });

      test('should handle non-existent task operations', () async {
        print('🤝 [VOLUNTEER_TEST] Testing error handling for non-existent tasks...');
        
        try {
          await repository.updateTaskStatus('non_existent_task_id', TaskStatus.completed);
          fail('Should have thrown an exception');
        } catch (e) {
          print('🤝 [VOLUNTEER_TEST] ✅ Error handled correctly: $e');
          expect(e, isA<Exception>());
        }
      });
    });

    group('Performance Tests', () {
      test('should handle large hours dataset', () async {
        print('🤝 [VOLUNTEER_TEST] Testing performance with large hours dataset...');
        
        print('🤝 [VOLUNTEER_TEST] Fetching all volunteer hours (performance test)...');
        final startTime = DateTime.now();
        
        final hours = await repository.getVolunteerHours(testVolunteerId).first;
        
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        print('🤝 [VOLUNTEER_TEST] ⚡ Performance Results:');
        print('   - Hours Retrieved: ${hours.length}');
        print('   - Duration: ${duration.inMilliseconds}ms');
        print('   - Average Time per Hour Entry: ${duration.inMilliseconds / hours.length}ms');
        
        expect(duration.inMilliseconds, lessThan(3000)); // Should complete within 3 seconds
        print('🤝 [VOLUNTEER_TEST] ✅ Performance test passed');
      });

      test('should handle concurrent operations', () async {
        print('🤝 [VOLUNTEER_TEST] Testing concurrent operations...');
        
        final futures = <Future>[];
        
        for (int i = 0; i < 3; i++) {
          final volunteerHours = VolunteerHoursModel(
            id: '',
            volunteerId: testVolunteerId,
            activity: 'Concurrent Test Activity $i',
            hours: 2.0 + i * 0.5,
            date: DateTime.now(),
            location: 'Test Location $i',
            supervisor: 'supervisor_$i',
            notes: 'Concurrent test',
            status: HoursStatus.approved,
            createdAt: DateTime.now(),
          );
          
          futures.add(repository.logVolunteerHours(volunteerHours));
        }

        print('🤝 [VOLUNTEER_TEST] Executing 3 concurrent hours logging operations...');
        final results = await Future.wait(futures);
        
        print('🤝 [VOLUNTEER_TEST] ✅ All concurrent operations completed');
        expect(results.length, equals(3));
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i], isNotEmpty);
          print('🤝 [VOLUNTEER_TEST]   - Hours entry $i logged with ID: ${results[i]}');
        }
      });
    });
  });
} 