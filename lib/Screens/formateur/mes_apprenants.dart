import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ajout_apprenant.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class MesApprenants extends StatefulWidget {
  @override
  _MesApprenantsState createState() => _MesApprenantsState();
}

class _MesApprenantsState extends State<MesApprenants> {
  String selectedStatus = 'tout'; // Par défaut, on affiche tous les tickets

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes Apprenants')),
        body: const Center(child: Text('Vous devez être connecté '
            'pour voir les apprenants que vous avez inscrits.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff1E1C40),
        toolbarHeight: 70,
        title: Column(
          children: [
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xff0E39C6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Espacement personnalisé
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AjoutApprenant()),
                );
              },
              child: const Text("Ajouter un apprenant"),
            ),
            const SizedBox(height: 50),
          ],
        ),
        centerTitle: true,
      ),

      // Ajout des boutons de filtre
      body: Column(
        children: [

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getApprenantParFormateur(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xffF79621),));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun apprenant inscrit par vous !!!.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildListItem(data);
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
  Stream<QuerySnapshot> _getApprenantParFormateur(User user) {
      return FirebaseFirestore.instance
          .collection('utilisateurs')
          .where('formateur_id', isEqualTo: user.uid)
          .snapshots();
  }

  // Widget chaque apprenant
  Widget _buildListItem(Map<String, dynamic> data) {
        return ListTile(
          subtitle: Container(height: 30),
          leading: CircleAvatar(
                radius: 30.0,
                backgroundImage: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                    ? NetworkImage(data['imageUrl'])  // Utiliser NetworkImage pour les images depuis Firebase Storage
                    : const AssetImage('assets/images/boy.png'),  // Utiliser AssetImage par défaut
              ),
          title: Text(
            '${data['nom']} ${data['prenom']}',  // Afficher nom et prénom
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          // onTap: () => onTap(),
        );

      }
}