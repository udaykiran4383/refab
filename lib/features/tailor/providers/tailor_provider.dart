import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/tailor_repository.dart';
import '../data/models/pickup_request_model.dart';
import '../data/models/tailor_profile_model.dart';
import '../data/models/tailor_analytics_model.dart';

// Repository Provider
final tailorRepositoryProvider = Provider<TailorRepository>((ref) {
  return TailorRepository();
});

// Pickup Requests Providers
final pickupRequestsProvider = StreamProvider.family<List<PickupRequestModel>, String>((ref, tailorId) {
  print('📦 [PICKUP_PROVIDER] Getting pickup requests for tailor: $tailorId');
  final repository = ref.read(tailorRepositoryProvider);
  return repository.getPickupRequests(tailorId).map((requests) {
    print('📦 [PICKUP_PROVIDER] Found ${requests.length} pickup requests for tailor $tailorId');
    for (final request in requests) {
      print('📦 [PICKUP_PROVIDER] Request: ${request.id} - ${request.customerName} - ${request.fabricTypeDisplayName}');
    }
    return requests;
  });
});

final pickupRequestsByStatusProvider = StreamProvider.family<List<PickupRequestModel>, ({String tailorId, PickupStatus status})>((ref, params) {
  final repository = ref.read(tailorRepositoryProvider);
  return repository.getPickupRequestsByStatus(params.tailorId, params.status);
});

final pickupRequestProvider = FutureProvider.family<PickupRequestModel?, String>((ref, requestId) async {
  final repository = ref.read(tailorRepositoryProvider);
  return await repository.getPickupRequest(requestId);
});

// Profile Providers
final tailorProfileProvider = FutureProvider.family<TailorProfileModel?, String>((ref, tailorId) async {
  final repository = ref.read(tailorRepositoryProvider);
  return await repository.getTailorProfile(tailorId);
});

// Analytics Providers
final tailorAnalyticsProvider = FutureProvider.family<TailorAnalyticsModel, ({String tailorId, DateTime? startDate, DateTime? endDate})>((ref, params) async {
  print('📊 [ANALYTICS_PROVIDER] Getting analytics for tailor: ${params.tailorId}');
  print('📊 [ANALYTICS_PROVIDER] Start date: ${params.startDate}');
  print('📊 [ANALYTICS_PROVIDER] End date: ${params.endDate}');
  
  final repository = ref.read(tailorRepositoryProvider);
  try {
    final analytics = await repository.getTailorAnalytics(params.tailorId, startDate: params.startDate, endDate: params.endDate);
    print('📊 [ANALYTICS_PROVIDER] ✅ Analytics loaded successfully');
    return analytics;
  } catch (e) {
    print('📊 [ANALYTICS_PROVIDER] ❌ Error loading analytics: $e');
    rethrow;
  }
});

final performanceMetricsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, tailorId) async {
  final repository = ref.read(tailorRepositoryProvider);
  return await repository.getPerformanceMetrics(tailorId);
});

// Notifications Provider
final tailorNotificationsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, tailorId) {
  final repository = ref.read(tailorRepositoryProvider);
  return repository.getNotifications(tailorId);
});

// Scheduled Pickups Provider
final scheduledPickupsProvider = StreamProvider.family<List<PickupRequestModel>, ({String tailorId, DateTime date})>((ref, params) {
  final repository = ref.read(tailorRepositoryProvider);
  return repository.getScheduledPickups(params.tailorId, params.date);
});

// Top Customers Provider
final topCustomersProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String tailorId, int limit})>((ref, params) async {
  final repository = ref.read(tailorRepositoryProvider);
  return await repository.getTopCustomers(params.tailorId, limit: params.limit);
});

