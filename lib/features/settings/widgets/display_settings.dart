import 'package:flutter/material.dart';
import '../../../core/models/settings_model.dart';

class DisplaySettings extends StatelessWidget {
  final DisplayPreferences preferences;
  final Function(ChartDisplayPeriod) onChartPeriodChanged;
  final Function(int) onDataPointDensityChanged;

  const DisplaySettings({
    Key? key,
    required this.preferences,
    required this.onChartPeriodChanged,
    required this.onDataPointDensityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Period Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Default Chart Period',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _ChartPeriodChip(
                    label: 'Day',
                    isSelected: preferences.defaultChartPeriod == ChartDisplayPeriod.day,
                    onTap: () => onChartPeriodChanged(ChartDisplayPeriod.day),
                  ),
                  _ChartPeriodChip(
                    label: 'Week',
                    isSelected: preferences.defaultChartPeriod == ChartDisplayPeriod.week,
                    onTap: () => onChartPeriodChanged(ChartDisplayPeriod.week),
                  ),
                  _ChartPeriodChip(
                    label: 'Month',
                    isSelected: preferences.defaultChartPeriod == ChartDisplayPeriod.month,
                    onTap: () => onChartPeriodChanged(ChartDisplayPeriod.month),
                  ),
                  _ChartPeriodChip(
                    label: 'Quarter',
                    isSelected: preferences.defaultChartPeriod == ChartDisplayPeriod.quarter,
                    onTap: () => onChartPeriodChanged(ChartDisplayPeriod.quarter),
                  ),
                  _ChartPeriodChip(
                    label: 'Year',
                    isSelected: preferences.defaultChartPeriod == ChartDisplayPeriod.year,
                    onTap: () => onChartPeriodChanged(ChartDisplayPeriod.year),
                  ),
                  _ChartPeriodChip(
                    label: 'All',
                    isSelected: preferences.defaultChartPeriod == ChartDisplayPeriod.all,
                    onTap: () => onChartPeriodChanged(ChartDisplayPeriod.all),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Data Point Density
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Point Density',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: preferences.dataPointDensity.toDouble(),
                min: 0,
                max: 2,
                divisions: 2,
                label: _getDensityLabel(preferences.dataPointDensity),
                onChanged: (value) => onDataPointDensityChanged(value.toInt()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Medium',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'High',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDensityLabel(int density) {
    switch (density) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Medium';
    }
  }
}

class _ChartPeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartPeriodChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

