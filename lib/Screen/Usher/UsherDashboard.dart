import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ysseparcha/Auth/LoginPage.dart';

class UsherDashboard extends StatefulWidget {
  const UsherDashboard({super.key});

  @override
  State<UsherDashboard> createState() => _UsherDashboardState();
}

class _UsherDashboardState extends State<UsherDashboard> {
  String? selectedDept; // Selected department from the dropdown
  List<String> departments = []; // List to store department names dynamically
  List<Map<String, dynamic>> queue = []; // List to hold patient data (queue)
  List<Map<String, dynamic>> missing = []; // List to hold missing patient data
  int selectedListIndex = 0; // 0 for queue, 1 for missing
  TextEditingController couponController = TextEditingController(); // Controller to add coupon number
  DocumentSnapshot? lastFetchedDoc; // Keep track of the last fetched document for pagination
  bool isLoading = false; // Loading state
  String successMessage = ''; // Success message after adding a patient

  @override
  void initState() {
    super.initState();
    fetchDepartments(); // Fetch departments when the widget is initialized
  }

  // Function to fetch the list of departments from Firestore
  Future<void> fetchDepartments() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch documents from the "waiting" collection to get the department names
      QuerySnapshot deptSnapshot = await firestore.collection("waiting").get();

      List<String> deptList = [];
      for (var doc in deptSnapshot.docs) {
        deptList.add(doc.id); // Add document IDs as department names
      }

