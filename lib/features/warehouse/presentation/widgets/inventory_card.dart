import 'package:flutter/material.dart';
import 'package:refab_app/features/warehouse/data/models/inventory_model.dart';

class InventoryCard extends StatelessWidget {
  final InventoryModel inventory;
  final VoidCallback? onTap;
  final Function(InventoryStatus?)? onStatusChange;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InventoryCard({
    super.key,
    required this.inventory,
    this.onTap,
    this.onStatusChange,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${inventory.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inventory.fabricCategory,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),
              // Details Row
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Weight',
                      inventory.formattedWeight,
                      Icons.scale,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Grade',
                      inventory.qualityGrade,
                      Icons.star,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Cost',
                      inventory.formattedCost,
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Additional Info
              if (inventory.supplierName != null || inventory.batchNumber != null)
                Row(
                  children: [
                    if (inventory.supplierName != null)
                      Expanded(
                        child: _buildDetailItem(
                          'Supplier',
                          inventory.supplierName!,
                          Icons.business,
                        ),
                      ),
                    if (inventory.batchNumber != null)
                      Expanded(
                        child: _buildDetailItem(
                          'Batch',
                          inventory.batchNumber!,
                          Icons.inventory_2,
                        ),
                      ),
                  ],
                ),
              if (inventory.warehouseLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildDetailItem(
                    'Location',
                    inventory.warehouseLocation!,
                    Icons.location_on,
                  ),
                ),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                children: [
                  if (onStatusChange != null) ...[
                    Expanded(
                      child: _buildStatusDropdown(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    IconData chipIcon;
    
    switch (inventory.status) {
      case InventoryStatus.processing:
        chipColor = Colors.orange;
        chipIcon = Icons.sync;
        break;
      case InventoryStatus.graded:
        chipColor = Colors.blue;
        chipIcon = Icons.grade;
        break;
      case InventoryStatus.ready:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case InventoryStatus.used:
        chipColor = Colors.grey;
        chipIcon = Icons.archive;
        break;
      case InventoryStatus.lowStock:
        chipColor = Colors.red;
        chipIcon = Icons.warning;
        break;
      case InventoryStatus.reserved:
        chipColor = Colors.purple;
        chipIcon = Icons.lock;
        break;
      case InventoryStatus.damaged:
        chipColor = Colors.red[900]!;
        chipIcon = Icons.error;
        break;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(
        inventory.statusLabel,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
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

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<InventoryStatus>(
      value: inventory.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      items: InventoryStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status.toString().split('.').last,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: onStatusChange,
    );
  }
}
