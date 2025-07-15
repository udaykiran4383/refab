import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequestsPage extends ConsumerStatefulWidget {
  const PickupRequestsPage({super.key});

  @override
  ConsumerState<PickupRequestsPage> createState() => _PickupRequestsPageState();
}

class _PickupRequestsPageState extends ConsumerState<PickupRequestsPage> {
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pickupRequests = ref.watch(pickupRequestsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Pickup Requests'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search
                SizedBox(
                  width: 180,
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search by customer name...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                // Status filter
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    _buildStatusChip('all', 'All'),
                    _buildStatusChip('pending', 'Pending'),
                    _buildStatusChip('requested', 'Requested'),
                    _buildStatusChip('assigned', 'Assigned'),
                    _buildStatusChip('completed', 'Completed'),
                    _buildStatusChip('delivered', 'Delivered'),
                  ],
                ),
              ],
            ),
          ),
          // Requests list
          Expanded(
            child: pickupRequests.when(
              data: (requests) => _buildRequestsList(requests),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
    );
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> requests) {
    // Filter requests
    final filteredRequests = requests.where((request) {
      final matchesStatus = _selectedStatus == 'all' || 
                           request['status'] == _selectedStatus;
      
      final matchesSearch = _searchQuery.isEmpty ||
                           (request['customer_name'] ?? '')
                               .toString()
                               .toLowerCase()
                               .contains(_searchQuery.toLowerCase());
      
      return matchesStatus && matchesSearch;
    }).toList();

    if (filteredRequests.isEmpty) {
      return const Center(
        child: Text(
          'No pickup requests found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] ?? 'unknown';
    final customerName = request['customer_name'] ?? 'Unknown';
    final createdAt = request['created_at'];
    final requestId = request['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            if (createdAt != null) ...[
              Text(
                'Created: ${_formatDate(createdAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Request ID: ${requestId ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                if (status == 'pending' || status == 'requested') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(requestId, 'assigned'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Assign'),
                  ),
                ],
                if (status == 'assigned') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(requestId, 'completed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Complete'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
      case 'requested':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'assigned':
        color = Colors.blue;
        label = 'Assigned';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'delivered':
        color = Colors.purple;
        label = 'Delivered';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    }
    return 'Unknown';
  }

  Future<void> _updateStatus(String? requestId, String newStatus) async {
    if (requestId == null) return;

    try {
      await ref.read(updatePickupStatusProvider({'requestId': requestId, 'status': newStatus}).future);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 