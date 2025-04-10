import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ysseparcha/Auth/LoginPage.dart';

// Import other pages
import 'AddUser.dart';
import 'UserManagement.dart';
import 'PatientManagement.dart';
import 'WaitingList.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange, // Orange color for the AppBar
        actions: [
          // Logout button (IconButton on the top right)
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center buttons vertically
          children: [
            // Button for Add User
            Container(
              width: double.infinity, // Ensure the button takes up full width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddUser()), // Navigate to Add User page
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button background color (orange)
                  foregroundColor: Colors.white, // Text color (white)
                  side: BorderSide(color: Colors.orange.shade800, width: 2), // Dark orange border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Box shape with rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16), // Add padding for height
                ),
                child: Text(
                  'Add User',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16), // Space between buttons
            // Button for User Management
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagement()), // Navigate to User Management page
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button background color (orange)
                  foregroundColor: Colors.white, // Text color (white)
                  side: BorderSide(color: Colors.orange.shade800, width: 2), // Dark orange border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Box shape with rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'User Management',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Button for Patient Management
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PatientManagement()), // Navigate to Patient Management page
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button background color (orange)
                  foregroundColor: Colors.white, // Text color (white)
                  side: BorderSide(color: Colors.orange.shade800, width: 2), // Dark orange border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Box shape with rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Patient Management',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Button for Waiting List
          ],
        ),
      ),
    );
  }
}
