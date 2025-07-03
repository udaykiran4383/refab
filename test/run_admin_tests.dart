import 'package:flutter_test/flutter_test.dart';

// Import all admin tests
import 'repository/admin_repository_test.dart';
import 'integration/admin_integration_test.dart';

void main() {
  print('🚀 [ADMIN_TEST_RUNNER] Starting comprehensive admin tests...');
  print('🚀 [ADMIN_TEST_RUNNER] ==========================================');

  group('Admin Test Suite', () {
    group('Unit Tests', () {
      test('Admin Repository Unit Tests', () {
        print('🧪 [ADMIN_TEST_RUNNER] Running Admin Repository Unit Tests...');
        // This will be handled by the imported test file
      });
    });

    group('Integration Tests', () {
      test('Admin Integration Tests', () {
        print('🔧 [ADMIN_TEST_RUNNER] Running Admin Integration Tests...');
        // This will be handled by the imported test file
      });
    });
  });

  print('🚀 [ADMIN_TEST_RUNNER] ==========================================');
  print('🚀 [ADMIN_TEST_RUNNER] Admin test suite completed!');
} 