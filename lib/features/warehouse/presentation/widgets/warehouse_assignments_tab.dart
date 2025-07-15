import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/warehouse_provider.dart';
import '../../data/models/warehouse_assignment_model.dart';
import 'assignment_details_dialog.dart';

class WarehouseAssignmentsTab extends ConsumerStatefulWidget {
  const WarehouseAssignmentsTab({super.key});

  @override
  ConsumerState<WarehouseAssignmentsTab> createState() => _WarehouseAssignmentsTabState();
}

class _WarehouseAssignmentsTabState extends ConsumerState<WarehouseAssignmentsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final warehouseId = ref.watch(warehouseIdProvider);
    print('🏭 [WAREHOUSE_TAB] Building with warehouse ID: $warehouseId');
    
    return Column(
      children: [
        // Enhanced Search Bar
        Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[50]!,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔍 Search assignments...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        // Main Assignments List
        Expanded(
          child: _buildAllAssignmentsTab(warehouseId),
        ),
      ],
    );
  }

  Widget _buildAllAssignmentsTab(String warehouseId) {
    // Use a provider that gets all assignments, not filtered by warehouseId
    final allAssignmentsAsync = ref.watch(warehouseAssignmentsProvider('all'));
    
    return allAssignmentsAsync.when(
      data: (assignments) {
        print('🏭 [WAREHOUSE_TAB] Received ${assignments.length} assignments for all warehouses');
        for (final assignment in assignments) {
          print('🏭 [WAREHOUSE_TAB] Assignment: ${assignment.id} - Warehouse: ${assignment.warehouseId} - Status: ${assignment.statusDisplayName} - Logistics: ${assignment.logisticsName}');
        }
        
        final filteredAssignments = _filterAssignments(assignments);
        print('🏭 [WAREHOUSE_TAB] After filtering: ${filteredAssignments.length} assignments');
        
        if (filteredAssignments.isEmpty) {
          return _buildEmptyState(
            'No assignments found',
            'Create your first assignment to get started',
            Icons.assignment,
            Colors.grey,
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
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading assignments...'),
          ],
        ),
      ),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildAssignmentCard(WarehouseAssignmentModel assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAssignmentDetails(assignment),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Enhanced Status indicator
                    Container(
                      width: 6,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(assignment.status),
                            _getStatusColor(assignment.status).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(assignment.status).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Assignment details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Assignment #${(assignment.id ?? '').substring(0, 8)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getStatusColor(assignment.status).withOpacity(0.1),
                                      _getStatusColor(assignment.status).withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getStatusColor(assignment.status).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  assignment.statusDisplayName.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(assignment.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Enhanced info rows
                          _buildInfoRow(
                            Icons.person,
                            assignment.logisticsName,
                            Icons.person_outline,
                            assignment.tailorName,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.inventory_2,
                            assignment.fabricType,
                            Icons.scale,
                            '${assignment.actualWeight} kg',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.location_on,
                            assignment.warehouseId,
                            Icons.access_time,
                            _formatDate(assignment.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Overdue indicator
                if (assignment.isOverdue) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red[50]!,
                          Colors.red[100]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.red[700], size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Overdue: ${assignment.delayDisplay}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon1, String text1, IconData icon2, String text2) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon1, size: 16, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text1,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon2, size: 16, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text2,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(WarehouseAssignmentStatus status) {
    switch (status) {
      case WarehouseAssignmentStatus.scheduled:
        return Colors.blue;
      case WarehouseAssignmentStatus.inTransit:
        return Colors.orange;
      case WarehouseAssignmentStatus.arrived:
        return Colors.green;
      case WarehouseAssignmentStatus.processing:
        return Colors.purple;
      case WarehouseAssignmentStatus.completed:
        return Colors.grey;
      case WarehouseAssignmentStatus.cancelled:
        return Colors.red;
    }
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error loading assignments',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(warehouseAssignmentsProvider('main_warehouse'));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<WarehouseAssignmentModel> _filterAssignments(List<WarehouseAssignmentModel> assignments) {
    return assignments.where((assignment) {
      // Search filter only - no status filtering since we removed the status filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return assignment.logisticsName.toLowerCase().contains(query) ||
               assignment.tailorName.toLowerCase().contains(query) ||
               assignment.fabricType.toLowerCase().contains(query) ||
               (assignment.id ?? '').toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }

  void _showAssignmentDetails(WarehouseAssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (context) => AssignmentDetailsDialog(assignment: assignment),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 