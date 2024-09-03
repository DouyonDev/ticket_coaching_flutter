import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            'user_id': user.uid, // Enregistrement de l'ID de l'utilisateur
            'statut': "en_cours",
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ticket créé avec succès!'),
          ));
        } else {
          // Gérer le cas où l'utilisateur n'est pas connecté
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Vous devez être connecté pour créer un ticket.'),
          ));
        }
      } catch (e) {
        print('Erreur lors de l\'enregistrement du ticket : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créer un Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Champ Titre
              TextFormField(
                decoration: InputDecoration(labelText: 'Titre'),
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
              SizedBox(height: 20),

              // Liste déroulante des catégories
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Catégorie'),
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
              SizedBox(height: 20),

              // Champ Description
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
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
              SizedBox(height: 20),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Créer le Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}