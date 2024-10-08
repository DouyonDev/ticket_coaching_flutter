import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AjoutApprenant extends StatefulWidget {
  @override
  _AjoutApprenantState createState() => _AjoutApprenantState();
}

class _AjoutApprenantState extends State<AjoutApprenant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _prenom = '';
  String _nom = '';
  String _email = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour gérer la soumission du formulaire
  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      _formKey.currentState?.save();
      try {
        // Récupérer l'ID du formateur connecté
        final formateurId = FirebaseAuth.instance.currentUser?.uid;

        // Création de l'utilisateur apprenant dans Firebase Authentication avec un mot de passe par défaut
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: '12345678', // Mot de passe par défaut
        );

        // Enregistrement des informations de l'apprenant dans Firestore
        await FirebaseFirestore.instance.collection('utilisateurs').doc(userCredential.user!.uid).set({
          'prenom': _prenom,
          'nom': _nom,
          'email': _email,
          'role': 'APPRENANT', // Rôle par défaut
          'created_at': Timestamp.now(),
          'formateur_id': formateurId, // ID du formateur connecté
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apprenant ajouté avec succès')),
        );

        // Réinitialiser le formulaire après l'enregistrement
        _formKey.currentState?.reset();

      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs d'authentification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff1E1C40),
      ),
      backgroundColor: const Color(0xff1E1C40),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logoDeme.png", // Chemin vers le logo
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                "Ajout d'un apprenant",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xffF79621),
                ),
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      key: const ValueKey('prenom'),
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _prenom = value!;
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('nom'),
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.person_2_outlined),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _nom = value!;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('email'),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Veuillez entrer un email valide.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xff0E39C6),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Espacement personnalisé
                      ),
                      child: const Text("Enregistrer"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
