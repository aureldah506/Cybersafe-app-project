// lib/chat_screen.dart
import 'package:flutter/material.dart';
import 'theme_toggle_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// Classe pour stocker un message
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {this.isUser = false});
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  
  // Vos questions rapides
  final List<String> _quickQuestions = [
    'mot de passe fort',
    'c\'est du phishing ?',
    'securiser instagram'
  ];

  @override
  void initState() {
    super.initState();
    // Premier message du bot
    _messages.add(ChatMessage("Bonjour ! Comment puis-je vous aider ?"));
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Ajoute le message de l'utilisateur
    setState(() {
      _messages.add(ChatMessage(text, isUser: true));
      _controller.clear();
    });

    // Réponse du bot (logique de app_with_php.js)
    String response = _getBotResponse(text);
    
    // Ajoute la réponse du bot après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(ChatMessage(response));
      });
    });
  }

  String _getBotResponse(String text) {
    final s = text.toLowerCase();
    if (s.contains('phishing')) return 'Regardez le domaine, l’orthographe, et évite de cliquer. Utilise le module "Phishing".';
    if (s.contains('mot de passe') || s.contains('password')) return 'Utilise 12+ caractères, majuscules/chiffres/symboles. Un mot différent par site.';
    if (s.contains('instagram')) return 'Active 2FA, compte privé, alertes de connexion. Va au module Instagram.';
    return 'Je peux t\'aider sur: mots de passe, phishing, instagram.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant 💬'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [ const ThemeToggleButton() ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          
                    // Questions rapides
          Padding( // On ajoute un widget Padding autour
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // On met le padding ici
            child: Wrap(
              spacing: 8.0,
              // (on supprime la ligne 'padding:' d'ici)
              children: _quickQuestions.map((q) {
                return ActionChip(
                  label: Text(q),
                  onPressed: () => _sendMessage(q),
                );
              }).toList(),
            ),
          ),

          // Barre de saisie
          _buildTextInput(),
        ],
      ),
    );
  }

  // Une bulle de message
  Widget _buildMessageBubble(ChatMessage msg) {
    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = msg.isUser ? Theme.of(context).primaryColor : Colors.grey.shade200;
    final textColor = msg.isUser ? Colors.white : Colors.black87;

    return Container(
      alignment: align,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(msg.text, style: TextStyle(color: textColor)),
      ),
    );
  }

  // La barre de saisie en bas
  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Écris ton message…',
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => _sendMessage(_controller.text),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}