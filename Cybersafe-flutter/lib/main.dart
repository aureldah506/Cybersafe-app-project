// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart'; 
import 'theme_provider.dart'; // <-- Importer le nouveau provider

// =========================================================================
// IMPORTANT : L'adresse de ton serveur WAMP
// =========================================================================
const String API_BASE_URL = 'http://10.0.2.2/cybersafe';


void main() {
  // On "fournit" le ThemeProvider à toute l'application
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// =========================================================================
// WIDGET PRINCIPAL (MyApp)
// =========================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On "consomme" le provider pour que l'app se mette à jour
    final themeProvider = context.watch<ThemeProvider>();

    // --- THÈME CLAIR (Light) ---
    // Basé sur :root de style.css
    const Color accentColor = Color(0xFF4F7CFF); // --accent
    const Color bgColor = Color(0xFFF6F7FB);     // --bg
    const Color panelColor = Color(0xFFFFFFFF);  // --panel
    const Color lineCoDlor = Color(0xFFE9EEF5);  // --line
    const Color textColor = Color(0xFF0F172A);   // --text

    // --- THÈME SOMBRE (Dark) ---
    // Basé sur :root[data-theme="dark"] de style.css
    const Color darkAccentColor = Color(0xFF7AA2FF); // --accent
    const Color darkBgColor = Color(0xFF0B1220);     // --bg
    const Color darkPanelColor = Color(0xFF0F172A);  // --panel
    const Color darkLineColor = Color(0xFF1E293B);   // --line
    const Color darkTextColor = Color(0xFFE5E7EB);   // --text

    return MaterialApp(
      title: 'CyberSafe',
      
      // Indique à l'app quel mode utiliser (clair, sombre, ou système)
      themeMode: themeProvider.themeMode, 

      // ==========================
      // THÈME CLAIR
      // ==========================
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgColor,
        primaryColor: accentColor,
        // Boutons ".btn"
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        // Boutons ".btn.ghost"
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: const BorderSide(color: lineCoDlor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        // ".card"
        cardTheme: CardThemeData(
          color: panelColor,
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
            side: const BorderSide(color: lineCoDlor),
          ),
        ),
        // inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panelColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lineCoDlor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lineCoDlor),
          ),
        ),
        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: bgColor,
          elevation: 0,
          foregroundColor: textColor,
        ),
        // Bottom Nav Bar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: panelColor,
          selectedItemColor: accentColor,
          unselectedItemColor: Colors.grey.shade600,
        ),
      ),
      
      // ==========================
      // THÈME SOMBRE
      // ==========================
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBgColor,
        primaryColor: darkAccentColor,
        // Boutons ".btn"
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: darkAccentColor,
            foregroundColor: Colors.black, // Texte plus lisible
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        // Boutons ".btn.ghost"
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: darkTextColor,
            side: const BorderSide(color: darkLineColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        // ".card"
        cardTheme: CardThemeData(
          color: darkPanelColor,
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
            side: const BorderSide(color: darkLineColor),
          ),
        ),
        // inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkPanelColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkLineColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkAccentColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkLineColor),
          ),
        ),
        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: darkBgColor,
          elevation: 0,
          foregroundColor: darkTextColor,
        ),
        // Bottom Nav Bar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: darkPanelColor,
          selectedItemColor: darkAccentColor,
          unselectedItemColor: Colors.grey.shade400,
        ),
      ),

      home: AuthScreen(), 
    );
  }
}


// =========================================================================
// ÉCRAN DE CONNEXION (AuthScreen) - (INCHANGÉ)
// =========================================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _message = 'Entre simplement un prénom.';

  Future<void> _login() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() { _message = 'Le prénom ne peut pas être vide.'; });
      return;
    }

    setState(() { _message = 'Connexion en cours...'; });

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/users.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cs_user_id', data['id']);
        await prefs.setString('cs_name', data['name']);

        if (mounted) { 
          Navigator.pushReplacement( 
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        
      } else {
        setState(() { _message = 'Erreur: ${response.body}'; });
      }
    } catch (e) {
      setState(() { _message = 'Erreur réseau: $e. As-tu bien lancé WAMP ?'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenue 👋',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ton prénom',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _login, 
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}