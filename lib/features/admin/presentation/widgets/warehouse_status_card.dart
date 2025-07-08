import 'package:flutter/material.dart';

class WarehouseStatusCard extends StatelessWidget {
  final int totalWarehouses;
  final int activeWarehouses;
  final int totalInventory;
  final int processingInventory;
  final int readyInventory;
  final int utilizationRate;
  final VoidCallback onTap;

  const WarehouseStatusCard({
    super.key,
    required this.totalWarehouses,
    required this.activeWarehouses,
    required this.totalInventory,
    required this.processingInventory,
    required this.readyInventory,
    required this.utilizationRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeRate = totalWarehouses > 0 ? (activeWarehouses / totalWarehouses * 100).round() : 0;
    final readyRate = totalInventory > 0 ? (readyInventory / totalInventory * 100).round() : 0;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Warehouse Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$utilizationRate% Utilized',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Warehouse Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Total Warehouses',
                      totalWarehouses.toString(),
                      Icons.warehouse,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      'Active Warehouses',
                      activeWarehouses.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricItem(
                      'Utilization',
                      '$utilizationRate%',
                      Icons.analytics,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Indicators
              Row(
                children: [
                  Expanded(
                    child: _buildProgressIndicator(
                      'Active Rate',
                      activeRate,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProgressIndicator(
                      'Ready Rate',
                      readyRate,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Inventory Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildDetailMetric(
                      'Total Inventory',
                      totalInventory.toString(),
                      Icons.inventory,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailMetric(
                      'Processing',
                      processingInventory.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailMetric(
                      'Ready',
                      readyInventory.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Warehouse Operations
              Text(
                'Warehouse Operations',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildWarehouseOperations(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
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
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildDetailMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseOperations() {
    return Column(
      children: [
        _buildOperationStep(
          'Inventory Received',
          'Fabric received from logistics',
          Icons.input,
          Colors.blue,
          true,
        ),
        _buildOperationStep(
          'Quality Inspection',
          'Quality check and categorization',
          Icons.verified,
          Colors.orange,
          true,
        ),
        _buildOperationStep(
          'Processing',
          'Fabric processing and preparation',
          Icons.build,
          Colors.purple,
          true,
        ),
        _buildOperationStep(
          'Storage',
          'Organized storage and tracking',
          Icons.inventory_2,
          Colors.green,
          true,
        ),
        _buildOperationStep(
          'Ready for Distribution',
          'Ready for customer orders',
          Icons.local_shipping,
          Colors.teal,
          true,
        ),
        _buildOperationStep(
          'Analytics',
          'Performance tracking and reporting',
          Icons.analytics,
          Colors.indigo,
          false,
        ),
      ],
    );
  }

  Widget _buildOperationStep(String title, String description, IconData icon, Color color, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? color : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? color.withOpacity(0.7) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Icon(
              Icons.check_circle,
              color: color,
              size: 16,
            ),
        ],
      ),
    );
  }
} 