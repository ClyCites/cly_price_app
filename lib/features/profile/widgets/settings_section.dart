import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const SettingsSection({
    Key? key,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(context, 'Account Settings'),
          _buildSettingsItem(
            context,
            'Personal Information',
            Icons.person_outline,
            () {},
          ),
          _buildSettingsItem(
            context,
            'Notification Preferences',
            Icons.notifications_none,
            () {},
          ),
          _buildSettingsItem(
            context,
            'Privacy & Security',
            Icons.security,
            () {},
          ),
          _buildSettingsItem(
            context,
            'App Settings',
            Icons.settings,
            onSettingsTap,
          ),
          _buildSettingsItem(
            context,
            'Help & Support',
            Icons.help_outline,
            () {},
          ),
          _buildSettingsItem(
            context,
            'About',
            Icons.info_outline,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

