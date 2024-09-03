import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TicketDetail extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  TicketDetail({required this.ticketData});

  @override
  _TicketDetailState createState() => _TicketDetailState();
}

class _TicketDetailState extends State<TicketDetail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _responseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final String userId = user?.uid ?? '';
    final String ticketStatut = widget.ticketData['statut'] ?? '';
    final bool isFormateur = widget.ticketData['role'] == 'FORMATEUR';

    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du Ticket'),
        backgroundColor: const Color(0xff1E1C40),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFirstSection(),
              const SizedBox(height: 20),
              _buildSecondSection(),
              const SizedBox(height: 20),
              _buildThirdSection(),
              const SizedBox(height: 20),
              if (ticketStatut == 'en_attente' && isFormateur) _buildPriseEnChargeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.ticketData['categorie'] ?? 'Sans catégorie',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.ticketData['apprenant'] ?? 'Apprenant inconnu',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date Ajout: ${(widget.ticketData['created_at'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              'Statut : ${widget.ticketData['statut']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.ticketData['statut'] == 'resolu' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.ticketData['titre'] ?? 'Sans titre',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.ticketData['contenu_titre'] ?? 'Pas de contenu pour le titre',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildThirdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.ticketData['description'] ?? 'Pas de description disponible',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPriseEnChargeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            // Mettre à jour le statut du ticket à "en_cours"
            await FirebaseFirestore.instance
                .collection('tickets')
                .doc(widget.ticketData['id'])
                .update({'statut': 'en_cours'});

            setState(() {
              widget.ticketData['statut'] = 'en_cours';
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: const Color(0xff0E39C6),
          ),
          child: const Text('Prise en charge'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _responseController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Votre réponse',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            // Enregistrer la réponse dans Firestore
            await FirebaseFirestore.instance
                .collection('tickets')
                .doc(widget.ticketData['id'])
                .update({'reponse': _responseController.text});

            // Mettre à jour le statut à "resolu"
            await FirebaseFirestore.instance
                .collection('tickets')
                .doc(widget.ticketData['id'])
                .update({'statut': 'resolu'});

            setState(() {
              widget.ticketData['statut'] = 'resolu';
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: const Color(0xff0E39C6),
          ),
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
