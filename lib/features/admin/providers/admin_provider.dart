import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/admin_repository.dart';
import '../data/models/analytics_model.dart';
import '../data/models/system_config_model.dart';
import '../../auth/data/models/user_model.dart';

// Repository Provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// Analytics Providers
final systemAnalyticsProvider = FutureProvider<AnalyticsModel>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getSystemAnalytics();
});

final analyticsStreamProvider = StreamProvider<AnalyticsModel>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  // Create a stream that refreshes analytics every 30 seconds
  return Stream.periodic(const Duration(seconds: 30), (_) => null)
      .asyncMap((_) => repository.getSystemAnalytics());
});

// User Management Providers
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllUsers();
});

final usersByRoleProvider = StreamProvider.family<List<UserModel>, String>((ref, role) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getUsersByRole(role);
});

final userProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getUser(userId);
});

// System Configuration Providers
final systemConfigProvider = FutureProvider<SystemConfigModel>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getSystemConfig();
});

final systemConfigStreamProvider = StreamProvider<SystemConfigModel>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  // Listen to system config changes
  return FirebaseFirestore.instance
      .collection('systemConfig')
      .doc('main')
      .snapshots()
      .map((doc) => doc.exists 
          ? SystemConfigModel.fromJson(doc.data()!) 
          : SystemConfigModel.defaultConfig());
});

// Admin State Provider
class AdminState {
  final bool isLoading;
  final String? error;
  final AnalyticsModel? analytics;
  final SystemConfigModel? systemConfig;
  final List<UserModel> users;
  final Map<String, dynamic>? currentReport;

  AdminState({
    this.isLoading = false,
    this.error,
    this.analytics,
    this.systemConfig,
    this.users = const [],
    this.currentReport,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    AnalyticsModel? analytics,
    SystemConfigModel? systemConfig,
    List<UserModel>? users,
    Map<String, dynamic>? currentReport,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      analytics: analytics ?? this.analytics,
      systemConfig: systemConfig ?? this.systemConfig,
      users: users ?? this.users,
      currentReport: currentReport ?? this.currentReport,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(AdminState());

  // Load Analytics
  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final analytics = await _repository.getSystemAnalytics();
      state = state.copyWith(analytics: analytics, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Load System Config
  Future<void> loadSystemConfig() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final config = await _repository.getSystemConfig();
      state = state.copyWith(systemConfig: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Update System Config
  Future<void> updateSystemConfig(SystemConfigModel config) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateSystemConfig(config);
      state = state.copyWith(systemConfig: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // User Management
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateUser(userId, updates);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deactivateUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deactivateUser(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> activateUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.activateUser(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteUser(userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Notifications
  Future<void> sendSystemNotification({
    required String title,
    required String message,
    required List<String> targetRoles,
    String? targetUserId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.sendSystemNotification(
        title: title,
        message: message,
        targetRoles: targetRoles,
        targetUserId: targetUserId,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Reports
  Future<void> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final report = await _repository.generateReport(
        reportType: reportType,
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(currentReport: report, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear Report
  void clearReport() {
    state = state.copyWith(currentReport: null);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return AdminNotifier(repository);
});

// Convenience Providers
final adminAnalyticsProvider = Provider<AnalyticsModel?>((ref) {
  return ref.watch(adminProvider).analytics;
});

final adminSystemConfigProvider = Provider<SystemConfigModel?>((ref) {
  return ref.watch(adminProvider).systemConfig;
});

final adminUsersProvider = Provider<List<UserModel>>((ref) {
  return ref.watch(adminProvider).users;
});

final adminCurrentReportProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(adminProvider).currentReport;
});

final adminIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider).isLoading;
});

final adminErrorProvider = Provider<String?>((ref) {
  return ref.watch(adminProvider).error;
}); 