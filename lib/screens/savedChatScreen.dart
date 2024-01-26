import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailsScreen extends StatelessWidget {
  final String chatId;

  ChatDetailsScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Details'),
      ),
      body: ChatMessages(chatId: chatId),
    );
  }
}

class ChatMessages extends StatelessWidget {
  final String chatId;
 late bool isUser;
  ChatMessages({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid) // Assuming the chat is under the user's collection
          .collection('chats')
          .doc(chatId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return CircularProgressIndicator();
        }

        final chatData = snapshot.data as DocumentSnapshot;
        final chatTitle = chatData['title'] ?? 'Untitled Chat';
        final chatMessages = chatData['messages'] as List<dynamic>;

        return ListView.builder(
          itemCount: chatMessages.length,
          itemBuilder: (ctx, index) {
            final message = chatMessages[index].toString();
            if(index %2==0){
              isUser=true;
            }else{
              isUser=false;
            }
            return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child:  Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 16.0,color: isUser?Colors.white : Colors.black ),
        ),
      ),
    );
          },
        );
      },
    );
  }
}
