import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _deptController = TextEditingController();
  String role = 'usher'; // Default role value

  bool isLoading = false;
  bool isSubmitting = false;
  String error = '';
  String successMessage = '';
  String userEmail = ''; // Store the email of the user to display

  // Fetch user data from Firestore based on email
  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
      error = '';
      successMessage = '';
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_emailController.text)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data()!;
        _nameController.text = data['name'] ?? '';
        _mobileNoController.text = data['mobileNo'] ?? '';
        _ageController.text = data['age'] ?? '';
        _addressController.text = data['address'] ?? '';
        _deptController.text = data['dept'] ?? '';
        role = data['role'] ?? 'usher'; // Set the user's role
        userEmail = _emailController.text; // Store the email for display
      } else {
        setState(() {
          error = 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load user data';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update user data
  Future<void> _updateUserData() async {
    setState(() {
      isSubmitting = true;
      error = '';
      successMessage = '';
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail) // Update based on the user's email
          .update({
        'name': _nameController.text,
        'mobileNo': _mobileNoController.text,
        'age': _ageController.text,
        'address': _addressController.text,
        'dept': _deptController.text,
        'role': role, // Update the user's role
      });

      setState(() {
        successMessage = 'User data updated successfully!';
      });
    } catch (e) {
      setState(() {
        error = 'Failed to update user data';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // Delete user
  Future<void> _deleteUser() async {
    setState(() {
      isSubmitting = true;
      error = '';
      successMessage = '';
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail) // Delete based on the user's email
          .delete();

      setState(() {
        successMessage = 'User deleted successfully!';
        _clearForm(); // Clear the form after deletion
      });
    } catch (e) {
      setState(() {
        error = 'Failed to delete user';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // Clear form fields
  void _clearForm() {
    _emailController.clear();
    _nameController.clear();
    _mobileNoController.clear();
    _ageController.clear();
    _addressController.clear();
    _deptController.clear();
    userEmail = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent, // Orange Accent color
        title: Text('User Management'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show success message
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

              // Show error message
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

              // Loading indicator while fetching user data
              if (isLoading)
                Center(child: CircularProgressIndicator()),

              // Search field for email
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter User Email',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    prefixIcon: Icon(Icons.search, color: Colors.orangeAccent),
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
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              // Search button
              ElevatedButton(
                onPressed: isSubmitting ? null : _fetchUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent, // Orange for search
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Search User',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 20),

              // Display User Data if available
              if (userEmail.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'User Email: $userEmail',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    _buildTextField(_nameController, 'Full Name', Icons.person),
                    _buildTextField(_mobileNoController, 'Mobile Number', Icons.phone),
                    _buildTextField(_ageController, 'Age', Icons.calendar_today, keyboardType: TextInputType.number),
                    _buildTextField(_addressController, 'Address', Icons.home),
                    _buildTextField(_deptController, 'Department', Icons.business),

                    // Role Dropdown
                    Padding(
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
                          labelStyle: TextStyle(color: Colors.orangeAccent),
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
                    ),

                    SizedBox(height: 20),

                    // Update button
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Update User',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Delete button
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _deleteUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Red for delete
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Delete User',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field for the form
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.orangeAccent),
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
}
