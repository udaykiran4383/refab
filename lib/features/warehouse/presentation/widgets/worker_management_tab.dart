import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refab_app/features/warehouse/providers/warehouse_provider.dart';
import 'package:refab_app/features/warehouse/data/models/warehouse_worker_model.dart';

class WorkerManagementTab extends ConsumerWidget {
  const WorkerManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseId = ref.watch(warehouseIdProvider);
    final workersAsync = ref.watch(warehouseWorkersProvider(warehouseId));

    return workersAsync.when(
      data: (workers) {
        if (workers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No workers found'),
                Text('Add workers to get started'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];
            return _buildWorkerCard(worker);
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
                ref.invalidate(warehouseWorkersProvider(warehouseId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(WarehouseWorkerModel worker) {
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
                CircleAvatar(
                  backgroundColor: Colors.blue[800],
                  child: Text(
                    worker.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        worker.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(worker),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildWorkerDetail('Role', worker.roleLabel, Icons.work),
                ),
                Expanded(
                  child: _buildWorkerDetail('Years', '${worker.yearsOfService}', Icons.calendar_today),
                ),
                Expanded(
                  child: _buildWorkerDetail('Skills', '${worker.skills.length}', Icons.psychology),
                ),
              ],
            ),
            if (worker.skills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  children: worker.skills.map((skill) => Chip(
                    label: Text(skill, style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue[100],
                  )).toList(),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => _showWorkerDetails(worker),
                  icon: const Icon(Icons.info, color: Colors.blue),
                  tooltip: 'Details',
                ),
                IconButton(
                  onPressed: () => _editWorker(worker),
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _viewPerformance(worker),
                  icon: const Icon(Icons.analytics, color: Colors.green),
                  tooltip: 'Performance',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WarehouseWorkerModel worker) {
    Color chipColor;
    IconData chipIcon;
    
    switch (worker.status) {
      case WorkerStatus.active:
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case WorkerStatus.inactive:
        chipColor = Colors.grey;
        chipIcon = Icons.cancel;
        break;
      case WorkerStatus.onLeave:
        chipColor = Colors.orange;
        chipIcon = Icons.beach_access;
        break;
      case WorkerStatus.terminated:
        chipColor = Colors.red;
        chipIcon = Icons.block;
        break;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(
        worker.statusLabel,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildWorkerDetail(String label, String value, IconData icon) {
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

  void _showWorkerDetails(WarehouseWorkerModel worker) {
    // TODO: Show worker details dialog
  }

  void _editWorker(WarehouseWorkerModel worker) {
    // TODO: Navigate to edit worker page
  }

  void _viewPerformance(WarehouseWorkerModel worker) {
    // TODO: Navigate to performance page
  }
} 