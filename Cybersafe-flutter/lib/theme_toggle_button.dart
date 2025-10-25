// lib/theme_toggle_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le provider
    final themeProvider = context.watch<ThemeProvider>();

    return IconButton(
      // Équivalent de votre "🌗"
      icon: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      ),
      onPressed: () {
        // Appelle la fonction pour changer le thème
        context.read<ThemeProvider>().toggleTheme();
      },
    );
  }
}