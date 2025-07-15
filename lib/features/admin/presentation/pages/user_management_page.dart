import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../auth/data/models/user_model.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String _searchQuery = '';
  String _selectedRole = 'All';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(warehouseUsersProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.people,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          _buildFilters(),
          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: users.when(
              data: (usersList) {
                final filteredUsers = _filterUsers(usersList);
                
                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(context, user);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading users: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
                value: _selectedRole,
                items: ['All', 'admin', 'tailor', 'customer', 'volunteer', 'warehouse'].map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name.isNotEmpty ? user.name : 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      color: user.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'activate',
              child: Text('Activate'),
            ),
            const PopupMenuItem(
              value: 'deactivate',
              child: Text('Deactivate'),
            ),
          ],
          onSelected: (value) => _handleUserAction(context, user, value),
        ),
        onTap: () => _showUserDetails(context, user),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.tailor:
        return Colors.blue;
      case UserRole.customer:
        return Colors.green;
      case UserRole.volunteer:
        return Colors.orange;
      case UserRole.warehouse:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Search filter
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());

      // Role filter
      final matchesRole = _selectedRole == 'All' || 
          user.role.name.toLowerCase() == _selectedRole.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();
  }

  void _handleUserAction(BuildContext context, UserModel user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(context, user);
        break;
      case 'activate':
        _activateUser(context, user);
        break;
      case 'deactivate':
        _deactivateUser(context, user);
        break;
    }
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details - ${user.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${user.name}'),
              const SizedBox(height: 8),
              Text('Email: ${user.email}'),
              const SizedBox(height: 8),
              Text('Phone: ${user.phone ?? 'Not provided'}'),
              const SizedBox(height: 8),
              Text(
                'Role: ${user.role.name.toUpperCase()}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
              const SizedBox(height: 8),
              Text('Address: ${user.address ?? 'Not provided'}'),
              const SizedBox(height: 8),
              Text('Created: ${_formatDate(user.createdAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _activateUser(BuildContext context, UserModel user) async {
    try {
      final success = await ref.read(activateWarehouseUserProvider(user.id).future);
      if (success) {
        ref.invalidate(warehouseUsersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} activated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to activate user. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deactivateUser(BuildContext context, UserModel user) async {
    try {
      final success = await ref.read(deactivateWarehouseUserProvider(user.id).future);
      if (success) {
        ref.invalidate(warehouseUsersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} deactivated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to deactivate user. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
} 