import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/apprenant/ajout_ticket.dart';
import 'Screens/authentication_screen.dart';
import 'Screens/bienvenue.dart';

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
      theme: ThemeData(
        hintColor: Colors.orange, // Couleur de fond par défaut
      ),
      home: Bienvenue(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1A164C),
      //appBar: AppBar(title: const Text("Gestion de Tickets")),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bienvenue!"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text("page de connexion"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AjoutTicket()),
                    );
                  },
                  child: const Text("Ajout tickets"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
