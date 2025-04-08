import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late Future<Map<String, dynamic>> userData;

  @override
  void initState() {
    super.initState();
    userData = getUserDataFromFirestore();
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>> getUserDataFromFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      throw Exception("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange, // Orange color for the AppBar
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData) {
              return Center(child: Text("No user data found"));
            }

            var user = snapshot.data!;
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(user['name'] ?? 'N/A'),
                  accountEmail: Text(user['email'] ?? 'N/A'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.orange),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Name: ${user['name']}'),
                ),
                ListTile(
                  leading: Icon(Icons.cake),
                  title: Text('Age: ${user['age']}'),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email: ${user['email']}'),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Mobile: ${user['mobile']}'),
                ),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Role: ${user['role']}'),
                ),
              ],
            );
          },
        ),
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
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WaitingList()), // Navigate to Waiting List page
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
                  'Waiting List',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
