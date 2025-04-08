import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController = TextEditingController();

  String role = 'usher';
  String error = '';
  String successMessage = '';
  bool isSubmitting = false;

  Future<void> handleSubmit() async {
    setState(() {
      error = '';
      successMessage = '';
    });

    // Validate fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _mobileNoController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        error = 'All fields are required.';
      });
      return;
    }

    // Check if the email already exists
    final userRef = FirebaseFirestore.instance.collection('users').doc(_emailController.text);
    final docSnap = await userRef.get();
    if (docSnap.exists) {
      setState(() {
        error = 'User with this email already exists.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Create user in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Create user data for Firestore
      Map<String, dynamic> userDetails = {
        'name': _nameController.text,
        'email': _emailController.text,
        'role': role,
        'mobileNo': _mobileNoController.text,
        'age': _ageController.text,
        'address': _addressController.text,
        'dept': (role == 'doctor' || role == 'usher') ? _deptController.text : '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add the user data to Firestore
      await userRef.set(userDetails);

      setState(() {
        successMessage = 'User created successfully!';
      });

      // Reset the form
      _nameController.clear();
      _emailController.clear();
      _mobileNoController.clear();
      _ageController.clear();
      _addressController.clear();
      _passwordController.clear();
      _deptController.clear();
      setState(() {
        role = 'usher';
      });

      // Optionally, navigate to another page (like admin dashboard) or show a success popup
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushNamed(context, '/admin-dashboard'); // Navigate after 2 seconds

    } catch (e) {
      setState(() {
        error = 'Error creating user: $e';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent, // Using Orange Accent
        title: Text('Add New User'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (successMessage.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    successMessage,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (error.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(_emailController, 'Email', Icons.email),
              _buildRoleDropdown(),
              if (role == 'doctor' || role == 'usher')
                _buildTextField(_deptController, 'Department', Icons.business),
              _buildTextField(_mobileNoController, 'Mobile Number', Icons.phone),
              _buildTextField(_ageController, 'Age', Icons.calendar_today, keyboardType: TextInputType.number),
              _buildTextField(_addressController, 'Address', Icons.home),
              _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent, // Updated button color to orange
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Create User',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.orangeAccent), // Using orange for labels
          prefixIcon: Icon(icon, color: Colors.orangeAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orangeAccent, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<String>(
        value: role,
        onChanged: (String? newValue) {
          setState(() {
            role = newValue!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Role',
          labelStyle: TextStyle(color: Colors.orangeAccent), // Orange label for dropdown
          prefixIcon: Icon(Icons.person, color: Colors.orangeAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orangeAccent, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
          ),
        ),
        items: ['usher', 'admin', 'chemist', 'doctor']
            .map((roleOption) => DropdownMenuItem<String>(
          value: roleOption,
          child: Text(roleOption),
        ))
            .toList(),
      ),
    );
  }
}
