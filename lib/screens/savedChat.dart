import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedChatsScreen extends StatefulWidget {
  @override
  _SavedChatsScreenState createState() => _SavedChatsScreenState();
}

class _SavedChatsScreenState extends State<SavedChatsScreen> {
  List<String> savedChats = [];

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }
  

  Future<void> _loadSavedChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? chatMessagesJson = prefs.getStringList('chatMessages');

    if (chatMessagesJson != null) {
      setState(() {
        savedChats = chatMessagesJson;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Chats'),
      ),
      body: ListView.builder(
        itemCount: savedChats.length,
        itemBuilder: (BuildContext context, int index) {
          final savedChat = savedChats[index];
          return ListTile(
            title: Text(savedChat),
          );
        },
      ),
    );
  }
}
