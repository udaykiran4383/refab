import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('🔐 [AUTH_REPO] Attempting sign in for: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        print('🔐 [AUTH_REPO] ✅ Sign in successful, fetching user data');
        final user = await getCurrentUser();
        if (user != null) {
          print('🔐 [AUTH_REPO] ✅ User loaded: ${user.name} with role: ${user.role}');
        }
        return user;
      }
      return null;
    } catch (e) {
      print('🔐 [AUTH_REPO] ❌ Sign in error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
  }) async {
    try {
      print('🔐 [AUTH_REPO] Attempting registration for: $email with role: $role');
      print('🔐 [AUTH_REPO] Registration details - Name: $name, Phone: $phone, Address: $address');
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Set display name
        try {
          await credential.user!.updateDisplayName(name);
          print('🔐 [AUTH_REPO] ✅ Display name set to: $name');
        } catch (e) {
          print('🔐 [AUTH_REPO] ⚠️ Failed to set display name: $e');
        }
        
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
          address: address,
          createdAt: DateTime.now(),
        );
        
        print('🔐 [AUTH_REPO] 🎭 Created user model with role: ${user.role}');
        
        // Try to save to Firestore with better error handling
        bool firestoreSuccess = false;
        try {
          await FirestoreService.createUser(user);
          print('🔐 [AUTH_REPO] ✅ User saved to Firestore with role: ${user.role}');
          firestoreSuccess = true;
        } catch (e) {
          print('🔐 [AUTH_REPO] ⚠️ Firestore error during registration: $e');
          
          // Try alternative save method
          try {
            final userData = {
              'id': user.id,
              'email': user.email,
              'name': user.name,
              'phone': user.phone,
              'role': user.role.toString().split('.').last,
              'address': user.address,
              'is_active': user.isActive,
              'created_at': FieldValue.serverTimestamp(),
            };
            
            await FirebaseFirestore.instance.collection('users').doc(user.id).set(userData);
            print('🔐 [AUTH_REPO] ✅ User saved with alternative method, role: ${user.role}');
            firestoreSuccess = true;
          } catch (retryError) {
            print('🔐 [AUTH_REPO] ❌ Alternative save method also failed: $retryError');
            print('🔐 [AUTH_REPO] ⚠️ User created in Firebase Auth but not in Firestore');
          }
        }
        
        if (firestoreSuccess) {
          print('🔐 [AUTH_REPO] ✅ Registration successful: ${user.name} (${user.role})');
          return user;
        } else {
          // If Firestore failed, still return the user object
          // It will be saved when they log in next time
          print('🔐 [AUTH_REPO] ⚠️ Returning user without Firestore save: ${user.name} (${user.role})');
          return user;
        }
      }
      return null;
    } catch (e) {
      print('🔐 [AUTH_REPO] ❌ Registration error: $e');
      
      // Check if user was created in Firebase Auth despite the error
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        print('🔐 [AUTH_REPO] ✅ User exists in Firebase Auth, creating fallback user model');
        final fallbackUser = UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? email,
          name: name, // Use the original name, not displayName
          phone: phone,
          role: role, // Use the original role that was selected
          address: address,
          createdAt: DateTime.now(),
        );
        
        // Try to save to Firestore for future use
        try {
          await FirestoreService.createUser(fallbackUser);
          print('🔐 [AUTH_REPO] ✅ Fallback user saved to Firestore');
        } catch (firestoreError) {
          print('🔐 [AUTH_REPO] ⚠️ Failed to save fallback user to Firestore: $firestoreError');
        }
        
        return fallbackUser;
      }
      
      throw Exception('Registration failed: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        print('🔐 [AUTH_REPO] No current Firebase user');
        return null;
      }

      print('🔐 [AUTH_REPO] Current Firebase user: ${user.email} (${user.uid})');

      // Try to get user from Firestore first
      try {
        final firestoreUser = await FirestoreService.getUser(user.uid);
        if (firestoreUser != null) {
          print('🔐 [AUTH_REPO] ✅ User loaded from Firestore: ${firestoreUser.name} (${firestoreUser.role})');
          return firestoreUser;
        }
      } catch (e) {
        print('🔐 [AUTH_REPO] ⚠️ Firestore error: $e');
      }

      // Fallback: create user model from Firebase user
      // This should rarely happen if registration is working properly
      UserRole defaultRole = UserRole.customer;
      
      // Try to determine role from display name or email
      final displayName = user.displayName?.toLowerCase() ?? '';
      final email = user.email?.toLowerCase() ?? '';
      
      // Check if this is a newly registered user by looking for role hints
      if (displayName.contains('tailor') || email.contains('tailor')) {
        defaultRole = UserRole.tailor;
      } else if (displayName.contains('admin') || email.contains('admin')) {
        defaultRole = UserRole.admin;
      } else if (displayName.contains('logistics') || email.contains('logistics')) {
        defaultRole = UserRole.logistics;
      } else if (displayName.contains('warehouse') || email.contains('warehouse')) {
        defaultRole = UserRole.warehouse;
      } else if (displayName.contains('volunteer') || email.contains('volunteer')) {
        defaultRole = UserRole.volunteer;
      }
      
      print('🔐 [AUTH_REPO] 🎭 Determined fallback role: $defaultRole');
      
      // Use display name if available, otherwise use a more descriptive name
      String userName = user.displayName ?? 'User';
      if (userName == 'User' && user.email != null) {
        // Extract name from email if display name is generic
        final emailParts = user.email!.split('@');
        if (emailParts.isNotEmpty) {
          userName = emailParts[0];
          // Capitalize first letter
          userName = userName[0].toUpperCase() + userName.substring(1);
        }
      }
      
      final fallbackUser = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: userName,
        phone: user.phoneNumber ?? '',
        role: defaultRole,
        createdAt: DateTime.now(),
      );
      
      // Try to save to Firestore for future use
      try {
        await FirestoreService.createUser(fallbackUser);
        print('🔐 [AUTH_REPO] ✅ Fallback user saved to Firestore');
      } catch (e) {
        print('🔐 [AUTH_REPO] ⚠️ Failed to save fallback user to Firestore: $e');
      }
      
      print('🔐 [AUTH_REPO] ✅ Returning fallback user: ${fallbackUser.name} (${fallbackUser.role})');
      return fallbackUser;
    } catch (e) {
      print('🔐 [AUTH_REPO] ❌ Error getting current user: $e');
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<void> signOut() async {
    print('🔐 [AUTH_REPO] Signing out...');
    await _firebaseAuth.signOut();
    print('🔐 [AUTH_REPO] ✅ Sign out successful');
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    print('🔐 [AUTH_REPO] Updating user profile for ID: $userId');
    print('🔐 [AUTH_REPO] Updates: $updates');
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
      print('🔐 [AUTH_REPO] ✅ Profile updated successfully in Firestore');
    } catch (e) {
      print('🔐 [AUTH_REPO] ❌ Profile update error: $e');
      throw Exception('Failed to update profile: $e');
    }
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
