import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        // Connexion réussie, vous pouvez naviguer vers une autre page ici
        print('Connexion réussie : ${userCredential.user?.email}');
      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs d'authentification
        if (e.code == 'user-not-found') {
          print('Aucun utilisateur trouvé pour cet email.');
        } else if (e.code == 'wrong-password') {
          print('Mot de passe incorrect.');
        } else {
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
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Image.asset(
              "assets/images/logoDeme.png", // Chem in vers le logo
              height: 150,
            ),
            const Text(
              "Se connecter",
              style: TextStyle(
                fontSize: 24,
                //fontWeight: FontWeight.bold,
                color: Color(0xffF79621),
              ),
            ),
            const SizedBox(height: 100),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Veuillez entrer un email valide.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      iconColor: const Color(0xffA6A6A6),
                      labelText: 'Votre e-mail',
                      labelStyle: const TextStyle(color: Color(0xffA6A6A6)),
                      prefixIcon: const Icon(Icons.mail),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit comporter au moins 6 caractères.';
                      }
                      return null;
                    },
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Gérer le mot de passe oublié ici
                      },
                      child: Text("Mot de passe oublié ?"),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text("Se connecter"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
