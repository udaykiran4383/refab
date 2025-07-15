import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/utils/validators.dart';

class ProfileSettingsWidget extends ConsumerStatefulWidget {
  final UserModel user;
  final String title;

  const ProfileSettingsWidget({
    super.key,
    required this.user,
    this.title = 'Account Settings',
  });

  @override
  ConsumerState<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends ConsumerState<ProfileSettingsWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.blue),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: Colors.green),
            title: const Text('Update Phone Number'),
            subtitle: const Text('Change your contact number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUpdatePhoneDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.orange),
            title: const Text('Update Address'),
            subtitle: const Text('Change your address'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUpdateAddressDialog(context),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    print('🔐 [PROFILE_SETTINGS] Change password dialog opened');
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              
              setState(() => _isLoading = true);
              try {
                await _changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    print('🔐 [PROFILE_SETTINGS] Attempting password change');
    
    // Validate new password
    final passwordValidation = Validators.validatePassword(newPassword);
    if (passwordValidation != null) {
      throw Exception(passwordValidation);
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Re-authenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    
    // Change password
    await user.updatePassword(newPassword);
    print('🔐 [PROFILE_SETTINGS] ✅ Password changed successfully');
  }

  void _showUpdatePhoneDialog(BuildContext context) {
    print('📱 [PROFILE_SETTINGS] Update phone dialog opened');
    final phoneController = TextEditingController(text: widget.user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            hintText: 'Enter your phone number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _updatePhone(phoneController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhone(String phone) async {
    print('📱 [PROFILE_SETTINGS] Updating phone number to: $phone');
    
    // Validate phone number
    final phoneValidation = Validators.validatePhone(phone);
    if (phoneValidation != null) {
      throw Exception(phoneValidation);
    }
    
    // Update in Firestore
    await ref.read(authServiceProvider).updateUserProfile({'phone': phone});
    print('📱 [PROFILE_SETTINGS] ✅ Phone number updated successfully');
  }

  void _showUpdateAddressDialog(BuildContext context) {
    print('📍 [PROFILE_SETTINGS] Update address dialog opened');
    final addressController = TextEditingController(text: widget.user.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Address'),
        content: TextField(
          controller: addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
            hintText: 'Enter your full address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _updateAddress(addressController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAddress(String address) async {
    print('📍 [PROFILE_SETTINGS] Updating address to: $address');
    
    // Validate address
    final addressValidation = Validators.validateRequired(address, 'Address');
    if (addressValidation != null) {
      throw Exception(addressValidation);
    }
    
    // Update in Firestore
    await ref.read(authServiceProvider).updateUserProfile({'address': address});
    print('📍 [PROFILE_SETTINGS] ✅ Address updated successfully');
  }
} 