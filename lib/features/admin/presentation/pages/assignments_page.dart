import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentsPage extends ConsumerStatefulWidget {
  const AssignmentsPage({super.key});

  @override
  ConsumerState<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends ConsumerState<AssignmentsPage> {
  String _selectedType = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final assignments = ref.watch(assignmentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Assignments'),
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
                      hintText: 'Search by logistics user or warehouse...',
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
                // Type and Status filters
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text('Type: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    _buildTypeChip('all', 'All'),
                    _buildTypeChip('pickup', 'Pickup'),
                    _buildTypeChip('delivery', 'Delivery'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    _buildStatusChip('all', 'All'),
                    _buildStatusChip('pending', 'Pending'),
                    _buildStatusChip('assigned', 'Assigned'),
                    _buildStatusChip('in_progress', 'In Progress'),
                    _buildStatusChip('completed', 'Completed'),
                    _buildStatusChip('delivered', 'Delivered'),
                  ],
                ),
              ],
            ),
          ),
          // Assignments list
          Expanded(
            child: assignments.when(
              data: (assignments) => _buildAssignmentsList(assignments),
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

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
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

  Widget _buildAssignmentsList(List<Map<String, dynamic>> assignments) {
    // Filter assignments
    final filteredAssignments = assignments.where((assignment) {
      final matchesType = _selectedType == 'all' || 
                         assignment['type'] == _selectedType;
      
      final matchesStatus = _selectedStatus == 'all' || 
                           assignment['status'] == _selectedStatus;
      
      final matchesSearch = _searchQuery.isEmpty ||
                           (assignment['logistics_user_name'] ?? '')
                               .toString()
                               .toLowerCase()
                               .contains(_searchQuery.toLowerCase()) ||
                           (assignment['warehouse_name'] ?? '')
                               .toString()
                               .toLowerCase()
                               .contains(_searchQuery.toLowerCase());
      
      return matchesType && matchesStatus && matchesSearch;
    }).toList();

    if (filteredAssignments.isEmpty) {
      return const Center(
        child: Text(
          'No assignments found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAssignments.length,
      itemBuilder: (context, index) {
        final assignment = filteredAssignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final status = assignment['status'] ?? 'unknown';
    final type = assignment['type'] ?? 'unknown';
    final logisticsUserName = assignment['logistics_user_name'] ?? 'Unknown';
    final warehouseName = assignment['warehouse_name'] ?? 'Unknown';
    final createdAt = assignment['created_at'];
    final assignmentId = assignment['id'];

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        logisticsUserName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        warehouseName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTypeBadge(type),
                    const SizedBox(height: 4),
                    _buildStatusBadge(status),
                  ],
                ),
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
                    'Assignment ID: ${assignmentId ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                if (status == 'pending') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(assignmentId, 'assigned'),
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
                    onPressed: () => _updateStatus(assignmentId, 'in_progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Start'),
                  ),
                ],
                if (status == 'in_progress') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateStatus(assignmentId, 'completed'),
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

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;

    switch (type) {
      case 'pickup':
        color = Colors.blue;
        label = 'Pickup';
        break;
      case 'delivery':
        color = Colors.green;
        label = 'Delivery';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'assigned':
        color = Colors.blue;
        label = 'Assigned';
        break;
      case 'in_progress':
        color = Colors.purple;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'delivered':
        color = Colors.teal;
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

  Future<void> _updateStatus(String? assignmentId, String newStatus) async {
    if (assignmentId == null) return;

    try {
      await ref.read(updateAssignmentStatusProvider({'assignmentId': assignmentId, 'status': newStatus}).future);
      
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