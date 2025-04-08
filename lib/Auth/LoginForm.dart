import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Manually import the dashboard pages
import 'package:ysseparcha/Screen/Admin/AdminDashboard.dart';
import 'package:ysseparcha/Screen/Doctor/DoctorDashboard.dart';
import 'package:ysseparcha/Screen/Chemist/ChemistDashboard.dart';
import 'package:ysseparcha/Screen/Usher/UsherDashboard.dart';


class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;

  Future<void> handleLogin() async {
    setState(() {
      errorMessage = null; // Reset error message
    });

    try {
      // Firebase authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Fetch user role from Firestore
        DocumentSnapshot userSnap = await _firestore.collection('users').doc(user.email).get();

        if (userSnap.exists) {
          String role = userSnap.get('role');

          // Navigate based on role
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else if (role == 'doctor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DoctorDashboard()),
            );
          } else if (role == 'chemist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChemistDashboard()),
            );
          } else if (role == 'usher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UsherDashboard()),
            );
          }
        } else {
          setState(() {
            errorMessage = 'User role not found.';
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid email or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        // Email input
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
        ),
        SizedBox(height: 12),
        // Password input
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20),
        // Login button
        ElevatedButton(
          onPressed: handleLogin,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50), // Full-width button
            backgroundColor: Colors.orange, // Button color (correct parameter)
          ),
          child: Text('Login'),
        ),
      ],
    );
  }
}
