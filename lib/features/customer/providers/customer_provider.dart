import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/customer_repository.dart';
import '../data/models/product_model.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_model.dart';
import '../data/models/customer_profile_model.dart';
import '../data/models/customer_analytics_model.dart';

// Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

// Products Providers
final productsProvider = StreamProvider.family<List<ProductModel>, Map<String, String?>>((ref, filters) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getProducts(
    category: filters['category'],
    searchQuery: filters['searchQuery'],
  );
});

final productProvider = FutureProvider.family<ProductModel?, String>((ref, productId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getProduct(productId);
});

final trendingProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getTrendingProducts(limit: 10);
});

final recommendedProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getRecommendedProducts(customerId, limit: 10).first;
});

// Cart Providers
final cartProvider = StreamProvider.family<CartModel?, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCart(customerId);
});

final cartNotifierProvider = StateNotifierProvider<CartNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CartNotifier(repository);
});

class CartNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  CartNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addToCart(String customerId, CartItem item) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addToCart(customerId, item);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCartItem(String customerId, String productId, int quantity) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCartItem(customerId, productId, quantity);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeFromCart(String customerId, String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeFromCart(customerId, productId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearCart(String customerId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearCart(customerId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Orders Providers
final customerOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerOrders(customerId);
});

final orderProvider = FutureProvider.family<OrderModel?, String>((ref, orderId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getOrder(orderId);
});

final ordersByStatusProvider = FutureProvider.family<List<OrderModel>, Map<String, dynamic>>((ref, params) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getOrdersByStatus(params['customerId'], params['status']);
});

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return OrderNotifier(repository);
});

class OrderNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  OrderNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createOrder(OrderModel order) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createOrder(order);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> cancelOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelOrder(orderId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateOrderStatus(orderId, status);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Customer Profile Providers
final customerProfileProvider = StreamProvider.family<CustomerProfileModel?, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerProfileStream(customerId);
});

final customerProfileNotifierProvider = StateNotifierProvider<CustomerProfileNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerProfileNotifier(repository);
});

class CustomerProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  CustomerProfileNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createProfile(CustomerProfileModel profile) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createCustomerProfile(profile);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile(String customerId, Map<String, dynamic> updates) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCustomerProfile(customerId, updates);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Customer Analytics Providers
final customerAnalyticsProvider = FutureProvider.family<CustomerAnalyticsModel?, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerAnalytics(customerId);
});

final customerAnalyticsNotifierProvider = StateNotifierProvider<CustomerAnalyticsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CustomerAnalyticsNotifier(repository);
});

class CustomerAnalyticsNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  CustomerAnalyticsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> updateAnalytics(String customerId, Map<String, dynamic> analytics) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCustomerAnalytics(customerId, analytics);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Wishlist Providers
final wishlistProvider = StreamProvider.family<List<String>, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getWishlist(customerId);
});

final wishlistNotifierProvider = StateNotifierProvider<WishlistNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return WishlistNotifier(repository);
});

class WishlistNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  WishlistNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addToWishlist(String customerId, String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addToWishlist(customerId, productId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeFromWishlist(String customerId, String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.removeFromWishlist(customerId, productId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Customer Search and Filter Providers
final customerSearchProvider = StreamProvider.family<List<CustomerProfileModel>, Map<String, dynamic>>((ref, filters) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.searchCustomers(
    searchQuery: filters['searchQuery'],
    tier: filters['tier'],
    status: filters['status'],
    city: filters['city'],
    limit: filters['limit'] ?? 20,
  );
});

// Admin Analytics Providers
final customerAnalyticsSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerAnalyticsSummary();
});

final customerSegmentationProvider = FutureProvider<Map<String, int>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerSegmentation();
});

// Bulk Operations Providers
final bulkOperationsNotifierProvider = StateNotifierProvider<BulkOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return BulkOperationsNotifier(repository);
});

class BulkOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  BulkOperationsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> bulkUpdateStatus(List<String> customerIds, CustomerStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.bulkUpdateCustomerStatus(customerIds, status);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> bulkUpdateTier(List<String> customerIds, CustomerTier tier) async {
    state = const AsyncValue.loading();
    try {
      await _repository.bulkUpdateCustomerTier(customerIds, tier);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Notifications Providers
final customerNotificationsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, customerId) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerNotifications(customerId);
});

final notificationsNotifierProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return NotificationsNotifier(repository);
});

class NotificationsNotifier extends StateNotifier<AsyncValue<void>> {
  final CustomerRepository _repository;

  NotificationsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> sendNotification(String customerId, Map<String, dynamic> notification) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendCustomerNotification(customerId, notification);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markNotificationAsRead(notificationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Filter State Providers
final productFiltersProvider = StateProvider<Map<String, String?>>((ref) => {});

final customerSearchFiltersProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// UI State Providers
final selectedProductProvider = StateProvider<ProductModel?>((ref) => null);

final selectedOrderProvider = StateProvider<OrderModel?>((ref) => null);

final selectedCustomerProvider = StateProvider<CustomerProfileModel?>((ref) => null);

final cartItemCountProvider = Provider.family<int, String>((ref, customerId) {
  final cartAsync = ref.watch(cartProvider(customerId));
  return cartAsync.when(
    data: (cart) => cart?.totalItems ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final unreadNotificationsCountProvider = Provider.family<int, String>((ref, customerId) {
  final notificationsAsync = ref.watch(customerNotificationsProvider(customerId));
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !(n['isRead'] ?? false)).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}); 