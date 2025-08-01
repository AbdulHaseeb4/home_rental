import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:home_rental/menu/homepage.dart'; // Import Home page
import 'package:home_rental/auth/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import SignUp page

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;  // Variable to track loading state
  bool _isPasswordVisible = false; // Variable to toggle password visibility

  String? _emailError;
  String? _passwordError;

  // Function to handle user login
  Future<void> _handleLogIn() async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validate email and password fields
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required.';  // Show error under email field if empty
      });
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address.';  // Show error if email is invalid
      });
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required.';  // Show error under password field if empty
      });
    } else if (password.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters long.';  // Show error if password is too short
      });
    }

    // If either field is empty or invalid, stop the login process
    if (email.isEmpty || password.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email) || password.length < 8) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      var document = await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).get();
      if(document.exists){
        Map<String, dynamic>? data = document.data();
        List<dynamic> tokens = data!["fcmToken"] ?? [];
        String? token = await FirebaseMessaging.instance.getToken();
        if (!tokens.contains(token)) {
          tokens.add(token);
          await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).update({
            "fcmToken" : tokens
          });
        }
      }

      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
        } else {
          _showError('Please verify your email first. Check your spam folder too.');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle different error codes and show appropriate messages
      if (e.code == 'user-not-found') {
        setState(() {
          _emailError = 'No user found with this email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _passwordError = 'Incorrect password. Please check and try again.';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          _emailError = 'The email address is badly formatted.';
        });
      } else {
        _showError('An error occurred: ${e.message}');
      }
    } catch (e) {
      _showError('An unexpected error occurred. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;  // Hide loading indicator after login attempt
      });
    }
  }

  // Function to show error message as Snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Function to handle password reset
  Future<void> _handleForgotPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address to reset your password.');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email has been sent.')),
      );
    } on FirebaseAuthException catch (e) {
      _showError('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Log in to continue!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      errorText: _emailError, // Show error if exists
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Real-time validation for email
                        if (value.isEmpty) {
                          _emailError = 'Email is required.';  // If empty, show required error
                        } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          _emailError = 'Please enter a valid email address.';
                        } else {
                          _emailError = null;  // Clear error if valid email
                        }
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Toggle visibility
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _passwordError, // Show error if exists
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Real-time validation for password
                        if (value.isEmpty) {
                          _passwordError = 'Password is required.';  // If empty, show required error
                        } else if (value.length < 8) {
                          _passwordError = 'Password must be at least 8 characters long.';
                        } else {
                          _passwordError = null;  // Clear error if valid password
                        }
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // Forgot Password link
                  GestureDetector(
                    onTap: _handleForgotPassword,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: _handleLogIn, // Trigger login function
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ) // Show loading indicator
                            : Text(
                          'Log In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Don’t have an account? ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade300,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUp()), // Navigate to SignUp page
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
