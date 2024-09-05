import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/affichage_ticket.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class TicketsResoluTout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser;

    /*if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Les tickets résolus')),
        body: const Center(child: Text('Vous devez être connecté pour voir vos tickets.')),
      );
    }*/

    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff1E1C40),
        toolbarHeight: 100,
        title: const Column(
          children: [
            SizedBox(height: 0),
            Text(
              'Liste des tickets résolus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0), // Espace entre le texte et la barre de recherche
            SizedBox(
              width: double.infinity,
              height: 40.0,
              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(
                    color: Color(0xffA6A6A6),
                  ),
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.transparent, // Fond de la barre de recherche
                ),
              ),
            ),
          ],
        ),
        centerTitle: true, // Pour centrer le contenu du titre
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('statut', isEqualTo: 'resolu') // Filtrer les tickets par statut "resolu"
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xffF79621),));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun ticket résolu trouvé.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id_ticket'] = doc.id;

              // Création d'une instance d'AffichageTicket en lui passant les données
              return AffichageTicket(ticketData: data);
            }).toList(),
          );


        },
      ),
    );
  }
}
