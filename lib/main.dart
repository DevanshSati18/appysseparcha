import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Import for controlling orientation
import 'package:ysseparcha/Auth/LoginPage.dart';
import 'package:ysseparcha/AuthCheck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure the binding is initialized before Firebase
  await Firebase.initializeApp();  // Initialize Firebase

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Flutter Firebase App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: AuthCheck(),  // Set AuthCheck as the home widget to check authentication
    );
  }
}
