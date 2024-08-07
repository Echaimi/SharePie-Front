// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spaceshare/providers/LanguageProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.language, color: theme.textTheme.bodyMedium!.color),
      onPressed: () {
        _showLanguagePicker(context);
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        int selectedLanguageIndex =
            languageProvider.locale.languageCode == 'en' ? 0 : 1;
        return Container(
          height: 190,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    selectedLanguageIndex = index;
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedLanguageIndex,
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('lib/assets/icons/uk_flag.png', width: 30),
                        const SizedBox(width: 8),
                        const Text('English'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('lib/assets/icons/fr_flag.png', width: 30),
                        const SizedBox(width: 8),
                        const Text('Français'),
                      ],
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child: const Text('OK'),
                onPressed: () {
                  final newLocale = selectedLanguageIndex == 0
                      ? const Locale('en')
                      : const Locale('fr');
                  languageProvider.setLocale(newLocale);
                  context.pop();
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }
}
