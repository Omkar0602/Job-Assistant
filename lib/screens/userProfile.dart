import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web/models/greeting.dart';
import 'package:flutter_web/screens/login.dart';
import 'package:flutter_web/screens/savedChatScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  UserDetailsScreen({required this.userId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  

  Future<void> _loadUserData() async {
    try {
      final DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(widget.userId).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final String name = userData['name'];
        final String email = userData['email'];

        setState(() {
          _name = name;
          _email = email;
        });
      }
    } catch (error) {
      // Handle any errors here
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        elevation: 20,
        actions: [
    TextButton(
      onPressed: () async{
        await LogoutHelper.logout(context);
      },
      child: Text(
        'Logout',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 30,),
             Padding(
              padding: EdgeInsets.only(left:20),
              child: Text("Hi,"+_name,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 30),),
            ),
            
            Padding(
              padding: const EdgeInsets.only(left:20),
              child: GreetingWidget(),
            ),
            
            SizedBox(height: 40),
            Text(
              'Saved Chats',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.deepPurple),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('chats')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No data available.');
                }

                final chatDocs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    final chat = chatDocs[index].data() as Map<String, dynamic>;
                    final chatTitle = chat['title'] ?? 'Untitled Chat';
                    final chatId = chatDocs[index].id;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width/4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 10,
                          )
                          ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(chatTitle,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 20),),
                              Expanded(
                                child: Container()),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailsScreen(chatId: chatId),
                                    ),
                                  );
                                },
                                child: Text("View Details"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
          ],
        ),
      ),
    );
  }
}
