import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MarketList extends StatelessWidget {
  final List<String> markets;
  final Function(String) onMarketSelected;

  const MarketList({
    super.key,
    required this.markets,
    required this.onMarketSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (markets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No markets available',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: markets.length,
      itemBuilder: (context, index) {
        final market = markets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              market,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Tap to view market details'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () => onMarketSelected(market),
          ),
        );
      },
    );
  }
}

