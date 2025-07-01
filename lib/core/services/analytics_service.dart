import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = 
      FirebaseAnalyticsObserver(analytics: _analytics);

  // User Events
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> setUserProperties({
    required String userId,
    required String userRole,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_role', value: userRole);
  }

  // Pickup Events
  static Future<void> logPickupRequest({
    required String fabricType,
    required double weight,
  }) async {
    await _analytics.logEvent(
      name: 'pickup_request_created',
      parameters: {
        'fabric_type': fabricType,
        'weight': weight,
      },
    );
  }

  static Future<void> logPickupCompleted({
    required String pickupId,
    required double actualWeight,
  }) async {
    await _analytics.logEvent(
      name: 'pickup_completed',
      parameters: {
        'pickup_id': pickupId,
        'actual_weight': actualWeight,
      },
    );
  }

  // E-commerce Events
  static Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String category,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'view_item',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'item_category': category,
        'price': price,
      },
    );
  }

  static Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double price,
    required int quantity,
  }) async {
    await _analytics.logEvent(
      name: 'add_to_cart',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'price': price,
        'quantity': quantity,
      },
    );
  }

  static Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
      parameters: {
        'items': items,
      },
    );
  }

  // Volunteer Events
  static Future<void> logVolunteerHours({
    required String volunteerId,
    required double hours,
    required String taskCategory,
  }) async {
    await _analytics.logEvent(
      name: 'volunteer_hours_logged',
      parameters: {
        'volunteer_id': volunteerId,
        'hours': hours,
        'task_category': taskCategory,
      },
    );
  }

  // Custom Events
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // Screen Tracking
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }
}
