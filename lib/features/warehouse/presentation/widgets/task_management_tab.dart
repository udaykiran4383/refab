import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/features/warehouse/providers/warehouse_provider.dart';
import 'package:refab_app/features/warehouse/data/models/processing_task_model.dart';

class TaskManagementTab extends ConsumerStatefulWidget {
  const TaskManagementTab({super.key});

  @override
  ConsumerState<TaskManagementTab> createState() => _TaskManagementTabState();
}

class _TaskManagementTabState extends ConsumerState<TaskManagementTab> {
  String _selectedStatus = 'all';
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final warehouseId = ref.watch(warehouseIdProvider);
    final tasksAsync = ref.watch(processingTasksProvider(warehouseId));

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Status')),
                    ...TaskStatus.values.map((status) => DropdownMenuItem(
                      value: status.toString().split('.').last,
                      child: Text(status.toString().split('.').last),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Task Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Types')),
                    ...TaskType.values.map((type) => DropdownMenuItem(
                      value: type.toString().split('.').last,
                      child: Text(type.toString().split('.').last),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Tasks List
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              final filteredTasks = _filterTasks(tasks);
              
              if (filteredTasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No tasks found'),
                      Text('Try adjusting your filters'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _buildTaskCard(task);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(processingTasksProvider(warehouseId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<ProcessingTaskModel> _filterTasks(List<ProcessingTaskModel> tasks) {
    return tasks.where((task) {
      if (_selectedStatus != 'all' && 
          task.status.toString().split('.').last != _selectedStatus) {
        return false;
      }
      
      if (_selectedType != 'all' && 
          task.taskType.toString().split('.').last != _selectedType) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildTaskCard(ProcessingTaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${task.taskTypeLabel}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(task),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTaskDetail('Priority', task.priorityLabel, Icons.priority_high),
                ),
                Expanded(
                  child: _buildTaskDetail('Items', '${task.inventoryItemIds.length}', Icons.inventory),
                ),
                Expanded(
                  child: _buildTaskDetail('Duration', task.formattedDuration, Icons.timer),
                ),
              ],
            ),
            if (task.assignedTo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildTaskDetail('Assigned to', task.assignedTo!, Icons.person),
              ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildTaskDetail('Due', _formatDate(task.dueDate!), Icons.schedule),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusDropdown(task),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showTaskDetails(task),
                  icon: const Icon(Icons.info, color: Colors.blue),
                  tooltip: 'Details',
                ),
                if (task.isPending || task.isAssigned)
                  IconButton(
                    onPressed: () => _assignTask(task),
                    icon: const Icon(Icons.person_add, color: Colors.green),
                    tooltip: 'Assign',
                  ),
                if (task.isInProgress)
                  IconButton(
                    onPressed: () => _completeTask(task),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Complete',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProcessingTaskModel task) {
    Color chipColor;
    IconData chipIcon;
    
    switch (task.status) {
      case TaskStatus.pending:
        chipColor = Colors.grey;
        chipIcon = Icons.schedule;
        break;
      case TaskStatus.assigned:
        chipColor = Colors.blue;
        chipIcon = Icons.person;
        break;
      case TaskStatus.inProgress:
        chipColor = Colors.orange;
        chipIcon = Icons.play_arrow;
        break;
      case TaskStatus.completed:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case TaskStatus.cancelled:
        chipColor = Colors.red;
        chipIcon = Icons.cancel;
        break;
      case TaskStatus.onHold:
        chipColor = Colors.purple;
        chipIcon = Icons.pause;
        break;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(
        task.statusLabel,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildTaskDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(ProcessingTaskModel task) {
    return DropdownButtonFormField<TaskStatus>(
      value: task.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      items: TaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status.toString().split('.').last,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (status) {
        if (status != null) {
          ref.read(warehouseNotifierProvider.notifier).updateTaskStatus(task.id, status);
        }
      },
    );
  }

  void _showTaskDetails(ProcessingTaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task: ${task.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', task.description),
              _buildDetailRow('Type', task.taskTypeLabel),
              _buildDetailRow('Status', task.statusLabel),
              _buildDetailRow('Priority', task.priorityLabel),
              _buildDetailRow('Items Count', '${task.inventoryItemIds.length}'),
              _buildDetailRow('Duration', task.formattedDuration),
              if (task.assignedTo != null)
                _buildDetailRow('Assigned to', task.assignedTo!),
              if (task.dueDate != null)
                _buildDetailRow('Due Date', _formatDate(task.dueDate!)),
              if (task.notes != null)
                _buildDetailRow('Notes', task.notes!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _assignTask(ProcessingTaskModel task) {
    // TODO: Show worker selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task assignment coming soon!')),
    );
  }

  void _completeTask(ProcessingTaskModel task) {
    // TODO: Show completion dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task completion coming soon!')),
    );
  }
} 