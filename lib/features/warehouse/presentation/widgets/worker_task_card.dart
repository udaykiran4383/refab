import 'package:flutter/material.dart';

class WorkerTaskCard extends StatelessWidget {
  final String workerName;
  final String currentTask;
  final int tasksCompleted;
  final int efficiency;
  final VoidCallback onTap;
  final VoidCallback onAssignTask;

  const WorkerTaskCard({
    super.key,
    required this.workerName,
    required this.currentTask,
    required this.tasksCompleted,
    required this.efficiency,
    required this.onTap,
    required this.onAssignTask,
  });

  @override
  Widget build(BuildContext context) {
    Color efficiencyColor = _getEfficiencyColor(efficiency);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      workerName.split(' ').map((e) => e[0]).join(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workerName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Current: $currentTask',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: efficiencyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$efficiency%',
                      style: TextStyle(
                        color: efficiencyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.task_alt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('$tasksCompleted tasks completed'),
                  const Spacer(),
                  Text(
                    'Efficiency: $efficiency%',
                    style: TextStyle(
                      color: efficiencyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // View worker details
                      },
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAssignTask,
                      icon: const Icon(Icons.assignment, size: 16),
                      label: const Text('Assign Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEfficiencyColor(int efficiency) {
    if (efficiency >= 90) return Colors.green;
    if (efficiency >= 80) return Colors.orange;
    return Colors.red;
  }
}
