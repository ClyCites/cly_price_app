import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/models/price_alert_model.dart';
import '../../core/providers/price_alert_provider.dart';
import '../../core/theme/app_colors.dart';
import '../common/widgets/loading_indicator.dart';
import '../common/widgets/empty_state.dart';
import 'add_alert_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alertProvider = Provider.of<PriceAlertProvider>(context, listen: false);
    await alertProvider.loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = Provider.of<PriceAlertProvider>(context);
    final alerts = alertProvider.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Alerts'),
      ),
      body: alertProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : alerts.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_off,
                  title: 'No Price Alerts',
                  message: 'You haven\'t set up any price alerts yet.',
                  action: ElevatedButton.icon(
                    onPressed: () => _navigateToAddAlert(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Alert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAlerts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return _buildAlertCard(context, alert);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAlert(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, PriceAlert alert) {
    final currencyFormat = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isActive ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
      ),
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
                    alert.productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(alert),
              ],
            ),
            if (alert.marketName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Market: ${alert.marketName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getAlertTypeColor(alert.alertType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getAlertTypeIcon(alert.alertType),
                        size: 16,
                        color: _getAlertTypeColor(alert.alertType),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.getAlertTypeText(),
                        style: TextStyle(
                          color: _getAlertTypeColor(alert.alertType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(alert.targetPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  'Frequency: ${alert.getFrequencyText()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(alert.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    Switch(
                      value: alert.isActive,
                      onChanged: (value) {
                        Provider.of<PriceAlertProvider>(context, listen: false)
                            .toggleAlertStatus(alert.id);
                      },
                      activeColor: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _navigateToEditAlert(context, alert),
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(context, alert),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PriceAlert alert) {
    Color color;
    String text;
    
    if (!alert.isActive) {
      color = Colors.grey;
      text = 'Inactive';
    } else if (alert.hasBeenTriggered && alert.frequency == AlertFrequency.once) {
      color = Colors.orange;
      text = 'Triggered';
    } else {
      color = Colors.green;
      text = 'Active';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getAlertTypeColor(AlertType type) {
    switch (type) {
      case AlertType.below:
        return Colors.green;
      case AlertType.above:
        return Colors.red;
      case AlertType.change:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.below:
        return Icons.arrow_downward;
      case AlertType.above:
        return Icons.arrow_upward;
      case AlertType.change:
        return Icons.compare_arrows;
      default:
        return Icons.notifications;
    }
  }

  void _navigateToAddAlert(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAlertScreen(),
      ),
    );
    
    if (result == true) {
      _loadAlerts();
    }
  }

  void _navigateToEditAlert(BuildContext context, PriceAlert alert) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlertScreen(
          existingAlert: alert,
        ),
      ),
    );
    
    if (result == true) {
      _loadAlerts();
    }
  }

  void _showDeleteConfirmation(BuildContext context, PriceAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Are you sure you want to delete the alert for ${alert.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<PriceAlertProvider>(context, listen: false)
                    .deleteAlert(alert.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alert deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete alert: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

