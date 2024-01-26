import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web/screens/previewImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GChatScreen extends StatefulWidget {
  final String userId;
  GChatScreen({required this.userId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<GChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _name = '';
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Placement Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs;
                messages.sort((a, b) {
                  Timestamp? aTimestamp = a['timestamp'];
                  Timestamp? bTimestamp = b['timestamp'];

                  if (aTimestamp == null || bTimestamp == null) {
                    return 0;
                  }

                  return bTimestamp.seconds.compareTo(aTimestamp.seconds);
                });

                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message['text'];
                  var messageSender = message['sender'];
                  var messageSenderEmail = message['senderEmail'];
                  var messageImage = message['image'];
                  var timestamp = message['timestamp'];


                  var messageWidget = MessageWidget(
                    sender: messageSender,
                    text: messageText,
                    senderEmail: messageSenderEmail,
                    imageUrl: messageImage,
                    timestamp: timestamp,
                  );
                  messageWidgets.add(messageWidget);
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messageWidgets.length,
                  itemBuilder: (context, index) {
                    return messageWidgets[index];
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
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _selectImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Enter your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    try {
                      final DocumentSnapshot userSnapshot =
                          await _firestore.collection('users').doc(widget.userId).get();

                      if (userSnapshot.exists) {
                        final userData = userSnapshot.data() as Map<String, dynamic>;
                        final String name = userData['name'];
                        final String email = userData['email'];

                        setState(() {
                          _name = name;
                        });
                      }
                    } catch (error) {
                      print('Error fetching user data: $error');
                    }

                    if (_messageController.text.isNotEmpty) {
                      String imageUrl = '';

                      if (_selectedImage != null) {
                       // imageUrl = await _uploadImage(_selectedImage!);
                      }

                      _firestore.collection('messages').add({
                        'text': _messageController.text,
                        'image': imageUrl,
                        'sender': _name,
                        'senderEmail': FirebaseAuth.instance.currentUser!.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      _messageController.clear();
                      setState(() {
                        _selectedImage = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
       Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PreviewImage(imagePath: _selectedImage!,userId: widget.userId,)),
            );
      });
      

       
    }
    
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = path.basename(imageFile.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;
  final String senderEmail;
  final String imageUrl;
  final dynamic timestamp;

  MessageWidget({
    required this.sender,
    required this.text,
    required this.senderEmail,
    required this.imageUrl,
    required this.timestamp,
  });

  String _formatTimestamp() {
     if (timestamp == null) {
      return '';
    }
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.jm().format(dateTime); // Adjust the format as needed
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = FirebaseAuth.instance.currentUser!.email == senderEmail;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.grey[300],
              borderRadius: isCurrentUser
                  ? BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: isCurrentUser ? Colors.white : Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          
                if (imageUrl.isNotEmpty)
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(imageUrl: imageUrl),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 200, // Adjust the width as needed
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      if (imageUrl.isNotEmpty) SizedBox(height: 4),
                    ],
                  ),
                if (imageUrl.isNotEmpty) SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTimestamp(), // Display the formatted timestamp
                  style: TextStyle(
                    
                    fontSize: 10,
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
