import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  print('🚀 [MAIN] Starting ReFab app...');
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 [MAIN] Flutter binding initialized');
  
  try {
    print('🚀 [MAIN] Checking Firebase initialization...');
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      print('🚀 [MAIN] Firebase not initialized, initializing now...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('🚀 [MAIN] ✅ Firebase initialized successfully');
    } else {
      print('🚀 [MAIN] ⚠️ Firebase already initialized, using existing app');
      print('🚀 [MAIN] Firebase apps count: ${Firebase.apps.length}');
    }
  } catch (e) {
    print('🚀 [MAIN] ❌ Firebase initialization error: $e');
    if (e.toString().contains('duplicate-app')) {
      print('🚀 [MAIN] ⚠️ Firebase already initialized, continuing...');
    } else {
      print('🚀 [MAIN] ❌ Critical Firebase error, rethrowing: $e');
      rethrow;
    }
  }
  
  print('🚀 [MAIN] Starting app with ProviderScope...');
  runApp(
    ProviderScope(
      child: ReFabApp(),
    ),
  );
  print('🚀 [MAIN] App started successfully');
}
