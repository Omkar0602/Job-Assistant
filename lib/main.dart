import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_web/screens/ai_assistant.dart';
import 'package:flutter_web/screens/login.dart';
import 'package:flutter_web/screens/main_Screen.dart';
import 'package:flutter_web/screens/temp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lottie/lottie.dart';

Future main() async {
  
WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
      home:  MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splashScreen', // Set initial route to the login screen
      routes: {
        '/splashScreen' : (context) => SplashScreen(),
        '/login': (context) => LoginScreen(), // Define the login screen route
        '/home': (context) => HomeScreen(), // Define the home screen route
      },
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay to simulate a splash screen
    Timer(Duration(seconds: 5), () {
      // Navigate to the login screen after the delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
               
            Center(
              child: Lottie.asset(
                'assets/splashLottie.json', // Replace with your Lottie animation file
                width: 400,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              child: Text("Job Assistant",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}


