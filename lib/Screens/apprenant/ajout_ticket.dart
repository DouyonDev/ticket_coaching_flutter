import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/message_modale.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class AjoutTicket extends StatefulWidget {
  //AjoutTicket({required Key key}) : super(key: key);

  @override
  _AjoutTicketState createState() => _AjoutTicketState();
}

class _AjoutTicketState extends State<AjoutTicket> {

  final _formKey = GlobalKey<FormState>();
  String _titre = '';
  String _categorie = '';
  String _description = '';
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Récupération des catégories dès que la page est initialisée
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = querySnapshot.docs.map((doc) => doc['nom'].toString()).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories : $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Enregistrement des données dans Firestore
          await FirebaseFirestore.instance.collection('tickets').add({
            'titre': _titre,
            'categorie': _categorie,
            'description': _description,
            'created_at': Timestamp.now(),
            'id_apprenant': user.uid, // Enregistrement de l'ID de l'utilisateur
            'statut': "en_attente",
          });
          /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ticket créé avec succès!'),
          ));*/
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Success",
                content: "Ticket créé avec succès !",
              );
            },
          );
        } else {
          // Gérer le cas où l'utilisateur n'est pas connecté
          /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Vous devez être connecté pour créer un ticket.'),
          ));*/
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Erreur",
                content: "Vous devez être connecté pour créer un ticket.",
              );
            },
          );
        }
      } catch (e) {
        print('Erreur lors de l\'enregistrement du ticket : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        foregroundColor: Colors.white,
          backgroundColor: const Color(0xff1E1C40),
          title: const Text(
            'Créer un Ticket',
            style: TextStyle(
              fontSize: 30,
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Champ Titre
                const SizedBox(height: 20),
                TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                      labelText: 'Titre',
                      labelStyle: TextStyle(
                        color: Color(0xffA6A6A6),
                      )
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _titre = value!;
                  },
                ),
                const SizedBox(height: 20),

                // Liste déroulante des catégories
                DropdownButtonFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      labelStyle: TextStyle(
                        color: Color(0xffA6A6A6),
                      )
                  ),
                  items: _categories.map((categorie) {
                    return DropdownMenuItem(
                      value: categorie,
                      child: Text(categorie),
                    );
                  }).toList(),
                  validator: (value) =>
                  value == null ? 'Veuillez sélectionner une catégorie' : null,
                  onChanged: (value) {
                    _categorie = value.toString();
                  },
                ),
                const SizedBox(height: 20),

                // Champ Description
                TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      )
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                const SizedBox(height: 50),

                // Bouton de soumission
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff0E39C6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Espacement personnalisé
                  ),
                  onPressed: _submitForm,
                  child: const Text('Créer le Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}