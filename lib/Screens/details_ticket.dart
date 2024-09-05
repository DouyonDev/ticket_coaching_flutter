import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ticket_coaching_flutter/Screens/apprenant/modification_ticket.dart';
import 'package:ticket_coaching_flutter/Screens/widgets/confirmation_dialog.dart';
import 'package:ticket_coaching_flutter/Screens/widgets/message_modale.dart';

import 'chat_screen.dart';

class TicketDetail extends StatefulWidget {

  final Map<String, dynamic> ticketData;
  TicketDetail({required this.ticketData});

  @override
  _TicketDetailState createState() => _TicketDetailState();
}

class _TicketDetailState extends State<TicketDetail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _responseController = TextEditingController();
  bool _isPriseEnChargeClicked = false;

  Future<String> _getUserRole(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('utilisateurs').doc(userId).get();
    return userDoc['role'] ?? 'Role non trouvé'; // Par défaut
  }



  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final String userId = user?.uid ?? '';
    final String ticketStatut = widget.ticketData['statut'] ?? '';
    final String ticketApprenantId = widget.ticketData['id_apprenant'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
            'Détail du Ticket',
            style: TextStyle(
              fontSize: 30,
            ),),
        backgroundColor: const Color(0xff1E1C40),
      ),
      body: FutureBuilder<String>(
        future: _getUserRole(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xffF79621),));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors de la récupération du rôle.'));
          }

          final String userRole = snapshot.data ?? 'UTILISATEUR';
          final bool isFormateur = userRole == 'FORMATEUR';

          return SingleChildScrollView(
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
                  if (ticketStatut == 'en_attente' || ticketStatut == 'en_cours' && isFormateur) _buildPriseEnChargeSection(isFormateur),
                  if (ticketStatut == 'resolu') _buildReponseSection(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: userId == ticketApprenantId // Afficher le bouton flottant uniquement si l'utilisateur est l'apprenant
          ? SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color(0xff0E39C6),
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.delete),
            label: 'Supprimer',
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmationDialog(
                    title: 'Confirmation : Êtes-vous sûr de vouloir supprimer ce ticket ?',
                    content: ' Attention : votre ticket sera supprimé définitivement.',
                    onConfirm: () async {
                      print(widget.ticketData['id_ticket']);
                      // Supprimer le ticket de Firestore
                      try {
                        await FirebaseFirestore.instance
                            .collection('tickets')
                            .doc(widget.ticketData['id_ticket'])
                            .delete();
                        //Navigator.of(context).pop(); // Ferme la boîte de dialogue
                        // Afficher un message de succès
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const MessageModale(
                              title: "Supprimer",
                              content: "Votre ticket a été supprimer",
                            );
                          },
                        );
                        // Attendre 2 secondes avant de fermer la boîte de dialogue et revenir à la page précédente
                        Future.delayed(const Duration(seconds: 4), () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        });
                      } catch (e) {
                        // Gérer les erreurs si la suppression échoue
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de la suppression : $e'),
                          ),
                        );
                      }
                    },
                    onCancel: () {
                      Navigator.of(context).pop(); // Ferme la boîte de dialogue
                    },
                  );
                },
              );
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.edit),
            label: 'Modifier',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModificationTicket(
                    ticketData: widget.ticketData,
                  ),
                ),
              );
            },
          ),
        ],
      )
          : null,
    );
  }


  Widget _buildFirstSection() {
    return Container(
      padding: const EdgeInsets.all(10.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.ticketData['categorie'] ?? 'Sans catégorie',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              Text(
                widget.ticketData['apprenant'] ?? 'Apprenant inconnu',
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date Ajout: ${(widget.ticketData['created_at'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                ),
              ),
              Text(
                'Statut : ${widget.ticketData['statut']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.ticketData['statut'] == 'resolu' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Titre",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.ticketData['titre'] ?? 'Pas de contenu pour le titre',
            style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildThirdSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.ticketData['description'] ?? 'Pas de contenu pour la description',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriseEnChargeSection(bool isFormateur) {
    if (!isFormateur) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            // Mettre à jour le statut du ticket à "en_cours" et ajouter l'ID du formateur
            await FirebaseFirestore.instance
                .collection('tickets')
                .doc(widget.ticketData['id'])
                .update({
              'statut': 'en_cours',
              'id_formateur': _auth.currentUser?.uid,
            });

            setState(() {
              widget.ticketData['statut'] = 'en_cours';
              widget.ticketData['id_formateur'] = _auth.currentUser?.uid;
              _isPriseEnChargeClicked = true; // Afficher la section de réponse et le bouton "Valider"
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: const Color(0xff0E39C6),
          ),
          child: const Text('Prise en charge'),
        ),
        const SizedBox(height: 20),
        if (_isPriseEnChargeClicked || (widget.ticketData['statut'] == 'en_cours' && widget.ticketData['id_formateur'] == _auth.currentUser?.uid)) ...[
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
      ],
    );
  }

  //Partie reponse
  Widget _buildReponseSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Réponse",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.ticketData['reponse'] ?? 'Pas de contenu pour la réponse',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              //print(widget.ticketData['id_ticket']);
              _createChat(widget.ticketData['id_ticket'],
                  widget.ticketData['id_formateur'],
                  widget.ticketData['id_apprenant']);
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(chatId: widget.ticketData['id_ticket']),
                ),
              );*/
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: const Color(0xff0E39C6),
            ),
            icon: const Icon(Icons.chat),
            //child: const Text('Valider'),
          ),
        ],
      ),
    );

  }

  //fonction pour créer un chat
  void _createChat(String ticketId, String formateurId, String apprenantId) async {
    final existingChat = await FirebaseFirestore.instance
        .collection('chats')
        .where('ticket_id', isEqualTo: ticketId)
        .where('formateur_id', isEqualTo: formateurId)
        .where('apprenant_id', isEqualTo: apprenantId)
        .get();

    if (existingChat.docs.isEmpty) {
      // Si le chat n'existe pas, on le crée
      await FirebaseFirestore.instance.collection('chats').add({
        'ticket_id': ticketId,
        'formateur_id': formateurId,
        'apprenant_id': apprenantId,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    // Rediriger vers la page de chat
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chatId: ticketId)),
    );
  }


}
