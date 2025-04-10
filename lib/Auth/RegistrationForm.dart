import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'male';
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPhase = 1;

  final List<String> treatments = ['Ortho', 'Eye', 'Dental', 'OPD', 'Cardiology', 'ENT'];
  Map<String, bool> _selectedTreatments = {};

  @override
  void initState() {
    super.initState();
    for (String treatment in treatments) {
      _selectedTreatments[treatment] = false;
    }
  }

  Future<int> _getNextCouponNumber() async {
    int maxCoupon = 0;
    try {
      var querySnapshot = await FirebaseFirestore.instance.collection('patients').get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        if (data['couponNumber'] != null) {
          int current = data['couponNumber'];
          if (current > maxCoupon) maxCoupon = current;
        }
      }
    } catch (e) {
      print('Error fetching coupon number: $e');
    }
    return maxCoupon + 1;
  }

  void _register() async {
    if (_selectedTreatments.values.every((selected) => !selected)) {
      setState(() {
        _errorMessage = 'Please select at least one treatment.';
      });
      return;
    }

    final selectedTreatments = _selectedTreatments.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    int couponNumber = await _getNextCouponNumber();

    // Build remarks and prescriptions maps
    Map<String, String> remarksMap = {
      for (var treatment in selectedTreatments) treatment: 'NA'
    };
    Map<String, String> prescriptionsMap = {
      for (var treatment in selectedTreatments) treatment: 'NA'
    };

    // Create ISO string for registration time
    String registrationTime = DateTime.now().toIso8601String();

    Map<String, dynamic> patientData = {
      'name': _nameController.text.trim(),
      'age': _ageController.text.trim(),
      'address': _addressController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'gender': _gender,
      'treatments': selectedTreatments,
      'remarks': remarksMap,
      'prescriptions': prescriptionsMap,
      'registrationTime': registrationTime,
      'couponNumber': couponNumber,
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Use coupon number as the document ID
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(couponNumber.toString())
          .set(patientData);

      setState(() {
        _isLoading = false;
      });

      _resetForm();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registration Successful',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Patient data has been registered successfully.\nCoupon Number: $couponNumber',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  void _nextPhase() {
    if (_currentPhase == 1) {
      if (!_formKey.currentState!.validate()) return;
      setState(() {
        _currentPhase = 2;
        _errorMessage = '';
      });
    } else if (_currentPhase == 2) {
      _register();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _ageController.clear();
    _addressController.clear();
    _mobileController.clear();
    _gender = 'male';
    _currentPhase = 1;
    _selectedTreatments.updateAll((key, value) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          if (_currentPhase == 1)
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                    validator: (val) => val == null || val.isEmpty ? 'Enter age' : null,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    enabled: !_isLoading,
                    validator: (val) => val == null || val.isEmpty ? 'Enter address' : null,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter mobile number';
                      if (val.length != 10) return 'Mobile number must be 10 digits';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem(
                      value: gender.toLowerCase(),
                      child: Text(gender),
                    ))
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16,)
                ],
              ),
            ),
          if (_currentPhase == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Treatments (at least one)', style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                ...treatments.map(
                      (treatment) => CheckboxListTile(
                    title: Text(treatment),
                    value: _selectedTreatments[treatment] ?? false,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                      setState(() {
                        _selectedTreatments[treatment] = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _nextPhase,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.orange,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(_currentPhase == 1 ? 'Next' : 'Register'),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
