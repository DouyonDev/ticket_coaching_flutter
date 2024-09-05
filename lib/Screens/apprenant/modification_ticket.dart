import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ModificationTicket extends StatefulWidget {
  final Map<String, dynamic> ticketData;
  ModificationTicket({required this.ticketData});

  @override
  _ModificationTicketState createState() => _ModificationTicketState();
}

class _ModificationTicketState extends State<ModificationTicket> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titreController.text = widget.ticketData['titre'] ?? '';
    _descriptionController.text = widget.ticketData['description'] ?? '';
    _selectedCategory = widget.ticketData['categorie'] ?? '';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = snapshot.docs.map((doc) => doc['nom'] as String).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des categories : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
            'Modifier le Ticket',
            style: TextStyle(
              fontSize: 25,
            ),
        ),
        backgroundColor: const Color(0xff1E1C40),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              TextField(
                  controller: _titreController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    //filled: true,
                    //fillColor: Colors.white,
                  labelText: 'Titre',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  )
                  //border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                style: const TextStyle(
                  color: Colors.white,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  labelStyle: TextStyle(
                     color: Colors.grey,
                   ),
                  //border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  //border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Mettre à jour le ticket dans Firestore
                    await FirebaseFirestore.instance
                        .collection('tickets')
                        .doc(widget.ticketData['id_ticket'])
                        .update({
                      'titre': _titreController.text,
                      'description': _descriptionController.text,
                      'categorie': _selectedCategory,
                    });

                    // Revenir à la page précédente
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff0E39C6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Espacement personnalisé
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
