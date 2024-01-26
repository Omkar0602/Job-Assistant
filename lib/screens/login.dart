import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _prefsKey = 'userLoggedIn'; // Key to store the login state

  Future<void> _updateUserData(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // If the user document doesn't exist, create it
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
        });
      }
    } catch (error) {
      print('Error updating user data: $error');
    }
  }

  Future<void> _handleSignIn() async {
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
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Update user data in Firestore
        await _updateUserData(user);

        // Store the login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefsKey, true);
        Navigator.of(context, rootNavigator: true).pop();
        // Navigate to the home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      print(error);
      // Handle sign-in failure
      // You can show an error message or try again.
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    setState(() {
    _loading = true; // Add a boolean variable _loading to track whether the indicator should be shown
  });
    final prefs = await SharedPreferences.getInstance();
    final userLoggedIn = prefs.getBool(_prefsKey);
setState(() {
    _loading = false; // Add a boolean variable _loading to track whether the indicator should be shown
  });
    if (userLoggedIn == true) {
      // User is already logged in, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Example'),
      ),
      body: Center(
        child: Column(
          children: [
            Lottie.asset('assets/animation_login.json'),
            ElevatedButton(
              onPressed: () async {
                await _handleSignIn();
              },
              child: Text('Sign in with Google'),
            ),
            if(_loading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class LogoutHelper {
  static Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userLoggedIn');
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (error) {
      print('Error during logout: $error');
    }
  }
}