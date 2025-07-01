import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final int totalHours;
  final int targetHours;
  final int tasksCompleted;
  final int certificatesEarned;

  const ProgressCard({
    super.key,
    required this.totalHours,
    required this.targetHours,
    required this.tasksCompleted,
    required this.certificatesEarned,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalHours / targetHours;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Hours Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Volunteer Hours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$totalHours / $targetHours hrs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tasks Completed',
                    tasksCompleted.toString(),
                    Icons.task_alt,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Certificates',
                    certificatesEarned.toString(),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Progress',
                    '${(progress * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