      setState(() {
        departments = deptList; // Update the list of departments
        if (departments.isNotEmpty) {
          selectedDept = departments[0]; // Default to the first department in the list
          fetchPatientsFromDept(selectedDept!); // Fetch patients for the default department
        }
      });
    } catch (e) {
      print("Error fetching departments: $e");
    }
  }

  // Function to fetch patients from Firestore based on the selected department
  Future<void> fetchPatientsFromDept(String dept, {bool loadMore = false}) async {
    setState(() {
      isLoading = true; // Show loading spinner while fetching data
    });

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String deptPath = dept.trim().toLowerCase(); // Normalize to lowercase for query consistency

      DocumentSnapshot deptDoc = await firestore.collection("waiting").doc(deptPath).get();

      if (deptDoc.exists) {
        var queueList = List.from(deptDoc['list'] ?? []);
        var missingList = List.from(deptDoc['missing'] ?? []);

        List<Map<String, dynamic>> patientsData = [];
        for (var coupon in queueList.take(10)) {
          var patientDoc = await firestore.collection('patients').doc(coupon).get();
          if (patientDoc.exists) {
            patientsData.add({
              "couponNumber": coupon,
              "name": patientDoc["name"],
            });
          }
        }

        List<Map<String, dynamic>> missingData = [];
        for (var coupon in missingList) {
          var patientDoc = await firestore.collection('patients').doc(coupon).get();
          if (patientDoc.exists) {
            missingData.add({
              "couponNumber": coupon,
              "name": patientDoc["name"],
            });
          }
        }

        setState(() {
          queue = patientsData;
          missing = missingData;
        });

        // If it's a 'Load More' request, track the last fetched document
        if (loadMore && patientsData.isNotEmpty) {
          lastFetchedDoc = (await firestore.collection('patients')
              .where('couponNumber', isEqualTo: queueList.last)
              .limit(1)
              .get())
              .docs
              .last;
        }
      }
    } catch (e) {
      print("Error fetching patients: $e");
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner after data is fetched
      });
    }
  }

  // Function to add a patient to the queue
  void addPatientToQueue() async {
    String coupon = couponController.text.trim();
    if (coupon.isNotEmpty) {
      setState(() {
        isLoading = true; // Show loading spinner while adding data
      });

      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Add the coupon to the queue
        await firestore.collection('waiting').doc(selectedDept!.toLowerCase()).update({
          'list': FieldValue.arrayUnion([coupon]),
        });

        setState(() {
          couponController.clear(); // Clear the input field
          successMessage = "Coupon $coupon added successfully to the queue!";
        });

        // Reload patients after adding the new one
        fetchPatientsFromDept(selectedDept!);
      } catch (e) {
        print("Error adding patient to the queue: $e");
      } finally {
        setState(() {
          isLoading = false; // Hide loading spinner after the data is added
        });
      }
    }
  }

  // Function to remove a patient from the queue
  void removePatientFromQueue(int index) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String coupon = queue[index]["couponNumber"];

      // Remove from the queue
      await firestore.collection('waiting').doc(selectedDept!.toLowerCase()).update({
        'list': FieldValue.arrayRemove([coupon]),
      });

      setState(() {
        queue.removeAt(index);
      });
    } catch (e) {
      print("Error removing patient from queue: $e");
    }
  }

  // Function to move patient to the missing list
  void sendToMissing(int index) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String coupon = queue[index]["couponNumber"];

      // Move patient to missing list
      await firestore.collection('waiting').doc(selectedDept!.toLowerCase()).update({
        'missing': FieldValue.arrayUnion([coupon]),
        'list': FieldValue.arrayRemove([coupon]),
      });

      setState(() {
        missing.add(queue[index]);
        queue.removeAt(index);
      });
    } catch (e) {
      print("Error sending patient to missing list: $e");
    }
  }

  // Function to remove a patient from the missing list
  void removeFromMissingList(int index) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String coupon = missing[index]["couponNumber"];

      // Remove from the missing list
      await firestore.collection('waiting').doc(selectedDept!.toLowerCase()).update({
        'missing': FieldValue.arrayRemove([coupon]),
      });

      setState(() {
        missing.removeAt(index);
      });
    } catch (e) {
      print("Error removing patient from missing list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Usher Dashboard"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Department selection dropdown
            departments.isEmpty
                ? Center(child: CircularProgressIndicator()) // Show loading spinner if departments are still loading
                : DropdownButton<String>(
              value: selectedDept,
              hint: Text("Select Department"),
              onChanged: (newValue) async {
                setState(() {
                  selectedDept = newValue;
                  lastFetchedDoc = null; // Reset pagination when switching departments
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

            // Toggle between queue and missing lists
            ToggleButtons(
              isSelected: [selectedListIndex == 0, selectedListIndex == 1],
              onPressed: (index) {
                setState(() {
                  selectedListIndex = index;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Queue"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Missing"),
                ),
              ],
              color: Colors.black,
              selectedColor: Colors.white,
              fillColor: Colors.orange,
              borderColor: Colors.orange,
              borderRadius: BorderRadius.circular(8.0),
              selectedBorderColor: Colors.orange,
            ),

            SizedBox(height: 20),

            // Add new patient to queue
            TextField(
              controller: couponController,
              decoration: InputDecoration(
                labelText: "Enter Coupon Number",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              keyboardType: TextInputType.number, // Only allow numbers
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : () => addPatientToQueue(),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Add Patient to Queue"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            if (successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  successMessage,
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),

            SizedBox(height: 20),

            // Display patients in the selected list (queue or missing)
            Expanded(
              child: selectedListIndex == 0
                  ? queue.isEmpty
                  ? Center(child: Text("No patients in the queue"))
                  : ListView.builder(
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    child: ListTile(
                      title: Text(queue[index]["name"] ?? "Unknown Patient"),
                      subtitle: Text("Coupon No: ${queue[index]["couponNumber"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () {
                              removePatientFromQueue(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              sendToMissing(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : missing.isEmpty
                  ? Center(child: Text("No patients are missing"))
                  : ListView.builder(
                itemCount: missing.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    child: ListTile(
                      title: Text(missing[index]["name"] ?? "Unknown Patient"),
                      subtitle: Text("Coupon No: ${missing[index]["couponNumber"]}"),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          removeFromMissingList(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Load More Button
            if (lastFetchedDoc != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    fetchPatientsFromDept(selectedDept!, loadMore: true);
                  },
                  child: Text("Load More"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
