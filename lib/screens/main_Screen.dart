import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web/models/greeting.dart';
import 'package:flutter_web/screens/ai_assistant.dart';
import 'package:flutter_web/screens/communityChat.dart';
import 'package:flutter_web/screens/fire_jobs.dart';
import 'package:flutter_web/screens/recent_jobs.dart';
import 'package:flutter_web/screens/userProfile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<String> _userId; // Initialize with an empty string

  @override
  void initState() {
    super.initState();
    _userId = fetchUserId(); // Fetch the userId when the screen initializes
  }

  Future<String> fetchUserId() async {
  try {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      // If there's no signed-in user, return null or handle it accordingly
      return '';
    }
  } catch (error) {
    // Handle any errors here
    print('Error fetching user ID: $error');
    return '';
  }
}

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.blue,
  ];
  final List _images = [
    "assets/chatfreely.jpg",
    "assets/chatfreely.jpg",
  ];

  int _currentIndex = 0;

  //final List<String> names = ["AI Assistant", "Recent Jobs", "User"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 205, 205, 205),
      body: FutureBuilder<String>(
        future: _userId,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, you can show a loading indicator
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle errors here
            return Text('Error: ${snapshot.error}');
          } else {
            final userId = snapshot.data ?? ''; // Get the userId or a default value

            final List<Widget> _screens = [
              UserDetailsScreen(userId: userId),
              ChatScreen(),
              FetchDataFromFirebase(),
              GChatScreen(userId: userId,),
              
            ];

            return IndexedStack(
              index: _currentIndex,
              children: _screens,
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
         // Set the background color
        selectedItemColor: Colors.deepPurple, // Set the selected item color
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc_rounded),
            label: 'Chat',
            ),
          
        ],
      ),
    );
  }
}
