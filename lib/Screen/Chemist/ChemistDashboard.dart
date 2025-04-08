import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ysseparcha/Auth/LoginPage.dart'; // Import your login page

class ChemistDashboard extends StatefulWidget {
  const ChemistDashboard({super.key});

  @override
  State<ChemistDashboard> createState() => _ChemistDashboardState();
}

class _ChemistDashboardState extends State<ChemistDashboard> {
  final TextEditingController _couponController = TextEditingController();
  bool isLoading = false;
  bool isSubmitting = false;
  String error = '';
  Map<String, dynamic> patientData = {};
  User? _user; // Store the current authenticated user

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser; // Get the authenticated user
  }

  // Fetch patient data using coupon number
  Future<void> _fetchPatientData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final couponNumber = int.parse(_couponController.text);
      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc('$couponNumber') // Use coupon number as the document ID
          .get();

      if (patientDoc.exists) {
        setState(() {
          patientData = patientDoc.data()!;
        });
      } else {
        setState(() {
          error = 'Patient not found';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load patient data';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Logout function and navigate to login page
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error logging out. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Chemist Dashboard'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.orangeAccent,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                ),
                child: _user != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _user!.displayName ?? "Chemist", // Display name or "Chemist"
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _user!.email ?? "No Email",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                )
                    : Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              ListTile(
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              // Search field for coupon number
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    labelText: 'Enter Coupon Number',
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
                  keyboardType: TextInputType.number,
                ),
              ),

              // Search button
              ElevatedButton(
                onPressed: isSubmitting ? null : _fetchPatientData,
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
                  'Search Patient',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 20),

              // Display Patient Data if available
              if (patientData.isNotEmpty) ...[
                _buildDataRow('Name', patientData['name']),
                _buildDataRow('Age', patientData['age']),
                _buildDataRow('Mobile', patientData['mobile']),
                _buildDataRow('Address', patientData['address']),
                _buildDataRow('Coupon Number', patientData['couponNumber']),

                // Display treatments (array)
                SizedBox(height: 20),
                Text(
                  'Treatments:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 10),
                ...patientData['treatments'].map<Widget>((treatment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      treatment,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),

                // Display prescriptions (map)
                SizedBox(height: 20),
                Text(
                  'Prescriptions:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 10),
                ...patientData['prescriptions'].entries.map<Widget>((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Text(
                          entry.key + ': ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Display remarks (map)
                SizedBox(height: 20),
                Text(
                  'Remarks:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                SizedBox(height: 10),
                ...patientData['remarks'].entries.map<Widget>((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      children: [
                        Text(
                          entry.key + ': ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the data rows
  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
