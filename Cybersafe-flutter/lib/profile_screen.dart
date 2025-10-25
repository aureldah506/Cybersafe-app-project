// lib/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Pour AuthScreen (pour la déconnexion)
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Utilisateur';
  int _securityPercent = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Charge les mêmes données que le dashboard
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('cs_name') ?? 'Utilisateur';
    final userId = prefs.getInt('cs_user_id') ?? 0;
    int percent = 0;

    if (userId > 0) {
      try {
        final url = Uri.parse('$API_BASE_URL/scores.php?userId=$userId&summary=1');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          percent = data['percent'] as int;
        }
      } catch (e) {
        percent = 0;
      }
    }

    setState(() {
      _userName = name;
      _securityPercent = percent;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    // 1. Vide le "localStorage"
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime cs_user_id, cs_name, etc.

    // 2. Renvoie vers l'écran de connexion
    // pushAndRemoveUntil vide l'historique, l'utilisateur ne peut pas "revenir"
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false, // Supprime toutes les routes précédentes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil 👤'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [ const ThemeToggleButton() ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileBody(),
    );
  }

  Widget _buildProfileBody() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Carte d'infos utilisateur
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text('Apprenant en cybersécurité', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Carte de progression
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progression sécurité', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Niveau sécurité'),
                    Text(
                      '$_securityPercent / 100',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _securityPercent / 100.0,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Bouton Déconnexion
        OutlinedButton(
          onPressed: _logout,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.redAccent),
          ),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}