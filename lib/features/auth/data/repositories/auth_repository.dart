import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient();

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await getCurrentUser();
      }
      return null;
    } catch (e) {
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
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final userData = {
          'id': credential.user!.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'role': role.toString().split('.').last,
          'address': address,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };
        
        try {
          final response = await _apiClient.post('/auth/register', data: userData);
          return UserModel.fromJson(response.data);
        } catch (apiError) {
          // If API fails, create user model from local data
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      try {
        final response = await _apiClient.get('/users/profile');
        return UserModel.fromJson(response.data);
      } catch (apiError) {
        // Fallback to creating user model from Firebase user
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
          phone: user.phoneNumber ?? '',
          role: UserRole.customer, // Default role
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }
}
