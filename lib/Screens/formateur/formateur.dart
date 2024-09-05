import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_coaching_flutter/Screens/formateur/mes_apprenants.dart';
import 'package:ticket_coaching_flutter/Screens/formateur/tickets_tous.dart';
import 'package:ticket_coaching_flutter/Screens/profil.dart';

import '../discussion_page.dart';


///  Created by abdoulaye.douyon on 02/09/2024.
class Formateur extends StatefulWidget {
  //Formateur({required Key key}) : super(key: key);

  @override
  _FormateurState createState() => _FormateurState();
}

class _FormateurState extends State<Formateur> {
  int _selectedIndex = 0;  // Index pour suivre l'élément sélectionné

  // Liste des widgets pour chaque page
  static final List<Widget> _pages = <Widget>[
    TicketsTous(),
    MesApprenants(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,  // Définir le fond comme transparent
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Optionnel, mais vous pouvez la laisser aussi
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add_sharp),
              label: 'Apprenants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Discussions',
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
      ),

    );
  }
}