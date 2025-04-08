import 'package:flutter/material.dart';
import 'LoginForm.dart'; // Create this file for your login form
import 'RegistrationForm.dart'; // Create this file for your registration form

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true; // State to toggle between login and register

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the width with 5% padding on both sides
    double containerWidth = screenWidth * 0.9; // 90% of the screen width

    return Scaffold(
      body: SafeArea( // SafeArea to prevent overflow on screen edges
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_image.jpg'), // Background image
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: Center(
            child: SingleChildScrollView( // To ensure scrollability if content overflows
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, // White background with opacity
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4), // Shadow direction
                    ),
                  ],
                ),
                width: containerWidth, // Set the width to 90% of the screen width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo at the top
                    Image.asset(
                      'assets/ysslogo.png', // Add your logo image here
                      height: 100, // Adjust the height of the logo
                      width: 100, // Adjust the width if necessary
                    ),
                    SizedBox(height: 20), // Space between logo and toggle buttons

                    // Toggle buttons for Login and Register
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLogin = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLogin ? Colors.orange : Colors.grey[300], // Button color
                              foregroundColor: isLogin ? Colors.white : Colors.black, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                              ),
                            ),
                            child: Text('Login'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLogin = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !isLogin ? Colors.orange : Colors.grey[300], // Button color
                              foregroundColor: !isLogin ? Colors.white : Colors.black, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                              ),
                            ),
                            child: Text('Register'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Displaying the Login or Registration Form
                    if (isLogin)
                      LoginForm() // Replace with your login form widget
                    else
                      RegistrationForm(), // Replace with your registration form widget
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
