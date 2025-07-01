import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../../../services/firestore_service.dart';

final authStateProvider = StreamProvider<UserModel?>((ref) {
  print('🔐 [AUTH_STATE] Initializing auth state provider');
  return FirebaseAuth.instance.authStateChanges().asyncMap((firebaseUser) async {
    print('🔐 [AUTH_STATE] Firebase auth state changed: ${firebaseUser?.uid ?? 'null'}');
    print('🔐 [AUTH_STATE] Firebase user email: ${firebaseUser?.email ?? 'null'}');
    print('🔐 [AUTH_STATE] Firebase user displayName: ${firebaseUser?.displayName ?? 'null'}');
    
    if (firebaseUser != null) {
      print('🔐 [AUTH_STATE] User is authenticated, fetching from Firestore...');
      try {
        final user = await FirestoreService.getUser(firebaseUser.uid);
        if (user != null) {
          print('🔐 [AUTH_STATE] ✅ Successfully loaded user from Firestore: ${user.name}');
          print('🔐 [AUTH_STATE] 🎭 User role from Firestore: ${user.role}');
          return user;
        } else {
          print('🔐 [AUTH_STATE] ⚠️ User not found in Firestore, creating fallback user...');
          // User exists in Firebase Auth but not in Firestore, create and persist fallback
          // Try to determine role from displayName or default to customer
          UserRole defaultRole = UserRole.customer;
          if (firebaseUser.displayName != null) {
            final displayName = firebaseUser.displayName!.toLowerCase();
            if (displayName.contains('tailor')) {
              defaultRole = UserRole.tailor;
            } else if (displayName.contains('admin')) {
              defaultRole = UserRole.admin;
            } else if (displayName.contains('logistics')) {
              defaultRole = UserRole.logistics;
            } else if (displayName.contains('warehouse')) {
              defaultRole = UserRole.warehouse;
            } else if (displayName.contains('volunteer')) {
              defaultRole = UserRole.volunteer;
            }
          }
          print('🔐 [AUTH_STATE] 🎭 Determined fallback role: $defaultRole');
          
          final basicUser = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'User',
            phone: firebaseUser.phoneNumber ?? '',
            role: defaultRole,
            createdAt: DateTime.now(),
          );
          try {
            await FirestoreService.createUser(basicUser);
            print('🔐 [AUTH_STATE] ✅ Persisted fallback user to Firestore.');
          } catch (persistErr) {
            print('🔐 [AUTH_STATE] ❌ Failed to persist fallback user: $persistErr');
          }
          print('🔐 [AUTH_STATE] ✅ Created basic user: ${basicUser.name} (${basicUser.email})');
          print('🔐 [AUTH_STATE] 🎭 Fallback user role: ${basicUser.role}');
          return basicUser;
        }
      } catch (e) {
        print('🔐 [AUTH_STATE] ❌ Firestore error: $e');
        print('🔐 [AUTH_STATE] Creating and persisting basic user from Firebase Auth data...');
        // If Firestore is unavailable, create a basic user from Firebase Auth data and persist it
        UserRole defaultRole = UserRole.customer;
        if (firebaseUser.displayName != null) {
          final displayName = firebaseUser.displayName!.toLowerCase();
          if (displayName.contains('tailor')) {
            defaultRole = UserRole.tailor;
          } else if (displayName.contains('admin')) {
            defaultRole = UserRole.admin;
          } else if (displayName.contains('logistics')) {
            defaultRole = UserRole.logistics;
          } else if (displayName.contains('warehouse')) {
            defaultRole = UserRole.warehouse;
          } else if (displayName.contains('volunteer')) {
            defaultRole = UserRole.volunteer;
          }
        }
        print('🔐 [AUTH_STATE] 🎭 Determined error fallback role: $defaultRole');
        
        final basicUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          phone: firebaseUser.phoneNumber ?? '',
          role: defaultRole,
          createdAt: DateTime.now(),
        );
        try {
          await FirestoreService.createUser(basicUser);
          print('🔐 [AUTH_STATE] ✅ Persisted fallback user to Firestore.');
        } catch (persistErr) {
          print('🔐 [AUTH_STATE] ❌ Failed to persist fallback user: $persistErr');
        }
        print('🔐 [AUTH_STATE] ✅ Created basic user: ${basicUser.name} (${basicUser.email})');
        print('🔐 [AUTH_STATE] 🎭 Error fallback user role: ${basicUser.role}');
        return basicUser;
      }
    }
    print('🔐 [AUTH_STATE] User is not authenticated (null)');
    return null;
  });
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    print('🔐 [SIGN_IN] Attempting sign in for: $email');
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('🔐 [SIGN_IN] ✅ Firebase Auth sign in successful');
      print('🔐 [SIGN_IN] User ID: ${credential.user?.uid}');
      print('🔐 [SIGN_IN] User displayName: ${credential.user?.displayName ?? 'null'}');
      
      if (credential.user != null) {
        try {
          final user = await FirestoreService.getUser(credential.user!.uid);
          if (user != null) {
            print('🔐 [SIGN_IN] ✅ User loaded from Firestore: ${user.name}');
            print('🔐 [SIGN_IN] 🎭 User role from Firestore: ${user.role}');
            return user;
          } else {
            print('🔐 [SIGN_IN] ⚠️ User not found in Firestore, creating fallback user...');
            // User exists in Firebase Auth but not in Firestore, create and persist fallback
            UserRole defaultRole = UserRole.customer;
            if (credential.user!.displayName != null) {
              final displayName = credential.user!.displayName!.toLowerCase();
              if (displayName.contains('tailor')) {
                defaultRole = UserRole.tailor;
              } else if (displayName.contains('admin')) {
                defaultRole = UserRole.admin;
              } else if (displayName.contains('logistics')) {
                defaultRole = UserRole.logistics;
              } else if (displayName.contains('warehouse')) {
                defaultRole = UserRole.warehouse;
              } else if (displayName.contains('volunteer')) {
                defaultRole = UserRole.volunteer;
              }
            }
            print('🔐 [SIGN_IN] 🎭 Determined fallback role: $defaultRole');
            
            final basicUser = UserModel(
              id: credential.user!.uid,
              email: credential.user!.email ?? '',
              name: credential.user!.displayName ?? 'User',
              phone: credential.user!.phoneNumber ?? '',
              role: defaultRole,
              createdAt: DateTime.now(),
            );
            try {
              await FirestoreService.createUser(basicUser);
              print('🔐 [SIGN_IN] ✅ Persisted fallback user to Firestore.');
            } catch (persistErr) {
              print('🔐 [SIGN_IN] ❌ Failed to persist fallback user: $persistErr');
            }
            print('🔐 [SIGN_IN] ✅ Created basic user: ${basicUser.name}');
            print('🔐 [SIGN_IN] 🎭 Fallback user role: ${basicUser.role}');
            return basicUser;
          }
        } catch (e) {
          print('🔐 [SIGN_IN] ⚠️ Firestore error during sign in: $e');
          print('🔐 [SIGN_IN] Creating basic user from Firebase Auth...');
          UserRole defaultRole = UserRole.customer;
          if (credential.user!.displayName != null) {
            final displayName = credential.user!.displayName!.toLowerCase();
            if (displayName.contains('tailor')) {
              defaultRole = UserRole.tailor;
            } else if (displayName.contains('admin')) {
              defaultRole = UserRole.admin;
            } else if (displayName.contains('logistics')) {
              defaultRole = UserRole.logistics;
            } else if (displayName.contains('warehouse')) {
              defaultRole = UserRole.warehouse;
            } else if (displayName.contains('volunteer')) {
              defaultRole = UserRole.volunteer;
            }
          }
          print('🔐 [SIGN_IN] 🎭 Determined error fallback role: $defaultRole');
          
          final basicUser = UserModel(
            id: credential.user!.uid,
            email: credential.user!.email ?? '',
            name: credential.user!.displayName ?? 'User',
            phone: credential.user!.phoneNumber ?? '',
            role: defaultRole,
            createdAt: DateTime.now(),
          );
          try {
            await FirestoreService.createUser(basicUser);
            print('🔐 [SIGN_IN] ✅ Persisted fallback user to Firestore.');
          } catch (persistErr) {
            print('🔐 [SIGN_IN] ❌ Failed to persist fallback user: $persistErr');
          }
          print('🔐 [SIGN_IN] ✅ Created basic user: ${basicUser.name}');
          print('🔐 [SIGN_IN] 🎭 Error fallback user role: ${basicUser.role}');
          return basicUser;
        }
      }
      print('🔐 [SIGN_IN] ❌ No user returned from Firebase Auth');
      return null;
    } on FirebaseAuthException catch (e) {
      print('🔐 [SIGN_IN] ❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      print('🔐 [SIGN_IN] ❌ Throwing user-friendly error: $message');
      throw Exception(message);
    } catch (e) {
      print('🔐 [SIGN_IN] ❌ General error: $e');
      // Handle the PigeonUserDetails error specifically
      if (e.toString().contains('PigeonUserDetails')) {
        print('🔐 [SIGN_IN] ⚠️ PigeonUserDetails error detected, creating basic user');
        // Try to get user from Firebase Auth directly
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          UserRole defaultRole = UserRole.customer;
          if (currentUser.displayName != null) {
            final displayName = currentUser.displayName!.toLowerCase();
            if (displayName.contains('tailor')) {
              defaultRole = UserRole.tailor;
            } else if (displayName.contains('admin')) {
              defaultRole = UserRole.admin;
            } else if (displayName.contains('logistics')) {
              defaultRole = UserRole.logistics;
            } else if (displayName.contains('warehouse')) {
              defaultRole = UserRole.warehouse;
            } else if (displayName.contains('volunteer')) {
              defaultRole = UserRole.volunteer;
            }
          }
          print('🔐 [SIGN_IN] 🎭 Determined PigeonUserDetails fallback role: $defaultRole');
          
          final basicUser = UserModel(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            name: currentUser.displayName ?? 'User',
            phone: currentUser.phoneNumber ?? '',
            role: defaultRole,
            createdAt: DateTime.now(),
          );
          try {
            await FirestoreService.createUser(basicUser);
            print('🔐 [SIGN_IN] ✅ Persisted fallback user to Firestore.');
          } catch (persistErr) {
            print('🔐 [SIGN_IN] ❌ Failed to persist fallback user: $persistErr');
          }
          print('🔐 [SIGN_IN] ✅ Created basic user from current user: ${basicUser.name}');
          print('🔐 [SIGN_IN] 🎭 PigeonUserDetails fallback user role: ${basicUser.role}');
          return basicUser;
        }
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    print('🔐 [REGISTER] Attempting registration for: $email');
    print('🔐 [REGISTER] Name: $name, Phone: $phone, Role: $role');
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('🔐 [REGISTER] ✅ Firebase Auth user creation successful');
      print('🔐 [REGISTER] User ID: ${credential.user?.uid}');
      if (credential.user != null) {
        // Set displayName
        try {
          await credential.user!.updateDisplayName(name);
          print('🔐 [REGISTER] ✅ displayName set to $name');
        } catch (displayNameErr) {
          print('🔐 [REGISTER] ⚠️ Failed to set displayName: $displayNameErr');
        }
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );
        print('🔐 [REGISTER] Created UserModel: ${user.name} (${user.email})');
        try {
          print('🔐 [REGISTER] Saving user to Firestore...');
          await FirestoreService.createUser(user);
          print('🔐 [REGISTER] ✅ User saved to Firestore successfully');
        } catch (e) {
          print('🔐 [REGISTER] ⚠️ Firestore error during registration: $e');
          print('🔐 [REGISTER] User created in Firebase Auth, but Firestore failed');
        }
        print('🔐 [REGISTER] ✅ Registration completed successfully');
        return user;
      }
      print('🔐 [REGISTER] ❌ No user returned from Firebase Auth');
      return null;
    } on FirebaseAuthException catch (e) {
      print('🔐 [REGISTER] ❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account with this email already exists. Please sign in instead.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Please choose a stronger password.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      print('🔐 [REGISTER] ❌ Throwing user-friendly error: $message');
      throw Exception(message);
    } catch (e) {
      print('🔐 [REGISTER] ❌ General error: $e');
      if (e.toString().contains('PigeonUserDetails')) {
        print('🔐 [REGISTER] ⚠️ PigeonUserDetails error detected, checking if user was created');
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('🔐 [REGISTER] ✅ User was created successfully despite PigeonUserDetails error');
          try {
            await currentUser.updateDisplayName(name);
            print('🔐 [REGISTER] ✅ displayName set to $name (recovery)');
          } catch (displayNameErr) {
            print('🔐 [REGISTER] ⚠️ Failed to set displayName (recovery): $displayNameErr');
          }
          final user = UserModel(
            id: currentUser.uid,
            email: email,
            name: name,
            phone: phone,
            role: role,
            createdAt: DateTime.now(),
          );
          try {
            await FirestoreService.createUser(user);
            print('🔐 [REGISTER] ✅ User saved to Firestore after recovery');
          } catch (firestoreError) {
            print('🔐 [REGISTER] ⚠️ Firestore still failed: $firestoreError');
          }
          return user;
        }
      }
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    print('🔐 [SIGN_OUT] Attempting sign out...');
    try {
      await _auth.signOut();
      print('🔐 [SIGN_OUT] ✅ Sign out successful');
    } catch (e) {
      print('🔐 [SIGN_OUT] ❌ Sign out error: $e');
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> deleteUser() async {
    print('🔐 [DELETE_USER] Attempting to delete current user...');
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('🔐 [DELETE_USER] Current user: ${user.email} (${user.uid})');
        
        // First delete from Firestore
        try {
          print('🔐 [DELETE_USER] Deleting from Firestore...');
          await FirestoreService.deleteUser(user.uid);
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
