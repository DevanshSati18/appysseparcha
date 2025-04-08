import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ysseparcha/Auth/LoginPage.dart';// Import your login page

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final TextEditingController _couponController = TextEditingController();
  TextEditingController _prescriptionController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  String? selectedTreatment;
  bool isLoading = false;
  bool isSubmitting = false;
  String error = '';
  Map<String, dynamic> patientData = {};
  final List<String> treatmentsList = [
    'Cardio',
    'OPD',
    'Ortho',
  ];

  User? _user; // For storing the current authenticated user

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

  // Save the updated remarks and prescription for the selected treatment
  Future<void> _saveData() async {
    if (selectedTreatment == null || _prescriptionController.text.isEmpty || _remarkController.text.isEmpty) {
      setState(() {
        error = 'Please select a treatment and enter the prescription and remarks';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final couponNumber = int.parse(_couponController.text);

      // Create/update the prescriptions and remarks for the selected treatment
      final updatedPrescriptions = Map<String, String>.from(patientData['prescriptions']);
      final updatedRemarks = Map<String, String>.from(patientData['remarks']);

      // Update the selected treatment
      updatedPrescriptions[selectedTreatment!] = _prescriptionController.text;
      updatedRemarks[selectedTreatment!] = _remarkController.text;

      await FirebaseFirestore.instance
          .collection('patients')
          .doc('$couponNumber')
          .update({
        'prescriptions': updatedPrescriptions,
        'remarks': updatedRemarks,
      });

      // Optionally add the treatment to the treatments array if not already there
      if (!patientData['treatments'].contains(selectedTreatment)) {
        patientData['treatments'].add(selectedTreatment!);
      }

      setState(() {
        patientData['prescriptions'] = updatedPrescriptions;
        patientData['remarks'] = updatedRemarks;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Data saved successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() {
        error = 'Failed to save data';
      });
    } finally {
      setState(() {
        isSubmitting = false;
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

  // This method will ensure the correct treatment's prescription and remarks are displayed
  void _updateControllersForSelectedTreatment() {
    if (selectedTreatment != null) {
      _prescriptionController.text = patientData['prescriptions'][selectedTreatment!] ?? '';
      _remarkController.text = patientData['remarks'][selectedTreatment!] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Doctor Dashboard'),
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
                      _user!.displayName ?? "Doctor", // Display name or "Doctor"
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

                // Dropdown to select treatment
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedTreatment,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTreatment = newValue;
                      _updateControllersForSelectedTreatment();  // Update controllers when treatment is selected
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Treatment',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
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
                  items: treatmentsList.map<DropdownMenuItem<String>>((String treatment) {
                    return DropdownMenuItem<String>(
                      value: treatment,
                      child: Text(
                        treatment,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),

                // Prescription input field
                TextField(
                  controller: _prescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Prescription for $selectedTreatment',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
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
                SizedBox(height: 10),

                // Remarks input field
                TextField(
                  controller: _remarkController,
                  decoration: InputDecoration(
                    labelText: 'Remarks for $selectedTreatment',
                    labelStyle: TextStyle(color: Colors.orangeAccent),
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
                SizedBox(height: 20),

                // Save button
                ElevatedButton(
                  onPressed: isSubmitting ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Data'),
                ),
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
