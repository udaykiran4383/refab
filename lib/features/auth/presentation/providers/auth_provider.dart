import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges.asyncMap((firebaseUser) async {
    if (firebaseUser != null) {
      // Fetch user profile from backend
      try {
        return await authRepository.getCurrentUser();
      } catch (e) {
        return null;
      }
    }
    return null;
  });
});

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<UserModel?>>((ref) {
  return LoginNotifier(ref.watch(authRepositoryProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;

  LoginNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        address: address,
      );
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AsyncValue.data(null);
  }
}
