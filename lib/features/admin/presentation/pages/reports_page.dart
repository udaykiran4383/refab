import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../data/models/report_model.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(allReportsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 12),
              Text('Reports', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showGenerateReportDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Generate Report'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: reports.when(
              data: (reportsList) {
                if (reportsList.isEmpty) return const Center(child: Text('No reports found'));
                return ListView.builder(
                  itemCount: reportsList.length,
                  itemBuilder: (context, index) => _buildReportCard(context, reportsList[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getReportColor(report.reportType),
          child: Icon(_getReportIcon(report.reportType), color: Colors.white),
        ),
        title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(report.timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getReportColor(report.reportType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.reportType.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(fontSize: 10, color: _getReportColor(report.reportType), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View')),
            if (report.downloadUrl != null) const PopupMenuItem(value: 'download', child: Text('Download')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) => _handleReportAction(context, report, value),
        ),
        onTap: () => _showReportDetails(context, report),
      ),
    );
  }

  Color _getReportColor(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'pickup_requests': return Colors.orange;
      case 'orders': return Colors.green;
      case 'users': return Colors.blue;
      case 'revenue': return Colors.purple;
      case 'impact': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getReportIcon(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'pickup_requests': return Icons.local_shipping;
      case 'orders': return Icons.shopping_cart;
      case 'users': return Icons.people;
      case 'revenue': return Icons.currency_rupee;
      case 'impact': return Icons.eco;
      default: return Icons.assessment;
    }
  }

  void _handleReportAction(BuildContext context, ReportModel report, String action) {
    switch (action) {
      case 'view':
        _showReportDetails(context, report);
        break;
      case 'download':
        if (report.downloadUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started...')));
        }
        break;
      case 'delete':
        _showDeleteReportDialog(context, report);
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
              Text('Report Data:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...report.data.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${entry.key}: ${entry.value}'),
              )),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showGenerateReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: const Text('Report generation functionality will be implemented here.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showDeleteReportDialog(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete ${report.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).deleteReport(report.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 