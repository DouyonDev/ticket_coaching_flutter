import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ModificationApprenant extends StatefulWidget {
  @override
  _ModificationApprenantState createState() => _ModificationApprenantState();
}

class _ModificationApprenantState extends State<ModificationApprenant> {
  String? _imagePath;
  late TextEditingController _prenomController;
  late TextEditingController _nomController;

  @override
  void initState() {
    super.initState();

    // Initialisation des contrôleurs de texte avec les valeurs actuelles de l'utilisateur
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('utilisateurs').doc(user.uid).get();
      setState(() {
        _prenomController = TextEditingController(text: userData['prenom']);
        _nomController = TextEditingController(text: userData['nom']);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bloc pour la photo de profil
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage: _imagePath != null
                            ? FileImage(File(_imagePath!))
                            : const AssetImage('assets/images/boy.png')
                        as ImageProvider, // Remplacez par le chemin de votre image
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${_prenomController.text} ${_nomController.text}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // Bloc pour la modification des informations
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Enregistrer les modifications dans Firestore
                      FirebaseFirestore.instance.collection('utilisateurs').doc(user?.uid).update({
                        'prenom': _prenomController.text,
                        'nom': _nomController.text,
                        // Ajoutez ici la mise à jour du rôle ou d'autres champs si nécessaire
                      });
                      Navigator.of(context).pop(); // Retour à la page précédente
                    },
                    child: const Text('Enregistrer les modifications'),
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
