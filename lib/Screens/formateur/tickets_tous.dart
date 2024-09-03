import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_coaching_flutter/Screens/ajout_ticket.dart';
import 'package:ticket_coaching_flutter/Screens/details_ticket.dart';

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
        body: const Center(child: Text('Vous devez être connecté pour voir vos tickets.')),
      );
    }

    return Scaffold(
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
                  return const Center(child: Text('Aucun ticket trouvé.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildTicketItem(data);
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

  // 5. Construire un widget pour chaque ticket
  Widget _buildTicketItem(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetail(ticketData: data),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['categorie'] ?? 'Sans catégorie',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                data['titre'] ?? 'Sans titre',
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date Ajout: ${data['created_at'] != null
                        ? (data['created_at'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                        : 'Date non disponible'}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Statut : ${data['statut'] ?? 'Statut inconnu'}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: data['statut'] == 'resolu'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
