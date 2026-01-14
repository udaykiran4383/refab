import 'package:flutter/material.dart';

class KillSwitchWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const KillSwitchWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App disabled icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.block,
                    size: 60,
                    color: Colors.red[700],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'App Disabled',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Message
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Retry button (optional)
                if (onRetry != null) ...[
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Contact info
                Text(
                  'For support, contact: support@refab.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 