import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/product_provider.dart';
import '../../../core/theme/app_colors.dart';

class OfflineSyncButton extends StatelessWidget {
  const OfflineSyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.amber.shade700,
      child: Row(
        children: [
          const Icon(
            Icons.sync,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'You have offline data that needs to be synced.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await productProvider.syncPendingEntries();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data synced successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sync data: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Sync Now',
              style: TextStyle(
                color: Colors.amber.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

