import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/affichage_ticket.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class TicketsTous extends StatefulWidget {
  @override
  _TicketsTousState createState() => _TicketsTousState();
}

class _TicketsTousState extends State<TicketsTous> {
  String selectedStatus = 'tout'; // Par défaut, on affiche tous les tickets

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Tickets')),
        body: const Center(
            child: Text(
                'Vous devez être connecté pour voir vos tickets.',
                style: TextStyle(
                  color: Colors.white,
                ),
            )
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1C40),
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: const Column(
          children: [
            SizedBox(
              child: Text(
                "Liste des tickets",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),

      // Ajout des boutons de filtre
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton('Tout', 'tout'),
              _buildFilterButton('En attente', 'en_attente'),
              _buildFilterButton('En cours', 'en_cours'),
              _buildFilterButton('Resolu', 'resolu'),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTicketsStream(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Aucun ticket trouvé.',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                      )
                  );
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id_ticket'] = doc.id;//Ajouter l'id du ticket
                    return AffichageTicket(ticketData: data);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. Construire un bouton de filtre
  Widget _buildFilterButton(String label, String status) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedStatus == status ? const Color(0xff0E39C6) : Colors.white,
        minimumSize: const Size(10, 20), // Ajustez ici la longueur et la largeur du bouton
        textStyle: const TextStyle(
          fontSize: 10, // Ajustez ici la taille de la police
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Pour arrondir les coins si nécessaire
          side: BorderSide(color: selectedStatus == status ? Colors.transparent : Colors.black), // Ajoutez une bordure si nécessaire
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selectedStatus == status ? Colors.white : Colors.black, // Changement de couleur du texte
        ),
      ),
    );

  }

  // 4. Fonction pour obtenir les tickets en fonction du statut sélectionné
  Stream<QuerySnapshot> _getTicketsStream(User user) {
    if (selectedStatus == 'tout') {
      return FirebaseFirestore.instance
          .collection('tickets')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('tickets')
          .where('statut', isEqualTo: selectedStatus)
          .snapshots();
    }
  }

}
