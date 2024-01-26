import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web/screens/communityChat.dart';
import 'package:flutter_web/screens/previewImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:photo_view/photo_view.dart';
class PreviewImage extends StatefulWidget {
  final File imagePath;
  final String userId;
  const PreviewImage({super.key,required this.imagePath,required this.userId});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _name = '';
  late File _selectedImage;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedImage = widget.imagePath;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Review'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              
              child: PhotoView(
                imageProvider: FileImage(widget.imagePath),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          ),
          Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        
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
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
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

                    if (_messageController.text.isNotEmpty || _selectedImage != null) {
                      String imageUrl = '';

                      if (_selectedImage != null) {
                        imageUrl = await _uploadImage(_selectedImage!);
                      }

                      _firestore.collection('messages').add({
                        'text': _messageController.text,
                        'image': imageUrl,
                        'sender': _name,
                        'senderEmail': FirebaseAuth.instance.currentUser!.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                       Navigator.of(context, rootNavigator: true).pop();
                      _messageController.clear();
                       
                      
                    
                    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GChatScreen(userId: widget.userId)),
            );
                    
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );;
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

