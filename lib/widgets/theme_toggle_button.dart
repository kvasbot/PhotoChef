import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return IconButton(
          icon: Icon(
            themeService.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () {
            themeService.toggleTheme();
          },
          tooltip: themeService.isDarkMode
              ? 'Светлая тема'
              : 'Темная тема',
        );
      },
    );
  }
}

