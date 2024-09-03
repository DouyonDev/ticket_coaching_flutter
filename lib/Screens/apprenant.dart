import 'package:flutter/material.dart';
import 'package:ticket_coaching_flutter/Screens/profil.dart';
import 'package:ticket_coaching_flutter/Screens/tickets_resolu_tout.dart';

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
    Center(child: Text('Page 3', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
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
      body: _pages[_selectedIndex],  // Affichage de la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,  // Index de l'élément sélectionné
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,  // Appel de la méthode lorsqu'un élément est tapé
      ),
    );
  }
}