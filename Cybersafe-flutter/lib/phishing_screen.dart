// lib/phishing_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart'; // Pour API_BASE_URL

class PhishingScreen extends StatefulWidget {
  const PhishingScreen({super.key});

  @override
  State<PhishingScreen> createState() => _PhishingScreenState();
}

class _PhishingScreenState extends State<PhishingScreen> {
  // Vos questions, tirées de app_with_php.js
  final List<Map<String, String>> _questions = [
    {'q': '"Votre compte est bloqué, cliquez ici"', 'good': 'phishing'},
    {'q': 'Email du domaine officiel + demande 2FA', 'good': 'legit'},
    {'q': 'Lien raccourci bizarre bit.ly/xxxx', 'good': 'phishing'},
    {'q': 'Message interne via app officielle', 'good': 'legit'},
  ];

  String _currentView = 'select'; // 'select' ou 'quiz'
  int _currentIndex = 0;
  int _score = 0;
  String _level = 'Débutant';

  void _startQuiz(String level) {
    setState(() {
      _level = level;
      _currentView = 'quiz';
      _currentIndex = 0;
      _score = 0;
    });
  }

  void _answer(String choice) async {
    if (choice == _questions[_currentIndex]['good']) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      // Question suivante
      setState(() {
        _currentIndex++;
      });
    } else {
      // Fin du quiz
      await _saveScore();
      setState(() {
        _currentView = 'result';
      });
    }
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('cs_user_id') ?? 0;
    if (userId == 0) return;

    try {
      // Appel à scores.php
      await http.post(
        Uri.parse('$API_BASE_URL/scores.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'module': 'phishing',
          'level': _level,
          'score': _score,
          'total': _questions.length,
        }),
      );
      // TODO: Mettre à jour le score global (via Provider)
    } catch (e) {
      // Erreur silencieuse pour l'instant
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Phishing 📨'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentView(),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_currentView == 'select') {
      return _buildLevelSelection();
    } else if (_currentView == 'quiz') {
      return _buildQuizView();
    } else {
      return _buildResultView();
    }
  }

  // Écran de sélection de niveau
  Widget _buildLevelSelection() {
    return ListView(
      key: const ValueKey('select'),
      children: [
        _buildLevelCard('Débutant', 'Exemples simples.', () => _startQuiz('Débutant')),
        _buildLevelCard('Intermédiaire', 'Exemples plus difficiles.', () => _startQuiz('Intermédiaire')),
        _buildLevelCard('Avancé', 'Pièges courants.', () => _startQuiz('Avancé')),
      ],
    );
  }

  Widget _buildLevelCard(String title, String desc, VoidCallback onPressed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(desc, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton( // Utilise le style ".btn"
                onPressed: onPressed,
                child: const Text('Commencer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Écran du quiz
  Widget _buildQuizView() {
    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Column(
      key: const ValueKey('quiz'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(label: Text(_level)),
            Text('Score: $_score', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question['q']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton( // Style ".btn.ghost"
                  onPressed: () => _answer('legit'),
                  child: const Text('C’est légitime'),
                ),
                const SizedBox(height: 12),
                FilledButton( // Style ".btn"
                  onPressed: () => _answer('phishing'),
                  child: const Text('C’est du phishing'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Écran de résultat
  Widget _buildResultView() {
    return Card(
      key: const ValueKey('result'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Résultat',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '$_score / ${_questions.length}',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() { _currentView = 'select'; });
              },
              child: const Text('Rejouer'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Retourne au dashboard
              },
              child: const Text('Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}