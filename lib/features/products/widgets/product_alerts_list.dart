import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/price_alert_model.dart';
import '../../../core/providers/price_alert_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../alerts/add_alert_screen.dart';

class ProductAlertsList extends StatelessWidget {
  final String productId;
  final String productName;
  final List<PriceAlert> alerts;

  const ProductAlertsList({
    Key? key,
    required this.productId,
    required this.productName,
    required this.alerts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No price alerts set',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAlertScreen(
                      productId: productId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(context, alert);
      },
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
                Text(
                  alert.getAlertTypeText(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(alert),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(alert.targetPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Frequency: ${alert.getFrequencyText()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(alert.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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

  void _navigateToEditAlert(BuildContext context, PriceAlert alert) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAlertScreen(
          existingAlert: alert,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PriceAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Are you sure you want to delete this price alert?'),
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alert deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
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

