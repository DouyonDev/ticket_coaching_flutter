import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'authentication_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Enlever le bandeau "DEBUG"
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion de Tickets")),
      body: Stack( // Utilisation d'un Stack pour superposer le fond et le contenu
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1C40), Color(0xFF00D7FF)], // Dégradé de couleurs
                begin: Alignment.center,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter( // Application d'un effet de flou
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0), // Couleur transparente pour voir le fond flouté
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Bienvenue!"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text("Voir les tickets"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

