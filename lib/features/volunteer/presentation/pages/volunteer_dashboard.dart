import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/hour_logging_card.dart';
import '../widgets/progress_card.dart';

class VolunteerDashboard extends ConsumerWidget {
  final UserModel user;

  const VolunteerDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer - ${user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              // TODO: View certificates
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificates coming soon!')),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'certificates',
                child: Text('Certificates'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(loginProvider.notifier).signOut();
              } else if (value == 'profile') {
                // TODO: Navigate to profile page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile page coming soon!')),
                );
              } else if (value == 'certificates') {
                // TODO: Navigate to certificates page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Certificates page coming soon!')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ProgressCard(
              totalHours: 42,
              targetHours: 100,
              tasksCompleted: 18,
              certificatesEarned: 2,
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Hours Logged',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Replace with actual data
              itemBuilder: (context, index) {
                return HourLoggingCard(
                  date: DateTime.now().subtract(Duration(days: index)),
                  task: 'Task ${index + 1}',
                  hours: 2.5 + index,
                  status: 'Approved',
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showLogHoursDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Hours'),
      ),
    );
  }

  void _showLogHoursDialog(BuildContext context) {
    final hoursController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'General';
    
    final categories = ['General', 'Fabric Sorting', 'Data Entry', 'Quality Check', 'Packaging', 'Training'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Log Volunteer Hours'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Task Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hours Worked',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Submit hours to backend
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hours logged successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Log Hours'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
