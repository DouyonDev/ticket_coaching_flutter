import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class TicketsResoluTout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    /*if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Les tickets résolus')),
        body: const Center(child: Text('Vous devez être connecté pour voir vos tickets.')),
      );
    }*/

    return Scaffold(
      appBar: AppBar(
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun ticket résolu trouvé.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre de la catégorie en gros plan
                      Text(
                        data['categorie'] ?? 'Pas de catégorie sélectionnée',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Titre du ticket avec trois points pour la suite
                      Text(
                        data['titre'] ?? 'Sans titre',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(), // Trait de séparation

                      // Description sur deux lignes avec trois points pour la suite
                      Text(
                        data['description'] ?? 'Pas de description disponible',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16.0),

                      // Date et statut sur la même ligne
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //const Text("Date Ajout"),
                          // Date d'ajout du ticket
                          Text(
                            'Date Ajout: ${data['created_at'] != null
                                ? (data['created_at'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                                : 'Date non disponible'}',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                          ),


                          // Statut du ticket
                          Text(
                            'Statut : '+(
                                data['statut'] ?? 'Statut inconnu'),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: data['statut'] == 'resolu'
                                  ? Colors.green
                                  : Colors.red, // Couleur selon le statut
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );

        },
      ),
    );
  }
}
