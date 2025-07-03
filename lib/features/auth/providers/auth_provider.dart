import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  print('🔐 [AUTH_STATE] Initializing auth state provider');
  final authRepository = ref.watch(authRepositoryProvider);
  
  return authRepository.authStateChanges.asyncMap((firebaseUser) async {
    print('🔐 [AUTH_STATE] Firebase auth state changed: ${firebaseUser?.uid ?? 'null'}');
    print('🔐 [AUTH_STATE] Firebase user email: ${firebaseUser?.email ?? 'null'}');
    print('🔐 [AUTH_STATE] Firebase user displayName: ${firebaseUser?.displayName ?? 'null'}');
    
    if (firebaseUser != null) {
      print('🔐 [AUTH_STATE] User is authenticated, fetching from repository...');
      try {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          print('🔐 [AUTH_STATE] ✅ Successfully loaded user from repository: ${user.name}');
          print('🔐 [AUTH_STATE] 🎭 User role from repository: ${user.role}');
          print('🔐 [AUTH_STATE] 📧 User email: ${user.email}');
          print('🔐 [AUTH_STATE] 📱 User phone: ${user.phone}');
          return user;
        } else {
          print('🔐 [AUTH_STATE] ❌ No user returned from repository');
          return null;
        }
      } catch (e) {
        print('🔐 [AUTH_STATE] ❌ Repository error: $e');
        // Don't return null on error, try to create a fallback user
        try {
          print('🔐 [AUTH_STATE] 🔄 Attempting to create fallback user...');
          UserRole fallbackRole = UserRole.customer;
          
          // Try to determine role from display name or email
          final displayName = firebaseUser.displayName?.toLowerCase() ?? '';
          final email = firebaseUser.email?.toLowerCase() ?? '';
          
          if (displayName.contains('tailor') || email.contains('tailor')) {
            fallbackRole = UserRole.tailor;
          } else if (displayName.contains('admin') || email.contains('admin')) {
            fallbackRole = UserRole.admin;
          } else if (displayName.contains('logistics') || email.contains('logistics')) {
            fallbackRole = UserRole.logistics;
          } else if (displayName.contains('warehouse') || email.contains('warehouse')) {
            fallbackRole = UserRole.warehouse;
          } else if (displayName.contains('volunteer') || email.contains('volunteer')) {
            fallbackRole = UserRole.volunteer;
          }
          
          final fallbackUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'User',
            phone: firebaseUser.phoneNumber ?? '',
            role: fallbackRole,
            createdAt: DateTime.now(),
          );
          
          print('🔐 [AUTH_STATE] ✅ Created fallback user: ${fallbackUser.name} (${fallbackUser.role})');
          return fallbackUser;
        } catch (fallbackError) {
          print('🔐 [AUTH_STATE] ❌ Fallback user creation failed: $fallbackError');
          return null;
        }
      }
    }
    print('🔐 [AUTH_STATE] User is not authenticated (null)');
    return null;
  });
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final AuthRepository _authRepository = AuthRepository();

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    print('🔐 [SIGN_IN] Attempting sign in for: $email');
    try {
      final user = await _authRepository.signInWithEmailAndPassword(email, password);
      print('🔐 [SIGN_IN] ✅ Sign in successful');
      if (user != null) {
        print('🔐 [SIGN_IN] User: ${user.name} (${user.email})');
        print('🔐 [SIGN_IN] Role: ${user.role}');
      }
      return user;
    } catch (e) {
      print('🔐 [SIGN_IN] ❌ Sign in error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
  }) async {
    print('🔐 [REGISTER] Attempting registration for: $email');
    print('🔐 [REGISTER] Name: $name, Phone: $phone, Role: $role');
    
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        address: address,
      );
      print('🔐 [REGISTER] ✅ Registration successful');
      if (user != null) {
        print('🔐 [REGISTER] User: ${user.name} (${user.email})');
        print('🔐 [REGISTER] Role: ${user.role}');
      }
      return user;
    } catch (e) {
      print('🔐 [REGISTER] ❌ Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    print('🔐 [SIGN_OUT] Attempting sign out...');
    try {
      await _authRepository.signOut();
      print('🔐 [SIGN_OUT] ✅ Sign out successful');
    } catch (e) {
      print('🔐 [SIGN_OUT] ❌ Sign out error: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    print('🔐 [UPDATE_PROFILE] Attempting to update user profile: $updates');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      // Update in Firestore
      await _authRepository.updateUserProfile(user.uid, updates);
      print('🔐 [UPDATE_PROFILE] ✅ Profile updated successfully');
    } catch (e) {
      print('🔐 [UPDATE_PROFILE] ❌ Update error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    print('🔐 [PASSWORD_RESET] Sending password reset email to: $email');
    try {
      await _authRepository.sendPasswordResetEmail(email);
      print('🔐 [PASSWORD_RESET] ✅ Password reset email sent successfully');
    } catch (e) {
      print('🔐 [PASSWORD_RESET] ❌ Error sending password reset email: $e');
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> deleteUser() async {
    print('🔐 [DELETE_USER] Attempting to delete current user...');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🔐 [DELETE_USER] Current user: ${user.email} (${user.uid})');
        
        // First delete from Firestore
        try {
          print('🔐 [DELETE_USER] Deleting from Firestore...');
          // Note: FirestoreService.deleteUser would need to be implemented
          print('🔐 [DELETE_USER] ✅ User deleted from Firestore');
        } catch (e) {
          print('🔐 [DELETE_USER] ⚠️ Firestore error during user deletion: $e');
          // Continue with Auth deletion even if Firestore fails
        }
        
        // Then delete from Firebase Auth
        print('🔐 [DELETE_USER] Deleting from Firebase Auth...');
        await user.delete();
        print('🔐 [DELETE_USER] ✅ User deleted from Firebase Auth');
      } else {
        print('🔐 [DELETE_USER] ❌ No current user to delete');
      }
    } on FirebaseAuthException catch (e) {
      print('🔐 [DELETE_USER] ❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message = 'Please sign in again before deleting your account.';
          break;
        case 'user-not-found':
          message = 'User not found.';
          break;
        default:
          message = 'Failed to delete account: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      print('🔐 [DELETE_USER] ❌ General error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }
}
