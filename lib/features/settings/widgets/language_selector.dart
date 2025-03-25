import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    Key? key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'English', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'Spanish', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'French', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'German', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'Chinese', 'name': '中文', 'flag': '🇨🇳'},
      {'code': 'Japanese', 'name': '日本語', 'flag': '🇯🇵'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Language',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                }
              },
              items: languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Row(
                    children: [
                      Text(
                        language['flag']!,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(language['name']!),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

