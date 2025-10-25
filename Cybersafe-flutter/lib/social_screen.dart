// lib/social_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart'; // Pour API_BASE_URL

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  // Vos étapes
  final List<Map<String, String>> _steps = [
    {'k': 'ig_2fa', 't': 'Activer la 2FA', 'desc': 'Paramètres > Sécurité > Authentification à deux facteurs.'},
    {'k': 'ig_priv', 't': 'Compte privé', 'desc': 'Paramètres > Confidentialité > Compte privé.'},
    {'k': 'ig_login', 't': 'Alertes de connexion', 'desc': 'Paramètres > Activité de connexion > Alertes.'},
  ];

  Map<String, bool> _completedSteps = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> loadedSteps = {};
    for (var step in _steps) {
      loadedSteps[step['k']!] = prefs.getBool(step['k']!) ?? false;
    }
    setState(() {
      _completedSteps = loadedSteps;
      _isLoading = false;
    });
  }

  Future<void> _updateStep(String key, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, isCompleted);
    
    setState(() {
      _completedSteps[key] = isCompleted;
    });

    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('cs_user_id') ?? 0;
    if (userId == 0) return;

    final score = _completedSteps.values.where((v) => v).length;
    final total = _steps.length;

    try {
      // Appel à scores.php
      await http.post(
        Uri.parse('$API_BASE_URL/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'module': 'instagram',
          'level': 'guide',
          'score': score,
          'total': total,
        }),
      );
    } catch (e) {
      // Erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    int score = _completedSteps.values.where((v) => v).length;
    int total = _steps.length;
    double progress = total > 0 ? score / total : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécuriser Instagram 📱'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Carte de progression
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progression'),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('$score/$total étapes complétées', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Liste des étapes
                ..._steps.map((step) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: CheckboxListTile(
                      title: Text(step['t']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(step['desc']!),
                      value: _completedSteps[step['k']!],
                      onChanged: (bool? value) {
                        _updateStep(step['k']!, value ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  );
                }),
              ],
            ),
    );
  }
}