// Search Provider
final searchPickupRequestsProvider = StreamProvider.family<List<PickupRequestModel>, ({
  String tailorId,
  String? searchQuery,
  PickupStatus? status,
  FabricType? fabricType,
  DateTime? startDate,
  DateTime? endDate,
})>((ref, params) {
  final repository = ref.read(tailorRepositoryProvider);
  return repository.searchPickupRequests(
    params.tailorId,
    searchQuery: params.searchQuery,
    status: params.status,
    fabricType: params.fabricType,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Tailor State Notifier
class TailorState {
  final bool isLoading;
  final String? error;
  final List<PickupRequestModel> pickupRequests;
  final TailorProfileModel? profile;
  final TailorAnalyticsModel? analytics;
  final List<Map<String, dynamic>> notifications;
  final Map<String, dynamic>? performanceMetrics;
  final List<Map<String, dynamic>> topCustomers;

  TailorState({
    this.isLoading = false,
    this.error,
    this.pickupRequests = const [],
    this.profile,
    this.analytics,
    this.notifications = const [],
    this.performanceMetrics,
    this.topCustomers = const [],
  });

  TailorState copyWith({
    bool? isLoading,
    String? error,
    List<PickupRequestModel>? pickupRequests,
    TailorProfileModel? profile,
    TailorAnalyticsModel? analytics,
    List<Map<String, dynamic>>? notifications,
    Map<String, dynamic>? performanceMetrics,
    List<Map<String, dynamic>>? topCustomers,
  }) {
    return TailorState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pickupRequests: pickupRequests ?? this.pickupRequests,
      profile: profile ?? this.profile,
      analytics: analytics ?? this.analytics,
      notifications: notifications ?? this.notifications,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      topCustomers: topCustomers ?? this.topCustomers,
    );
  }
}

class TailorNotifier extends StateNotifier<TailorState> {
  final TailorRepository _repository;

  TailorNotifier(this._repository) : super(TailorState());

  // Pickup Request Management
  Future<void> createPickupRequest(PickupRequestModel request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createPickupRequest(request);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updatePickupStatus(String requestId, PickupStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePickupStatus(requestId, status);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updatePickupProgress(String requestId, String progress) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePickupProgress(requestId, progress);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // New method for updating work progress using the enum
  Future<void> updateWorkProgress(String requestId, TailorWorkProgress workProgress) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateWorkProgress(requestId, workProgress);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updatePickupRequest(String requestId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePickupRequest(requestId, updates);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> cancelPickupRequest(String requestId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.cancelPickupRequest(requestId, reason);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> rejectPickupRequest(String requestId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.rejectPickupRequest(requestId, reason);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> schedulePickup(String requestId, DateTime scheduledDate) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.schedulePickup(requestId, scheduledDate);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> bulkUpdateStatus(List<String> requestIds, PickupStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.bulkUpdateStatus(requestIds, status);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Profile Management
  Future<void> createTailorProfile(TailorProfileModel profile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createTailorProfile(profile);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateTailorProfile(String tailorId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateTailorProfile(tailorId, updates);
      if (state.profile != null) {
        final updatedProfile = state.profile!.copyWith(
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(profile: updatedProfile, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateAvailabilityStatus(String tailorId, AvailabilityStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateAvailabilityStatus(tailorId, status);
      if (state.profile != null) {
        final updatedProfile = state.profile!.copyWith(
          availabilityStatus: status,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(profile: updatedProfile, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Analytics
  Future<void> loadAnalytics(String tailorId, {DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final analytics = await _repository.getTailorAnalytics(tailorId, startDate: startDate, endDate: endDate);
      state = state.copyWith(analytics: analytics, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadPerformanceMetrics(String tailorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final metrics = await _repository.getPerformanceMetrics(tailorId);
      state = state.copyWith(performanceMetrics: metrics, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadTopCustomers(String tailorId, {int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final customers = await _repository.getTopCustomers(tailorId, limit: limit);
      state = state.copyWith(topCustomers: customers, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Notifications
  Future<void> sendNotification(String tailorId, String title, String message) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.sendNotification(tailorId, title, message);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.markNotificationAsRead(notificationId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh Data
  Future<void> refreshData(String tailorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([
        loadAnalytics(tailorId),
        loadPerformanceMetrics(tailorId),
        loadTopCustomers(tailorId),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final tailorProvider = StateNotifierProvider<TailorNotifier, TailorState>((ref) {
  final repository = ref.read(tailorRepositoryProvider);
  return TailorNotifier(repository);
});

// Filter Providers
final pickupRequestsFilterProvider = StateProvider<PickupStatus?>((ref) => null);
final fabricTypeFilterProvider = StateProvider<FabricType?>((ref) => null);
final dateRangeFilterProvider = StateProvider<({DateTime? startDate, DateTime? endDate})>((ref) => (startDate: null, endDate: null));
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Pickup Requests Provider
final filteredPickupRequestsProvider = StreamProvider.family<List<PickupRequestModel>, String>((ref, tailorId) {
  final searchQuery = ref.watch(searchQueryProvider);
  final statusFilter = ref.watch(pickupRequestsFilterProvider);
  final fabricTypeFilter = ref.watch(fabricTypeFilterProvider);
  final dateRange = ref.watch(dateRangeFilterProvider);
  
  final repository = ref.read(tailorRepositoryProvider);
  return repository.searchPickupRequests(
    tailorId,
    searchQuery: searchQuery.isEmpty ? null : searchQuery,
    status: statusFilter,
    fabricType: fabricTypeFilter,
    startDate: dateRange.startDate,
    endDate: dateRange.endDate,
  );
});

// Statistics Providers
final pickupStatisticsProvider = Provider.family<Map<String, dynamic>, List<PickupRequestModel>>((ref, requests) {
  final total = requests.length;
  final pending = requests.where((r) => r.isPending).length;
  final inProgress = requests.where((r) => r.isInProgress).length;
  final completed = requests.where((r) => r.isCompleted).length;
  final cancelled = requests.where((r) => r.isCancelled).length;
  final totalWeight = requests.where((r) => r.isCompleted).fold<double>(0, (sum, r) => sum + r.actualWeight);
  final totalValue = requests.where((r) => r.isCompleted).fold<double>(0, (sum, r) => sum + r.actualValue);

  return {
    'total': total,
    'pending': pending,
    'inProgress': inProgress,
    'completed': completed,
    'cancelled': cancelled,
    'totalWeight': totalWeight,
    'totalValue': totalValue,
    'completionRate': total > 0 ? (completed / total * 100).round() : 0,
  };
}); 