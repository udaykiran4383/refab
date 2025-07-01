class AppConstants {
  // App Info
  static const String appName = 'ReFab';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Textile Recycling & Women Empowerment';

  // API Configuration
  static const String baseUrl = 'https://your-api-url.com/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'selected_theme';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxImagesPerUpload = 5;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxAddressLength = 200;
  static const int maxDescriptionLength = 500;

  // Business Rules
  static const double minPickupWeight = 0.1;
  static const double maxPickupWeight = 1000.0;
  static const double minOrderAmount = 50.0;
  static const int volunteerHoursForCertificate = 50;

  // Notification Types
  static const String pickupRequestNotification = 'pickup_request';
  static const String orderStatusNotification = 'order_status';
  static const String volunteerUpdateNotification = 'volunteer_update';
  static const String systemNotification = 'system';

  // User Roles
  static const List<String> userRoles = [
    'tailor',
    'logistics',
    'warehouse',
    'customer',
    'volunteer',
    'admin'
  ];

  // Product Categories
  static const List<String> productCategories = [
    'Bags',
    'Toys',
    'Home Decor',
    'Clothing',
    'Accessories',
    'Others'
  ];

  // Fabric Types
  static const List<String> fabricTypes = [
    'Cotton',
    'Silk',
    'Polyester',
    'Wool',
    'Linen',
    'Denim',
    'Chiffon',
    'Velvet',
    'Others'
  ];

  // Quality Grades
  static const List<String> qualityGrades = ['A', 'B', 'C'];

  // Order Status
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  // Pickup Status
  static const List<String> pickupStatuses = [
    'pending',
    'scheduled',
    'in_progress',
    'completed',
    'cancelled'
  ];
}
