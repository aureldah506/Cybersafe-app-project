// lib/password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  double _length = 12.0;
  bool _useUpper = true;
  bool _useNum = true;
  bool _useSym = true;
  String _password = '';
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const charsLower = 'abcdefghijklmnopqrstuvwxyz';
    const charsUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const charsNum = '0123456789';
    const charsSym = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = charsLower;
    if (_useUpper) chars += charsUpper;
    if (_useNum) chars += charsNum;
    if (_useSym) chars += charsSym;

    final random = Random.secure();
    setState(() {
      _password = String.fromCharCodes(Iterable.generate(
        _length.round(),
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur de mots de passe 🔑'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Carte 1: Résultat
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: _password),
                    readOnly: true,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe généré',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() { _obscureText = !_obscureText; });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _password));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copié dans le presse-papiers!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton( // Style ".btn.ghost"
                      onPressed: _generatePassword,
                      child: const Text('Nouveau'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Carte 2: Paramètres
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Paramètres", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Longueur: '),
                      Text(
                        _length.round().toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _length,
                    min: 6,
                    max: 30,
                    divisions: 24,
                    label: _length.round().toString(),
                    onChanged: (value) {
                      setState(() { _length = value; });
                      _generatePassword();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Majuscules (A-Z)'),
                    value: _useUpper,
                    onChanged: (value) {
                      setState(() { _useUpper = value; });
                      _generatePassword();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Chiffres (0-9)'),
                    value: _useNum,
                    onChanged: (value) {
                      setState(() { _useNum = value; });
                      _generatePassword();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Symboles (!@#\$…)'),
                    value: _useSym,
                    onChanged: (value) {
                      setState(() { _useSym = value; });
                      _generatePassword();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}