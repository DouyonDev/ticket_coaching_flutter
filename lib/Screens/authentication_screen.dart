import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticket_coaching_flutter/Screens/apprenant/apprenant.dart';
import 'package:ticket_coaching_flutter/Screens/formateur/formateur.dart';
import 'package:ticket_coaching_flutter/Screens/widgets/message_modale.dart';


import 'admin/admin.dart';
import 'apprenant/ajout_ticket.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _obscureText = true;

  // Instance de FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour gérer la soumission du formulaire
  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      _formKey.currentState?.save();
      try {
        // Tentative de connexion avec email et mot de passe
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // Récupérer le rôle de l'utilisateur connecté
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(userCredential.user!.uid)
            .get();

        String userRole = userDoc['role'];
        // Connexion réussie, vous pouvez naviguer vers une autre page ici
        print('Connexion réussie : ${userCredential.user?.email}, son role est : ${userRole}');
        // Afficher la boîte de dialogue modale de succès
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const MessageModale(
              title: "Success",
              content: "Connexion réussie",
            );
          },
        );
        // Redirection en fonction du rôle
        if (userRole == 'ADMIN') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Admin()),);
        } else if (userRole == 'APPRENANT') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Apprenant()),);
        } else if (userRole == 'FORMATEUR') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Formateur()),);
        }else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AjoutTicket()),);
        }
      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs d'authentification
        if (e.code == 'user-not-found') {
          print('Aucun utilisateur trouvé pour cet email.');
          // Afficher la boîte de dialogue modale de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Erreur",
                content: "Aucun utilisateur trouvé pour cet email.",
              );
            },
          );
        } else if (e.code == 'wrong-password') {
          print('Mot de passe incorrect.');
          // Afficher la boîte de dialogue modale de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Erreur",
                content: "Mot de passe incorrect.",
              );
            },
          );
        } else {
          // Afficher la boîte de dialogue modale de succès
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const MessageModale(
                title: "Erreur : Problème d'authentification",
                content: "Veuillez revérifier vos coordonnées saisies",
              );
            },
          );
          print('Erreur d\'authentification : ${e.message}');
        }
      } catch (e) {

        print('Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/logoDeme.png", // Chemin vers le logo
                height: 150,
              ),
              const Text(
                "Connexion",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xffF79621),
                ),
              ),
              const SizedBox(height: 100),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
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
                        iconColor: Color(0xffA6A6A6),
                        labelText: 'Votre e-mail',
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
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('password'),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Le mot de passe doit comporter au moins 6 caractères.';
                        }
                        return null;
                      },
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        labelStyle: const TextStyle(color: Color(0xffA6A6A6)),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Gérer le mot de passe oublié ici
                        },
                        child: const Text("Mot de passe oublié ?"),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      child: const Text("Se connecter"),
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
