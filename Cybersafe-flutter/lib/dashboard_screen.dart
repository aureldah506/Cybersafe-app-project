// lib/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'theme_toggle_button.dart';

// Importe les 5 écrans nécessaires
import 'main.dart'; // Pour API_BASE_URL
import 'phishing_screen.dart';
import 'social_screen.dart';
import 'password_screen.dart';
import 'shopping_screen.dart';

// Le Dashboard est un "StatefulWidget" car il doit charger des données
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // États pour stocker nos données (comme vos variables JS)
  String _userName = 'Utilisateur';
  int _securityPercent = 0;
  String _secMsg = '...';
  bool _isLoading = true; // Pour afficher un indicateur de chargement

  // Équivalent de votre "DOMContentLoaded" ou "loadSummary"
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fonction pour charger les données (nom + score)
  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Récupérer le nom (comme "applyName")
    final name = prefs.getString('cs_name') ?? 'Utilisateur';
    
    // 2. Récupérer le score (comme "loadSummary")
    final userId = prefs.getInt('cs_user_id') ?? 0;
    int percent = 0;

    if (userId > 0) {
      try {
        // Appel à scores.php
        final url = Uri.parse('$API_BASE_URL/scores.php?userId=$userId&summary=1');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          percent = data['percent'] as int;
        }
      } catch (e) {
        // Gérer l'erreur si le serveur n'est pas joint
        percent = 0;
      }
    }

    // 3. Mettre à jour l'interface (comme "updatePercent" et "setState")
    setState(() {
      _userName = name;
      _securityPercent = percent;
      _secMsg = percent >= 80 ? '✨ Bravo ! Continue.' : percent >= 40 ? '💡 Tu progresses.' : '🚀 Commence un module !';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        automaticallyImplyLeading: false, // Cache la flèche "retour"
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [ const ThemeToggleButton() ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Indicateur de chargement
          : _buildBody(context), // Affiche le corps quand les données sont prêtes
    );
  }

  // Le corps principal de votre dashboard
  Widget _buildBody(BuildContext context) {
    // SingleChildScrollView permet de faire défiler si le contenu est trop long
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      // C'est le début de votre ".dash-left"
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Équivalent de <p id="welcome">
          Text(
            'Salut $_userName ! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // --- MODULE : Progression ---
          Text(
            "Progression",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Équivalent de votre carte de progression
          _buildProgressCard(),

          const SizedBox(height: 24),

          // --- MODULE : Modules d'apprentissage ---
          Text(
            "Modules d'apprentissage",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Équivalent de #modules-grid
          _buildModulesGrid(),

          const SizedBox(height: 24),
          
          // --- MODULE : Widgets de droite (Challenge, etc.) ---
          // Sur mobile, on les met en dessous.
          // C'est l'équivalent de votre #dash-side
          _buildRightSidebar(),
        ],
      ),
    );
  }

  // --- Widgets pour construire le Dashboard ---

  // Équivalent de la carte de progression
  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Niveau de sécurité'),
                // Équivalent #secPct
                Text(
                  '$_securityPercent%',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Équivalent .progress et #secBar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _securityPercent / 100.0,
                minHeight: 10,
                backgroundColor: const Color(0xFFE8EDF6),
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            // Équivalent #secMsg
            Text(_secMsg, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Équivalent de #modules-grid
  Widget _buildModulesGrid() {
    // La liste de vos modules
    final modules = [
      {'id': 'phishing', 't': 'Quiz Phishing', 'icon': '📨', 'desc': 'Repérer les emails suspects.'},
      {'id': 'social', 't': 'Instagram', 'icon': '📱', 'desc': 'Sécuriser ton compte.'},
      {'id': 'password', 't': 'Mots de passe', 'icon': '🔑', 'desc': 'Générer des mots de passe forts.'},
      {'id': 'shopping', 't': 'Shopping', 'icon': '🛒', 'desc': 'Acheter en sécurité.'},
    ];

    // GridView recrée votre .grid
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // La page scrolle déjà
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colonnes
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9, // Ajustez si nécessaire
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${module['icon']} ${module['t']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(module['desc']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const Spacer(), // Pousse le bouton en bas
                Align(
                  alignment: Alignment.bottomRight,
                  // On utilise un OutlinedButton pour le style "ghost"
                  child: OutlinedButton(
                    child: const Text('Ouvrir'),
                    // ===============================================
                    // MISE À JOUR : Ajout de la navigation
                    // ===============================================
                    onPressed: () {
                      // On navigue vers le bon écran
                      Widget? screen;
                      switch (module['id']) {
                        case 'phishing':
                          screen = const PhishingScreen();
                          break;
                        case 'social':
                          screen = const SocialScreen();
                          break;
                        case 'password':
                          screen = const PasswordScreen();
                          break;
                        case 'shopping':
                          screen = const ShoppingScreen();
                          break;
                      }
                      
                      if (screen != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => screen!)// Ouvre l'écran en mode "push"
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Équivalent de #dash-side et initRightColumn()
  Widget _buildRightSidebar() {
    // On recrée les widgets de la colonne de droite
    return Column(
      children: [
        // --- Widget Streak ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🔥 Série de jours", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("0 jours d'affilée", style: TextStyle(fontSize: 16)),
                // TODO: Ajouter la logique de "streak"
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // --- Widget Objectif ---
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🎯 Objectif semaine", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Atteindre 80% de sécurité.", style: TextStyle(color: Colors.grey)),
                // TODO: Ajouter la barre de progression de l'objectif
              ],
            ),
          ),
        ),
        // TODO: Ajouter les autres cartes (Alertes, Raccourcis, Challenge)
      ],
    );
  }
}