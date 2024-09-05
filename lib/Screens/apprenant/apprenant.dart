import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_coaching_flutter/Screens/apprenant/tickets_resolu_tout.dart';
import 'package:ticket_coaching_flutter/Screens/profil.dart';

import '../discussion_page.dart';
import 'mes_tickets.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class Apprenant extends StatefulWidget {
  //Apprenant({required Key key}) : super(key: key);

  @override
  _ApprenantState createState() => _ApprenantState();
}

class _ApprenantState extends State<Apprenant> {
  int _selectedIndex = 0;  // Index pour suivre l'élément sélectionné

  // Liste des widgets pour chaque page
  static final List<Widget> _pages = <Widget>[
    TicketsResoluTout(),
    MesTickets(),
    DiscussionsPage(userId: FirebaseAuth.instance.currentUser!.uid),
    Profil(),
  ];

  // Méthode pour changer de page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xff1E1C40),
        child: _pages[_selectedIndex],// Affichage de la page sélectionnée
      ),
      bottomNavigationBar: BottomAppBar(
        shadowColor: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildIconButton(Icons.home, 0, 'Home'),
            _buildIconButton(Icons.business, 1, 'Tickets'),
            _buildIconButton(Icons.school, 2, 'Discussions'),
            _buildIconButton(Icons.person, 3, 'Profile'),
          ],
        ),
        color: const Color(0xff16142e), // Arrière-plan du BottomAppBar
      ),
    );
  }

  Widget _buildIconButton(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon),
          color: isSelected ? Colors.amber[800] : Colors.grey[400],
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        if (isSelected)
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.amber[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}