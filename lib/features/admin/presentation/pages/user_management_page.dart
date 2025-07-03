import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../providers/admin_provider.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  String _searchQuery = '';
  String _selectedRole = 'All';
  bool _showOnlyActive = true;

  final List<String> _roles = ['All', 'admin', 'customer', 'tailor', 'volunteer'];

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider);

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
              Text(
                'User Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          _buildFilters(),
          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: allUsers.when(
              data: (users) {
                final filteredUsers = _filterUsers(users);
                
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Search
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Role Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedRole,
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Active Filter
                Expanded(
                  child: Row(
                    children: [
                      Checkbox(
                        value: _showOnlyActive,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyActive = value!;
                          });
                        },
                      ),
                      const Text('Active Only'),
                    ],
                  ),
                ),
              ],
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
          child: Icon(
            _getRoleIcon(user.role),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: user.isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
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
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getRoleColor(user.role),
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
              value: 'edit',
              child: Text('Edit'),
            ),
            if (user.isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: Text('Deactivate'),
              )
            else
              const PopupMenuItem(
                value: 'activate',
                child: Text('Activate'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleUserAction(context, user, value),
        ),
        onTap: () => _showUserDetails(context, user),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'customer':
        return Colors.green;
      case 'tailor':
        return Colors.blue;
      case 'volunteer':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'customer':
        return Icons.shopping_bag;
      case 'tailor':
        return Icons.cut;
      case 'volunteer':
        return Icons.volunteer_activism;
      default:
        return Icons.person;
    }
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Search filter
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // Role filter
      final matchesRole = _selectedRole == 'All' || user.role == _selectedRole;

      // Active filter
      final matchesActive = !_showOnlyActive || user.isActive;

      return matchesSearch && matchesRole && matchesActive;
    }).toList();
  }

  void _handleUserAction(BuildContext context, UserModel user, String action) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'activate':
        ref.read(adminProvider.notifier).activateUser(user.id);
        break;
      case 'deactivate':
        ref.read(adminProvider.notifier).deactivateUser(user.id);
        break;
      case 'delete':
        _showDeleteUserDialog(context, user);
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
              Text('Role: ${user.role}'),
              const SizedBox(height: 8),
              Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
              const SizedBox(height: 8),
              Text('Address: ${user.address ?? 'Not provided'}'),
              const SizedBox(height: 8),
              Text('Created: ${_formatDate(user.createdAt)}'),
              if (user.updatedAt != null) ...[
                const SizedBox(height: 8),
                Text('Updated: ${_formatDate(user.updatedAt!)}'),
              ],
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

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: const Text('User creation functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User - ${user.name}'),
        content: const Text('User editing functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminProvider.notifier).deleteUser(user.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 