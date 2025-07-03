import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class PickupRequestsPage extends ConsumerStatefulWidget {
  const PickupRequestsPage({super.key});

  @override
  ConsumerState<PickupRequestsPage> createState() => _PickupRequestsPageState();
}

class _PickupRequestsPageState extends ConsumerState<PickupRequestsPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final pickups = ref.watch(allPickupRequestsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 12),
              Text('Pickup Requests', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: pickups.when(
              data: (pickupsList) {
                final filtered = pickupsList.where((p) => _selectedStatus == 'All' || p['status'] == _selectedStatus).toList();
                if (filtered.isEmpty) return const Center(child: Text('No pickup requests found'));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildPickupCard(context, filtered[index]),
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
          decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
          value: _selectedStatus,
          items: ['All', 'pending', 'assigned', 'completed', 'cancelled'].map((status) => DropdownMenuItem(value: status, child: Text(status.toUpperCase()))).toList(),
          onChanged: (value) => setState(() => _selectedStatus = value!),
        ),
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, Map<String, dynamic> pickup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: _getStatusColor(pickup['status']), child: Icon(Icons.local_shipping, color: Colors.white)),
        title: Text('Pickup #${pickup['id']?.toString().substring(0, 8) ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${pickup['customerName'] ?? 'Unknown'}'),
            Text('Weight: ${pickup['estimatedWeight'] ?? 'N/A'} kg'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _getStatusColor(pickup['status']).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Text(pickup['status']?.toString().toUpperCase() ?? 'UNKNOWN', style: TextStyle(fontSize: 10, color: _getStatusColor(pickup['status']), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'update_status', child: Text('Update Status')),
          ],
          onSelected: (value) => _handlePickupAction(context, pickup, value),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'assigned': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _handlePickupAction(BuildContext context, Map<String, dynamic> pickup, String action) {
    switch (action) {
      case 'view':
        _showPickupDetails(context, pickup);
        break;
      case 'update_status':
        _showUpdateStatusDialog(context, pickup);
        break;
    }
  }

  void _showPickupDetails(BuildContext context, Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pickup Details - #${pickup['id']?.toString().substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${pickup['customerName']}'),
            Text('Weight: ${pickup['estimatedWeight']} kg'),
            Text('Status: ${pickup['status']}'),
            Text('Created: ${_formatDate(pickup['createdAt'])}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Map<String, dynamic> pickup) {
    String selectedStatus = pickup['status'] ?? 'pending';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          items: ['pending', 'assigned', 'completed', 'cancelled'].map((status) => DropdownMenuItem(value: status, child: Text(status.toUpperCase()))).toList(),
          onChanged: (value) => selectedStatus = value!,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).updatePickupStatus(pickup['id'], selectedStatus);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}

final allPickupRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final repository = ref.read(adminRepositoryProvider);
  return repository.getAllPickupRequests();
}); 