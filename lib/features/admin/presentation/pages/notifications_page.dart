import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../data/models/notification_model.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(allNotificationsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 12),
              Text('Notifications', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showSendNotificationDialog(context),
                icon: const Icon(Icons.send),
                label: const Text('Send Notification'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: notifications.when(
              data: (notificationsList) {
                final filtered = notificationsList.where((n) => _selectedType == 'All' || n.type == _selectedType).toList();
                if (filtered.isEmpty) return const Center(child: Text('No notifications found'));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildNotificationCard(context, filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
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
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
          value: _selectedType,
          items: ['All', 'system', 'pickup', 'order', 'general'].map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase()))).toList(),
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(_getNotificationIcon(notification.type), color: Colors.white),
        ),
        title: Text(
          notification.title,
          style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(notification.timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.type.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: _getNotificationColor(notification.type), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!notification.isRead) const PopupMenuItem(value: 'mark_read', child: Text('Mark as Read')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) => _handleNotificationAction(context, notification, value),
        ),
        onTap: () {
          if (!notification.isRead) {
            ref.read(adminRepositoryProvider).markNotificationAsRead(notification.id);
          }
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'system': return Colors.blue;
      case 'pickup': return Colors.orange;
      case 'order': return Colors.green;
      case 'general': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'system': return Icons.settings;
      case 'pickup': return Icons.local_shipping;
      case 'order': return Icons.shopping_cart;
      case 'general': return Icons.notifications;
      default: return Icons.notifications;
    }
  }

  void _handleNotificationAction(BuildContext context, NotificationModel notification, String action) {
    switch (action) {
      case 'mark_read':
        ref.read(adminRepositoryProvider).markNotificationAsRead(notification.id);
        break;
      case 'delete':
        _showDeleteNotificationDialog(context, notification);
        break;
    }
  }

  void _showSendNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Notification'),
        content: const Text('Notification sending functionality will be implemented here.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showDeleteNotificationDialog(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).deleteNotification(notification.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 