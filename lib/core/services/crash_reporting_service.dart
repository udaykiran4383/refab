import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService {
  static Future<void> initialize() async {
    if (kDebugMode) {
      // Disable crash reporting in debug mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Enable crash reporting in release mode
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    if (context != null) {
      for (final entry in context.entries) {
        await FirebaseCrashlytics.instance.setCustomKey(
          entry.key,
          entry.value.toString(),
        );
      }
    }
    
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: fatal,
    );
  }

  static Future<void> setUserId(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  static Future<void> log(String message) async {
    await FirebaseCrashlytics.instance.log(message);
  }
}
