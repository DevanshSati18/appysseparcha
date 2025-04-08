import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientManagement extends StatefulWidget {
  const PatientManagement({super.key});

  @override
  State<PatientManagement> createState() => _PatientManagementState();
}

class _PatientManagementState extends State<PatientManagement> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  bool isLoading = false;
  bool isSubmitting = false;
  String error = '';
  Map<String, dynamic> patientData = {};

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

  // Add new treatment to the treatments array
  Future<void> _addTreatment() async {
    if (_treatmentController.text.isEmpty) {
      setState(() {
        error = 'Treatment cannot be empty';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final couponNumber = int.parse(_couponController.text);
      await FirebaseFirestore.instance
          .collection('patients')
          .doc('$couponNumber') // Use coupon number as the document ID
          .update({
        'treatments': FieldValue.arrayUnion([_treatmentController.text]), // Add new treatment
      });

      setState(() {
        patientData['treatments'].add(_treatmentController.text); // Update local state
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Treatment added successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() {
        error = 'Failed to add treatment';
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
        backgroundColor: Colors.orangeAccent,
        title: Text('Patient Management'),
        centerTitle: true,
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

                // Input field to add new treatment
                SizedBox(height: 20),
                TextField(
                  controller: _treatmentController,
                  decoration: InputDecoration(
                    labelText: 'Add Treatment',
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
                ElevatedButton(
                  onPressed: isSubmitting ? null : _addTreatment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Add Treatment'),
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
