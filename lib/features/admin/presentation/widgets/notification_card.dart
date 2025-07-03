import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(allNotificationsProvider);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notifications.when(
                data: (notificationsList) {
                  if (notificationsList.isEmpty) {
                    return const Center(
                      child: Text('No notifications found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: notificationsList.length,
                    itemBuilder: (context, index) {
                      final notification = notificationsList[index];
                      return _buildNotificationTile(context, ref, notification);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading notifications: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  notification.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getNotificationColor(notification.type),
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
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Text('Mark as Read'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleNotificationAction(
            context,
            ref,
            notification,
            value,
          ),
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
      case 'system':
        return Colors.blue;
      case 'pickup':
        return Colors.orange;
      case 'order':
        return Colors.green;
      case 'general':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'system':
        return Icons.settings;
      case 'pickup':
        return Icons.local_shipping;
      case 'order':
        return Icons.shopping_cart;
      case 'general':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationAction(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
    String action,
  ) {
    switch (action) {
      case 'mark_read':
        ref.read(adminRepositoryProvider).markNotificationAsRead(notification.id);
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(adminRepositoryProvider).deleteNotification(notification.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}

// Provider for all notifications
final allNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllNotifications();
}); 