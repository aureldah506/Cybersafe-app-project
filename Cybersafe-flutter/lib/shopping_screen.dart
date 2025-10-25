// lib/shopping_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Pour API_BASE_URL

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late Future<List<String>> _tipsFuture;

  // Vos listes hardcodées
  final List<String> _redFlags = [
    'Prix trop beau',
    'Domaine copié',
    'Demande d’infos bancaires',
    'Pas de mentions légales'
  ];
  final List<String> _checklist = [
    'HTTPS présent',
    'Avis vérifiés',
    'Contact clair',
    'Politique retours'
  ];

  @override
  void initState() {
    super.initState();
    _tipsFuture = _fetchTips();
  }

  Future<List<String>> _fetchTips() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/tips.php'));
      if (response.statusCode == 200) {
        // La réponse est une List<dynamic>
        final List<dynamic> data = json.decode(response.body);
        // On la transforme en List<String>
        return data.map((tip) => tip['text'].toString()).toList();
      } else {
        throw Exception('Failed to load tips');
      }
    } catch (e) {
      // En cas d'erreur, on retourne une liste par défaut
      return [
        'Vérifie le cadenas HTTPS avant d’acheter.',
        'Active la double authentification (2FA).',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achats en ligne sûrs 🛒'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner
          Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shopping en sécurité", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text("Apprends à identifier les sites fiables et éviter les arnaques.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Conseils (via API)
          Text("Conseils", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<String>>(
            future: _tipsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Erreur de chargement des conseils.');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Aucun conseil trouvé.');
              }
              // Affiche la liste des conseils
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: snapshot.data!.map((tip) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('• $tip'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          // Signaux d'alarme
          _buildListCard(
            '⚠️ Signaux d\'alarme',
            _redFlags,
            Colors.red.withOpacity(0.05),
          ),
          
          const SizedBox(height: 16),
          // Checklist rapide
          _buildListCard(
            '✅ Checklist rapide',
            _checklist,
            Colors.green.withOpacity(0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<String> items, Color bgColor) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('• $item'),
            )),
          ],
        ),
      ),
    );
  }
}