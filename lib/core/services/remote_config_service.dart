import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // Set default values
    await _remoteConfig.setDefaults({
      'maintenance_mode': false,
      'app_disabled': false, // Kill switch parameter
      'kill_switch_message': 'This app has been disabled by the developer.', // Kill switch message
      'min_app_version': '1.0.0',
      'api_base_url': 'https://your-api-url.com/api',
      'support_email': 'support@refab.com',
      'support_phone': '+91-1234567890',
      'max_pickup_weight': 1000.0,
      'min_order_amount': 50.0,
      'volunteer_certificate_hours': 50,
      'enable_analytics': true,
      'enable_crashlytics': true,
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
  }

  // Kill switch getters
  static bool get appDisabled => _remoteConfig.getBool('app_disabled');
  static String get killSwitchMessage => _remoteConfig.getString('kill_switch_message');
  
  // Existing getters
  static bool get maintenanceMode => _remoteConfig.getBool('maintenance_mode');
  static String get minAppVersion => _remoteConfig.getString('min_app_version');
  static String get apiBaseUrl => _remoteConfig.getString('api_base_url');
  static String get supportEmail => _remoteConfig.getString('support_email');
  static String get supportPhone => _remoteConfig.getString('support_phone');
  static double get maxPickupWeight => _remoteConfig.getDouble('max_pickup_weight');
  static double get minOrderAmount => _remoteConfig.getDouble('min_order_amount');
  static int get volunteerCertificateHours => _remoteConfig.getInt('volunteer_certificate_hours');
  static bool get enableAnalytics => _remoteConfig.getBool('enable_analytics');
  static bool get enableCrashlytics => _remoteConfig.getBool('enable_crashlytics');

  static Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to refresh remote config: $e');
    }
  }
}
