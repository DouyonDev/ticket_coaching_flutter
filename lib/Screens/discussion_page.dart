import 'package:flutter/material.dart';

///  Created by abdoulaye.douyon on 04/09/2024.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class DiscussionsPage extends StatelessWidget {
  final String userId; // ID de l'utilisateur connecté

  DiscussionsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: fetchUserChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xffF79621),));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Erreur lors du chargement des discussions.'));
        }

        final chats = snapshot.data ?? [];

        if (chats.isEmpty) {
          return const Center(
              child: Text(
                  'Aucune discussion trouvée.',
                  style: TextStyle(
                    color: Colors.white,
                  ),
              )
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xff1E1C40),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff1E1C40),
            title: const Text(
                'Liste des discussions',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
          body: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index].data() as Map<String, dynamic>;

              return ListTile(

                title: _buildListItem(chat),//Text('Discussion avec ${chat['apprenant_id']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatId: chat['ticket_id']),
                    ),
                  );
                },
              );
                        },

          ),
        );
      },
    );
  }


  Future<List<QueryDocumentSnapshot>> fetchUserChats() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Première requête : récupérer les chats où l'utilisateur est formateur
    QuerySnapshot formateurChats = await FirebaseFirestore.instance
        .collection('chats')
        .where('formateur_id', isEqualTo: userId)
        .get();

    // Deuxième requête : récupérer les chats où l'utilisateur est apprenant
    QuerySnapshot apprenantChats = await FirebaseFirestore.instance
        .collection('chats')
        .where('apprenant_id', isEqualTo: userId)
        .get();

    // Combiner les deux listes de résultats
    List<QueryDocumentSnapshot> allChats = [
      ...formateurChats.docs,
      ...apprenantChats.docs
    ];

    return allChats;
  }

  //fonction pour construire un utilisateur
  Widget _buildListItem(Map<String, dynamic> data) {
    // Référence au document de l'apprenant
    DocumentReference InfoApprenant = FirebaseFirestore.instance.collection('utilisateurs').doc(data['apprenant_id']);

    return FutureBuilder<DocumentSnapshot>(
      future: InfoApprenant.get(),  // Récupérer les données de l'apprenant
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(color: Color(0xffF79621),);  // Affiche un indicateur de chargement
        }

        if (snapshot.hasError) {
          return const ListTile(
            title: const Text('Erreur lors du chargement des données'),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const ListTile(
            title: const Text('Utilisateur non trouvé'),
          );
        }

        // Récupérer les données de l'utilisateur
        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

        return ListTile(
          leading: CircleAvatar(
            radius: 30.0,
            backgroundImage: userData['imageUrl'] != null && userData['imageUrl'].isNotEmpty
                ? NetworkImage(userData['imageUrl'])  // Utiliser NetworkImage pour les images depuis Firebase Storage
                : const AssetImage('assets/images/boy.png'),  // Utiliser AssetImage par défaut
          ),
          title: Text(
            '${userData['nom']} ${userData['prenom']}',  // Afficher nom et prénom
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          // onTap: () => onTap(),
        );

      },
    );
  }


}
