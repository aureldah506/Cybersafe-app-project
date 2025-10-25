======================================
     Instructions d'installation
          CYBERSAFE App (WAMP + Flutter)
======================================

Ce ZIP contient trois éléments :
1.  /cybersafe-backend/   (Le serveur PHP)
2.  /cybersafe-flutter/ (L'application Flutter)
3.  /Visuels/   (Aperçu de l'application terminée)

---
## 🚨 PRÉREQUIS OBLIGATOIRES 🚨
---

Avant de commencer, vous DEVEZ installer les outils suivants sur votre ordinateur :

1.  **WampServer (ou WAMP/XAMPP)** : Pour faire tourner le serveur PHP et la base de données.
2.  **Flutter SDK** : Suivez le guide officiel sur flutter.dev pour l'installer.
3.  **VS Code** (recommandé) : L'éditeur de code.
4.  **Android Studio** : Nécessaire pour l'émulateur Android (AVD Manager).

Assurez-vous que vous pouvez lancer la commande `flutter doctor` dans votre terminal sans erreur majeure.

---
## Étape 1 : Installation du Backend (WAMP)
---

1.  Assurez-vous que WampServer est installé et lancé.
2.  Copiez le dossier `/cybersafe-backend/` de ce ZIP vers votre dossier `www` (ex: C:\wamp64\www\).
3.  Ouvrez phpMyAdmin (http://localhost/phpmyadmin).
4.  Créez une nouvelle base de données nommée `cybersafe`.
5.  Sélectionnez cette base `cybersafe` et ouvrez l'onglet "Importer".
6.  Importez le fichier `cybersafe.sql` (qui se trouve dans /cybersafe-backend/).
7.  Vérifiez que le serveur fonctionne en ouvrant cette URL dans votre navigateur :
    http://localhost/cybersafe-backend/tips.php
    (Vous devriez voir du texte JSON).

---
## Étape 2 : Lancement de l'Application (Flutter)
---

1.  Ouvrez le dossier `/cybersafe-flutter/` de ce ZIP dans VS Code.
2.  Dans le terminal de VS Code, installez les dépendances du projet :
    flutter pub get

3.  TRÈS IMPORTANT : Vérifiez l'adresse du serveur.
    Ouvrez le fichier `/cybersafe-flutter/lib/main.dart`.
    Vérifiez la ligne `API_BASE_URL`.

    - Si vous utilisez un ÉMULATEUR Android(Android Studio installé plus haut) :
      const String API_BASE_URL = 'http://10.0.2.2/cybersafe-backend';
    
    - Si vous utilisez un VRAI TÉLÉPHONE (connecté en USB) :
      Remplacez par l'adresse IP de votre PC sur le réseau local (ex: 'http://192.168.1.10/cybersafe-backend')

4.  Lancez un émulateur (depuis Android Studio) ou connectez votre téléphone.
5.  Dans le terminal de VS Code, lancez l'application :
    flutter run