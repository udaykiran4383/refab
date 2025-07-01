import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String trend;
  final List<double> chartData;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.trend,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    Color trendColor = trend == 'up' ? Colors.green : Colors.red;
    IconData trendIcon = trend == 'up' ? Icons.trending_up : Icons.trending_down;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(trendIcon, color: trendColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Simple chart representation
            Container(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((value) {
                  return Container(
                    width: 20,
                    height: value * 2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
