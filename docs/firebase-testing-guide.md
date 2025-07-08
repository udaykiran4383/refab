# Firebase Testing Setup Guide

This guide explains how to set up Firebase for testing in the ReFab app.

## 🚀 Quick Start

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Start Firebase Emulators
```bash
./scripts/start_emulators.sh
```

### 3. Run Tests
```bash
flutter test
```

## 📋 Detailed Setup

### Option 1: Firebase Emulators (Recommended)

#### Step 1: Initialize Firebase Project
```bash
firebase login
firebase init emulators
```

#### Step 2: Configure Emulators
The `firebase.json` file is already configured with:
- **Firestore**: Port 8080
- **Auth**: Port 9099  
- **Storage**: Port 9199
- **UI**: Port 4000

#### Step 3: Start Emulators
```bash
firebase emulators:start --only auth,firestore,storage
```

#### Step 4: Access Emulator UI
Open http://localhost:4000 to view the Firebase Emulator UI.

### Option 2: Mock Firebase (For Unit Tests)

For pure unit tests that don't need Firebase, you can use mocks:

```dart
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
```

### Option 3: Test Configuration

The app includes a test configuration in `test/firebase_test_config.dart` that provides:
- Test Firebase options
- Proper initialization for different platforms
- Error handling for missing Firebase setup

## 🧪 Test Helper Usage

### Basic Setup
```dart
import 'test_helper.dart';

void main() {
  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  tearDownAll(() async {
    await TestHelper.cleanupTestData();
  });
}
```

### Creating Test Data
```dart
// Create test user
final userId = await TestHelper.createTestUser(
  email: 'test@example.com',
  name: 'Test User',
  role: 'tailor',
);

// Create test pickup request
final requestId = await TestHelper.createTestPickupRequest(
  tailorId: userId,
  fabricType: 'cotton',
  weight: 5.5,
);

// Create test inventory
final inventoryId = await TestHelper.createTestInventoryItem(
  warehouseId: 'warehouse_1',
  fabricCategory: 'cotton',
  weight: 100.0,
);
```

## 🔧 Troubleshooting

### Common Issues

#### 1. "No Firebase App '[DEFAULT]' has been created"
**Solution**: Make sure Firebase emulators are running:
```bash
./scripts/start_emulators.sh
```

#### 2. "Unable to establish connection on channel"
**Solution**: Check if emulators are running on correct ports:
- Firestore: localhost:8080
- Auth: localhost:9099
- Storage: localhost:9199

#### 3. "Firebase CLI not found"
**Solution**: Install Firebase CLI:
```bash
npm install -g firebase-tools
```

#### 4. Tests failing due to Firebase initialization
**Solution**: Add proper error handling in tests:
```dart
setUpAll(() async {
  try {
    await TestHelper.setupFirebaseForTesting();
  } catch (e) {
    print('Firebase setup failed: $e');
    // Continue with tests using mocks
  }
});
```

### Debug Mode

Enable debug logging:
```dart
// In test_helper.dart
static Future<void> setupFirebaseForTesting() async {
  if (_isInitialized) return;

  try {
    print('🧪 [TEST_HELPER] Setting up Firebase for testing...');
    
    // Enable debug mode
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      ssl: false,
      persistenceEnabled: false,
    );
    
    await FirebaseTestConfig.initializeForTesting();
    await _connectToEmulators();
    
    _isInitialized = true;
    print('🧪 [TEST_HELPER] ✅ Firebase initialized successfully');
  } catch (e) {
    print('🧪 [TEST_HELPER] ⚠️ Firebase initialization failed: $e');
  }
}
```

## 📊 Test Categories

### 1. Unit Tests
- Don't require Firebase
- Use mocks for Firebase services
- Fast execution

### 2. Integration Tests
- Require Firebase emulators
- Test real Firebase operations
- Slower but more comprehensive

### 3. Widget Tests
- May require Firebase for state management
- Test UI components with real data

## 🎯 Best Practices

### 1. Test Data Management
- Always mark test data with `isTestData: true`
- Clean up test data after tests
- Use unique identifiers for test data

### 2. Error Handling
- Handle Firebase initialization failures gracefully
- Provide fallback behavior for missing Firebase setup
- Log errors for debugging

### 3. Performance
- Use Firebase emulators for faster tests
- Batch operations when possible
- Clean up data efficiently

### 4. CI/CD Integration
```yaml
# In your CI pipeline
- name: Start Firebase Emulators
  run: |
    npm install -g firebase-tools
    firebase emulators:start --only auth,firestore,storage &
    sleep 10  # Wait for emulators to start

- name: Run Tests
  run: flutter test
```

## 🔗 Useful Commands

```bash
# Start emulators
./scripts/start_emulators.sh

# Run all tests
flutter test

# Run specific test file
flutter test test/repository/tailor_repository_test.dart

# Run tests with coverage
flutter test --coverage

# View emulator UI
open http://localhost:4000

# Stop emulators
firebase emulators:stop
```

## 📚 Additional Resources

- [Firebase Emulator Documentation](https://firebase.google.com/docs/emulator-suite)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Firebase Testing Best Practices](https://firebase.google.com/docs/rules/unit-tests) 