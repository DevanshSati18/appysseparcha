import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Screen/Usher/UsherDashboard.dart';
import 'Screen/Admin/AdminDashboard.dart';
import 'Screen/Doctor/DoctorDashboard.dart';
import 'Screen/Chemist/ChemistDashboard.dart';
import 'Auth/LoginPage.dart';

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Listening for auth state changes (user logged in or logged out)
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // If the user is logged out, navigate to the login screen
        _redirectToLoginPage();
      } else {
        // If the user is logged in, navigate based on role
        _navigateBasedOnRole(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ),
    );
  }

  // Function to redirect to the login page
  void _redirectToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Function to navigate based on user role
  void _navigateBasedOnRole(User user) async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userSnapshot.exists) {
        // Extract user role from Firestore
        String role = userSnapshot['role'];
        print("User role: $role");

        // Navigate based on role
        switch (role) {
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
            break;
          case 'doctor':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DoctorDashboard()),
            );
            break;
          case 'chemist':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChemistDashboard()),
            );
            break;
          case 'usher':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UsherDashboard()),
            );
            break;
          default:
          // If no role found, redirect to login
            _redirectToLoginPage();
            break;
        }
      } else {
        print("User data not found in Firestore. Logging out.");
        _auth.signOut();
        _redirectToLoginPage();
      }
    } catch (e) {
      print("Error fetching user role: $e");
      _auth.signOut();
      _redirectToLoginPage();
    }
  }
}
