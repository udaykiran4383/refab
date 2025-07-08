import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for testing
class FirebaseTestConfig {
  static const FirebaseOptions testOptions = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: '123456789',
    projectId: 'refab-test-project',
  );

  /// Initialize Firebase for testing
  static Future<void> initializeForTesting() async {
    if (kIsWeb) {
      // Web configuration
      await Firebase.initializeApp(options: testOptions);
    } else {
      // Mobile configuration
      await Firebase.initializeApp();
    }
  }
} 