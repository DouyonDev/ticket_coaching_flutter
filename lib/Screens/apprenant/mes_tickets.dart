import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/affichage_ticket.dart';
import '../widgets/boutons_filtre.dart';
import 'ajout_ticket.dart';

class MesTickets extends StatefulWidget {
  @override
  _MesTicketsState createState() => _MesTicketsState();
}

class _MesTicketsState extends State<MesTickets> {
  String selectedStatus = 'tout'; // Par défaut, on affiche tous les tickets

  void _updateStatus(String status) {
    setState(() {
      selectedStatus = status;
    });
  }

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
        title: Column(
          children: [
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AjoutTicket()),
                );
              },
              child: Text("Ajouter un ticket"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xff0E39C6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Espacement personnalisé
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: double.infinity,
              height: 40.0,
              child: Text(
                "Soumettez votre problème",
                style: TextStyle(
                  color: Color(0xff7B78AA),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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
              FilterButton(
                label: 'Tout',
                status: 'tout',
                selectedStatus: selectedStatus,
                onStatusSelected: _updateStatus,
              ),
              FilterButton(
                label: 'En attente',
                status: 'en_attente',
                selectedStatus: selectedStatus,
                onStatusSelected: _updateStatus,
              ),
              FilterButton(
                label: 'En cours',
                status: 'en_cours',
                selectedStatus: selectedStatus,
                onStatusSelected: _updateStatus,
              ),
              FilterButton(
                label: 'Résolu',
                status: 'resolu',
                selectedStatus: selectedStatus,
                onStatusSelected: _updateStatus,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTicketsStream(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xffF79621),));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text(
                          'Erreur lors de la récupération des tickets.',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                  );
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
                    data['id_ticket'] = doc.id;
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

  // 4. Fonction pour obtenir les tickets en fonction du statut sélectionné
  Stream<QuerySnapshot> _getTicketsStream(User user) {
    if (selectedStatus == 'tout') {
      return FirebaseFirestore.instance
          .collection('tickets')
          .where('id_apprenant', isEqualTo: user.uid)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('tickets')
          .where('id_apprenant', isEqualTo: user.uid)
          .where('statut', isEqualTo: selectedStatus)
          .snapshots();
    }
  }
}
