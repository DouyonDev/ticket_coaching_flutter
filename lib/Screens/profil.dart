import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_coaching_flutter/Screens/apropos.dart';
import 'package:ticket_coaching_flutter/Screens/authentication_screen.dart';
import 'package:ticket_coaching_flutter/Screens/modification_apprenant.dart';
import 'package:ticket_coaching_flutter/Screens/password_change.dart';

import 'aide_support.dart';

class Profil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    //print(user?.email);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Vous devez être connecté pour voir votre profil.')),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Impossible de récupérer les informations utilisateur.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                const SizedBox(height: 50),
                // Bloc avec photo de profil, nom, prénom, rôle et bouton crayon
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: AlignmentDirectional.bottomStart,
                      end: AlignmentDirectional.topEnd,
                      colors: [
                        Color(0xFF1C1939),
                        Color(0xFF005261),
                      ],
                      stops: [0.0035, 0.9973],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // Position de l'ombre
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 40.0,
                        backgroundImage: AssetImage('assets/images/boy.png'), // Remplacez par le chemin de votre image
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['prenom']} ${data['nom']}', // Affichage du prénom et nom
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              data['role'] ?? 'Rôle inconnu', // Affichage du rôle
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () {
                          // Action lors du clic sur le bouton crayon
                          // Naviguer vers la page de modification du profil
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ModificationApprenant()
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                // Liste des options
                Expanded(
                  child: ListView(
                    children: [
                      _buildListItem(
                        context,
                        icon: Icons.person,
                        title: 'Compte',
                        onTap: () {
                          // Action lors du clic sur "Compte"
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ModificationApprenant()
                          ));
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.help,
                        title: 'Aide et support',
                        onTap: () {
                          // Action lors du clic sur "Aide et support"
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AideSupport(),
                          ));
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.security,
                        title: 'Sécurité',
                        onTap: () {
                          // Action lors du clic sur "Sécurité"
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PasswordChange(),
                          ));
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.info,
                        title: 'À propos',
                        onTap: () {
                          // Action lors du clic sur "À propos"
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Apropos(),
                          ));
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.logout,
                        title: 'Déconnexion',
                        onTap: () {
                          // Action lors du clic sur "Déconnexion"
                          _showLogoutConfirmationDialog(context); // Afficher la boîte de dialogue de confirmation
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, {required IconData icon, required String title, required Function onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: () => onTap(),
    );
  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: <Widget>[
          TextButton(
            child: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
            },
          ),
          TextButton(
            child: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              _logout(context); // Déconnexion et retour à la page de connexion
            },
          ),
        ],
      );
    },
  );
}

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut(); // Déconnexion de l'utilisateur
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}
