import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsherDashboard extends StatefulWidget {
  const UsherDashboard({super.key});

  @override
  State<UsherDashboard> createState() => _UsherDashboardState();
}

class _UsherDashboardState extends State<UsherDashboard> {
  String? selectedDept;
  List<String> departments = ["Eye", "Dental", "Cardio", "OPD"]; // List of departments

  List<Map<String, dynamic>> patients = []; // List to hold patient data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Usher Dashboard"),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Usher Name"), // Replace with actual user name
              accountEmail: Text("usher@example.com"), // Replace with actual user email
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.orange),
              ),
            ),
            ListTile(
              title: Text("Logout"),
              onTap: () {
                // Handle logout functionality here
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select department
            DropdownButton<String>(
              value: selectedDept,
              hint: Text("Select Department"),
              onChanged: (newValue) async {
                setState(() {
                  selectedDept = newValue;
                });

                // Fetch patients from the selected department (fetch only 10)
                if (selectedDept != null) {
                  fetchPatientsFromDept(selectedDept!);
                }
              },
              items: departments.map<DropdownMenuItem<String>>((String dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Display patients in the selected department
            Expanded(
              child: patients.isEmpty
                  ? Center(child: Text("No patients in the queue"))
                  : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    child: ListTile(
                      title: Text(patients[index]["name"] ?? "Unknown Patient"),
                      subtitle: Text("Coupon No: ${patients[index]["couponNumber"]}"),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          removePatientFromQueue(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add new patient to queue
            ElevatedButton(
              onPressed: () {
                // Handle adding a new patient to the queue
                addPatientToQueue();
              },
              child: Text("Add Patient to Queue"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Background color of button
                foregroundColor: Colors.white, // Text color for the button
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to fetch patients from Firestore based on the selected department
  Future<void> fetchPatientsFromDept(String dept) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot snapshot = await firestore
          .collection("usher")
          .doc(dept)
          .collection("patients")
          .limit(10) // Limit to 10 patients at a time
          .get();

      List<Map<String, dynamic>> patientsData = snapshot.docs
          .map((doc) => {
        "name": doc["name"],
        "couponNumber": doc["couponNumber"],
      })
          .toList();

      setState(() {
        patients = patientsData;
      });
    } catch (e) {
      print("Error fetching patients: $e");
    }
  }

  // Function to add a patient to the queue (You can customize this based on your logic)
  void addPatientToQueue() {
    // Add logic to add a patient to the queue
    print("Add Patient to Queue");
    // Example: You can show a form to input the patient's coupon number, name, etc.
  }

  // Function to remove a patient from the queue
  void removePatientFromQueue(int index) {
    setState(() {
      patients.removeAt(index); // Remove the patient at the specified index
    });

    // You can also remove the patient from Firestore if required
    // FirebaseFirestore.instance.collection("usher").doc(selectedDept).collection("patients").doc(patientId).delete();
  }
}
