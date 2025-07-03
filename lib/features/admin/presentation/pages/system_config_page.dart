import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../data/models/system_config_model.dart';

class SystemConfigPage extends ConsumerStatefulWidget {
  const SystemConfigPage({super.key});

  @override
  ConsumerState<SystemConfigPage> createState() => _SystemConfigPageState();
}

class _SystemConfigPageState extends ConsumerState<SystemConfigPage> {
  @override
  Widget build(BuildContext context) {
    final systemConfig = ref.watch(systemConfigStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 12),
              Text('System Configuration', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showBackupDialog(context),
                icon: const Icon(Icons.backup),
                label: const Text('Create Backup'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: systemConfig.when(
              data: (config) => _buildConfigForm(context, config),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigForm(BuildContext context, SystemConfigModel config) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('General Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Maintenance Mode'),
                    subtitle: const Text('Enable maintenance mode to restrict access'),
                    value: config.maintenanceMode,
                    onChanged: (value) => _updateConfig(config.copyWith(maintenanceMode: value)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Minimum App Version', border: OutlineInputBorder()),
                    initialValue: config.minAppVersion,
                    onChanged: (value) => _updateConfig(config.copyWith(minAppVersion: value)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'API Base URL', border: OutlineInputBorder()),
                    initialValue: config.apiBaseUrl,
                    onChanged: (value) => _updateConfig(config.copyWith(apiBaseUrl: value)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Support Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Support Email', border: OutlineInputBorder()),
                    initialValue: config.supportEmail,
                    onChanged: (value) => _updateConfig(config.copyWith(supportEmail: value)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Support Phone', border: OutlineInputBorder()),
                    initialValue: config.supportPhone,
                    onChanged: (value) => _updateConfig(config.copyWith(supportPhone: value)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Business Rules', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Max Pickup Weight (kg)', border: OutlineInputBorder()),
                    initialValue: config.maxPickupWeight.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final weight = double.tryParse(value);
                      if (weight != null) {
                        _updateConfig(config.copyWith(maxPickupWeight: weight));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Minimum Order Amount (₹)', border: OutlineInputBorder()),
                    initialValue: config.minOrderAmount.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value);
                      if (amount != null) {
                        _updateConfig(config.copyWith(minOrderAmount: amount));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Volunteer Certificate Hours', border: OutlineInputBorder()),
                    initialValue: config.volunteerCertificateHours.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hours = int.tryParse(value);
                      if (hours != null) {
                        _updateConfig(config.copyWith(volunteerCertificateHours: hours));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Features', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Analytics'),
                    subtitle: const Text('Collect and display analytics data'),
                    value: config.enableAnalytics,
                    onChanged: (value) => _updateConfig(config.copyWith(enableAnalytics: value)),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Crashlytics'),
                    subtitle: const Text('Collect crash reports and errors'),
                    value: config.enableCrashlytics,
                    onChanged: (value) => _updateConfig(config.copyWith(enableCrashlytics: value)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveConfig(config),
              child: const Text('Save Configuration'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateConfig(SystemConfigModel newConfig) {
    // This would typically update a local state and then save when user clicks save
    // For now, we'll just save immediately
    ref.read(adminProvider.notifier).updateSystemConfig(newConfig);
  }

  void _saveConfig(SystemConfigModel config) {
    ref.read(adminProvider.notifier).updateSystemConfig(config);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully!')),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create System Backup'),
        content: const Text('This will create a backup of all system data. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).createSystemBackup();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('System backup created successfully!')),
              );
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }
} 