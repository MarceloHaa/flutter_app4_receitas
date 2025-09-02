import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final Locale currentLocale;

  const LanguageSelector({
    super.key,
    required this.onLanguageChanged,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('pt', 'BR'),
          child: Row(
            children: [
              Text('🇧🇷'),
              const SizedBox(width: 8),
              const Text('Português'),
              if (currentLocale.languageCode == 'pt') ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              Text('🇺🇸'),
              const SizedBox(width: 8),
              const Text('English'),
              if (currentLocale.languageCode == 'en') ...[
                const Spacer(),
                const Icon(Icons.check, color: Colors.green),
              ],
            ],
          ),
        ),
      ],
    );
  }
}