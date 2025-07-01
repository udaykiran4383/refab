import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final UserModel? user;
  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // In a real app, get the user from provider or pass as argument
    final demoUser = user ?? UserModel(
      id: 'demo',
      name: 'Jane Doe',
      email: 'jane.doe@email.com',
      phone: '+91 9876543210',
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 48, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text('Name', style: Theme.of(context).textTheme.labelMedium),
            Text(demoUser.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Email', style: Theme.of(context).textTheme.labelMedium),
            Text(demoUser.email, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Phone', style: Theme.of(context).textTheme.labelMedium),
            Text(demoUser.phone, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text('Role', style: Theme.of(context).textTheme.labelMedium),
            Text(demoUser.role.toString().split('.').last, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement edit profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon!')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 