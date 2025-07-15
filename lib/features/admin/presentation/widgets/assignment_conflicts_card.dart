import 'package:flutter/material.dart';
import '../../../logistics/data/models/logistics_assignment_model.dart';

class AssignmentConflictsCard extends StatelessWidget {
  final List<LogisticsAssignmentModel> assignments;
  final VoidCallback onResolveConflict;
  final VoidCallback onTap;

  const AssignmentConflictsCard({
    super.key,
    required this.assignments,
    required this.onResolveConflict,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Find potential conflicts (multiple assignments for same pickup request)
    final conflicts = _findAssignmentConflicts();
    
    if (conflicts.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment Conflicts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No conflicts detected',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Assignment Conflicts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${conflicts.length} Conflicts',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Conflict List
              ...conflicts.take(3).map((conflict) => _buildConflictItem(context, conflict)),
              
              if (conflicts.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... and ${conflicts.length - 3} more conflicts',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onResolveConflict,
                  icon: const Icon(Icons.build),
                  label: const Text('Resolve Conflicts'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConflictItem(BuildContext context, Map<String, dynamic> conflict) {
    final pickupRequestId = conflict['pickupRequestId'] as String;
    final assignments = conflict['assignments'] as List<LogisticsAssignmentModel>;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pickup Request: ${pickupRequestId.substring(0, 8)}...',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${assignments.length} assignments',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...assignments.map((assignment) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(assignment.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Logistics: ${assignment.logisticsId.substring(0, 8)}... (${assignment.status.toString().split('.').last})',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _findAssignmentConflicts() {
    final conflicts = <Map<String, dynamic>>[];
    final pickupRequestGroups = <String, List<LogisticsAssignmentModel>>{};

    // Group assignments by pickup request ID
    for (final assignment in assignments) {
      if (assignment.type == LogisticsAssignmentType.pickup) {
        pickupRequestGroups.putIfAbsent(assignment.pickupRequestId, () => []);
        pickupRequestGroups[assignment.pickupRequestId]!.add(assignment);
      }
    }

    // Find conflicts (multiple assignments for same pickup request)
    for (final entry in pickupRequestGroups.entries) {
      if (entry.value.length > 1) {
        conflicts.add({
          'pickupRequestId': entry.key,
          'assignments': entry.value,
        });
      }
    }

    return conflicts;
  }

  Color _getStatusColor(LogisticsAssignmentStatus status) {
    switch (status) {
      case LogisticsAssignmentStatus.pending:
        return Colors.orange;
      case LogisticsAssignmentStatus.assigned:
        return Colors.blue;
      case LogisticsAssignmentStatus.inProgress:
        return Colors.purple;
      case LogisticsAssignmentStatus.completed:
        return Colors.green;
      case LogisticsAssignmentStatus.cancelled:
        return Colors.red;
    }
  }
} 