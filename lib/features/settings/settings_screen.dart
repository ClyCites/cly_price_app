import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/models/settings_model.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/theme_selector.dart';
import 'widgets/language_selector.dart';
import 'widgets/notification_settings.dart';
import 'widgets/display_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    
    if (settingsProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings'),
                  content: const Text('Are you sure you want to reset all settings to default?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        settingsProvider.resetSettings();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings reset to default')),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Appearance Section
          SettingsSection(
            title: 'Appearance',
            children: [
              ThemeSelector(
                currentTheme: settings.themeMode,
                onThemeChanged: settingsProvider.updateThemeMode,
              ),
              const SizedBox(height: 16),
              LanguageSelector(
                currentLanguage: settings.language,
                onLanguageChanged: settingsProvider.updateLanguage,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          SettingsSection(
            title: 'Notifications',
            children: [
              SettingsItem(
                title: 'Enable Notifications',
                subtitle: 'Receive updates about prices and markets',
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: settingsProvider.updateNotificationsEnabled,
                ),
              ),
              if (settings.notificationsEnabled)
                NotificationSettings(
                  settings: settings.notificationSettings,
                  onSettingChanged: settingsProvider.updateNotificationSetting,
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Data & Sync Section
          SettingsSection(
            title: 'Data & Sync',
            children: [
              SettingsItem(
                title: 'Sync Data',
                subtitle: 'Keep your data synchronized across devices',
                trailing: Switch(
                  value: settings.dataSync,
                  onChanged: settingsProvider.updateDataSync,
                ),
              ),
              SettingsItem(
                title: 'Currency',
                subtitle: 'Select your preferred currency',
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.updateCurrency(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                    DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                    DropdownMenuItem(value: 'CNY', child: Text('CNY')),
                  ],
                ),
              ),
              SettingsItem(
                title: 'Measurement Unit',
                subtitle: 'Choose between metric and imperial',
                trailing: DropdownButton<MeasurementUnit>(
                  value: settings.measurementUnit,
                  onChanged: (value) {
                    if (value != null) {
                      settingsProvider.updateMeasurementUnit(value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: MeasurementUnit.metric,
                      child: Text('Metric'),
                    ),
                    DropdownMenuItem(
                      value: MeasurementUnit.imperial,
                      child: Text('Imperial'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Display Settings Section
          SettingsSection(
            title: 'Display Settings',
            children: [
              DisplaySettings(
                preferences: settings.displayPreferences,
                onChartPeriodChanged: settingsProvider.updateChartPeriod,
                onDataPointDensityChanged: settingsProvider.updateDataPointDensity,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Privacy Section
          SettingsSection(
            title: 'Privacy',
            children: [
              SettingsItem(
                title: 'Analytics',
                subtitle: 'Help us improve by sending anonymous usage data',
                trailing: Switch(
                  value: settings.analyticsEnabled,
                  onChanged: settingsProvider.updateAnalyticsEnabled,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          SettingsSection(
            title: 'About',
            children: [
              SettingsItem(
                title: 'Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              SettingsItem(
                title: 'Terms of Service',
                onTap: () {
                  // Navigate to Terms of Service
                },
              ),
              SettingsItem(
                title: 'Privacy Policy',
                onTap: () {
                  // Navigate to Privacy Policy
                },
              ),
              SettingsItem(
                title: 'Licenses',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'ClyCites',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

