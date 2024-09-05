import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///  Created by abdoulaye.douyon on 04/09/2024.
class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String otherUserName = ''; // Nom de l'autre utilisateur

  @override
  void initState() {
    super.initState();
    _getOtherUserName(); // Récupérer le nom de l'autre utilisateur
  }

  void _getOtherUserName() async {
    // Récupérer les informations du chat pour obtenir l'ID de l'autre utilisateur
    DocumentSnapshot chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
    Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

    // Récupérer l'ID de l'autre utilisateur (différent de l'utilisateur actuel)
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String otherUserId = chatData['userIds'].firstWhere((id) => id != currentUserId);

    // Récupérer les informations de l'autre utilisateur depuis Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('utilisateurs').doc(otherUserId).get();
    setState(() {
      otherUserName = '${userDoc['nom']} ${userDoc['prenom']}';  // Récupérer le nom complet de l'utilisateur
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          otherUserName.isNotEmpty ? otherUserName : "Chat",  // Afficher le nom de l'utilisateur ou "Chat" par défaut
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: const Color(0xff1E1C40),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['sender_id'] == FirebaseAuth.instance.currentUser!.uid;
                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          decoration: BoxDecoration(
                            // Si c'est l'utilisateur actuel, on applique la couleur bleue, sinon un dégradé linéaire
                            color: !isMe ? const Color(0xffA6A6A6) : null, // Utilisez 'null' pour le dégradé
                            gradient: !isMe
                                ? null // Pas de gradient si c'est l'utilisateur actuel
                                : const LinearGradient(
                              begin: AlignmentDirectional.topCenter,
                              end: AlignmentDirectional.bottomCenter,
                              colors: [
                                Color(0xFF322D5E),
                                Color(0xFF005261),
                              ],
                              stops: [0.0035, 0.9973],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),


                          child: Text(
                            messageData['message'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                    color: Colors.white,
                  ),
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Tapez votre message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'sender_id': FirebaseAuth.instance.currentUser!.uid,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }
}
