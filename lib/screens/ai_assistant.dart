import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web/screens/savedChat.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

late bool isLoading=false;
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _chatMessages = [];
  ScrollController _scrollController = ScrollController();

  void _addMessage(String message, bool isUser) {
  final newMessage = ChatMessage(
    text: message,
    isUser: isUser,
  );

  setState(() {
    _chatMessages.add(newMessage);
  });

  // Scroll to the end of the list after adding the new message
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  });
}

  void _sendMessage() async {
    String userMessage = _messageController.text;
    _messageController.clear();
    
    // Add the user's message to the chat
    _addMessage(userMessage, true);

    // Send the user's message to ChatGPT API
    String chatGptResponse = await _getChatGptResponse(userMessage);
         setState(() {
           isLoading=false;
         });
    // Add ChatGPT's response to the chat
    _addMessage(chatGptResponse, false);
  }

  Future<String> _getChatGptResponse(String userMessage) async {
    final apiKey = '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'; // Replace with your actual GPT-3.5 Turbo API key
  final endpoint = 'https://api.openai.com/v1/chat/completions';

  final response = await http.post(
    Uri.parse(endpoint),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo-16k-0613",
      "messages": [
        {"role": "system", "content": "you are an assistant"},
        {"role": "user", "content": userMessage},
      ],
      "temperature": 0,
        "max_tokens": 256,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
    }),
  );
print('Response Status Code: ${response.statusCode}');
print('Response Body: ${response.body}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final responseMessage = data['choices'][0]['message']['content'];
    return responseMessage;
  } else {
    throw Exception('Failed to fetch response');
  }
  }
 Future<void> saveChatToFirebase(String chatTitle) async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final chatMessages = _chatMessages.map((message) => message.text).toList();
      final firebaseResponse = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .add({
        'title': chatTitle,
        'messages': chatMessages,
      });

      if (firebaseResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chat saved to Firebase'),
          ),
        );

        // Clear the chat messages list
        setState(() {
          _chatMessages.clear();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not signed in'),
        ),
      );
    }
  } catch (error) {
    // Handle any errors here
    print('Error saving chat to Firebase: $error');
  }
}

Future<void> _showChatTitleDialog() async {
  String chatTitle = ''; // Initialize chatTitle as an empty string

  // Show a dialog for entering the chat title
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Chat Title'),
        content: TextField(
          onChanged: (value) {
            chatTitle = value;
          },
          decoration: InputDecoration(
            hintText: 'Chat Title',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              // Save the chat with the entered title
              saveChatToFirebase(chatTitle);

              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
       appBar: AppBar(
      title: Text(isLoading ? 'Typing' : 'Chat with AI',),
    actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
               _showChatTitleDialog(); // Call the function to save chat to Firebase
              },
            ),
          ],
       // Set the icon color to black
    ),
        body:  Column(
            children: <Widget>[
              
             _chatMessages.isEmpty? Expanded(
               child: SingleChildScrollView(
                 child: Container(
                  child: Center(
                    child:Column(children: [
                      LottieBuilder.asset('assets/animation_ChatBot.json'),
                      Text("AI Assistant",style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,),),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text("Note: Chats will not be saved so copy if someting is important"),
                      )
                      ]
                    ),
                  ),
                 ),
               ),
             ):Expanded(
                child: ListView.builder(
                  itemCount: _chatMessages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = _chatMessages[index];
                    return ChatBubble(
                      text: message.text,
                      isUser: message.isUser,
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask a Question',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
              maxLines: null, // Allows for an unlimited number of lines
              textInputAction: TextInputAction.newline, // Enables newline action button
              keyboardType: TextInputType.multiline,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: (){
                        isLoading=true;
                          setState(() {
                            _sendMessage();
                          });
                           
            
                      },
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

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatBubble({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
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
          text,
          style: TextStyle(fontSize: 16.0,color: isUser?Colors.white : Colors.black ),
        ),
      ),
    );
  }
}

