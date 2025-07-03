import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../data/models/report_model.dart';

class ReportCard extends ConsumerWidget {
  const ReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(allReportsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showGenerateReportDialog(context, ref),
                  child: const Text('Generate New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            reports.when(
              data: (reportsList) {
                if (reportsList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No reports found'),
                    ),
                  );
                }

                return Column(
                  children: reportsList.take(5).map((report) {
                    return _buildReportTile(context, ref, report);
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading reports: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context,
    WidgetRef ref,
    ReportModel report,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getReportColor(report.reportType),
          child: Icon(
            _getReportIcon(report.reportType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  report.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getReportColor(report.reportType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.reportType.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getReportColor(report.reportType),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View'),
            ),
            if (report.downloadUrl != null)
              const PopupMenuItem(
                value: 'download',
                child: Text('Download'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) => _handleReportAction(
            context,
            ref,
            report,
            value,
          ),
        ),
        onTap: () => _showReportDetails(context, report),
      ),
    );
  }

  Color _getReportColor(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'pickup_requests':
        return Colors.orange;
      case 'orders':
        return Colors.green;
      case 'users':
        return Colors.blue;
      case 'revenue':
        return Colors.purple;
      case 'impact':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'pickup_requests':
        return Icons.local_shipping;
      case 'orders':
        return Icons.shopping_cart;
      case 'users':
        return Icons.people;
      case 'revenue':
        return Icons.currency_rupee;
      case 'impact':
        return Icons.eco;
      default:
        return Icons.assessment;
    }
  }

  void _handleReportAction(
    BuildContext context,
    WidgetRef ref,
    ReportModel report,
    String action,
  ) {
    switch (action) {
      case 'view':
        _showReportDetails(context, report);
        break;
      case 'download':
        if (report.downloadUrl != null) {
          // Implement download functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started...')),
          );
        }
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Report'),
            content: const Text('Are you sure you want to delete this report?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(adminRepositoryProvider).deleteReport(report.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${report.description}'),
              const SizedBox(height: 8),
              Text('Date Range: ${report.dateRange}'),
              const SizedBox(height: 8),
              Text('Generated: ${report.timeAgo}'),
              const SizedBox(height: 8),
              Text('Generated By: ${report.generatedBy}'),
              const SizedBox(height: 16),
              Text(
                'Report Data:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...report.data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${entry.key}: ${entry.value}'),
              )),
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

  void _showGenerateReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: const Text('Report generation functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Provider for all reports
final allReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final repository = ref.read(adminRepositoryProvider);
  return await repository.getAllReports();
}); 