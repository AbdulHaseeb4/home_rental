import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:home_rental/auth/log_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLoading = false;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user signup
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      // If validation fails, stop the signup process
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await FirebaseAuth.instance.currentUser!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent. Please verify.')),
        );

        await _storeUserData(userCredential.user!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogIn()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use. Try another.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'Signup failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to store additional user data in Firestore
  Future<void> _storeUserData(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    List<dynamic> fcmTokens = [];
    fcmTokens.add(token);
    await _firestore.collection('users').doc(userId).set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'dob': _dobController.text.trim(),
      'profilePic': '',
      'fcmToken': fcmTokens,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Function to show date picker for Date of Birth
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
      // Clear error if date is selected
      _clearError('dob');
    }
  }

  // Function to clear errors when a field is corrected
  void _clearError(String field) {
    final currentState = _formKey.currentState;
    if (currentState != null) {
      currentState.validate(); // Revalidate the form to clear errors
      setState(() {
        // Any additional UI updates or error-clearing logic can go here
      });
    }
  }

  // Function to validate name with max 3 words
  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return 'Name is required';
    }
    final nameParts = value.split(' ');
    if (nameParts.length > 3) {
      return 'Name can have only 3 words';
    }
    return null;
  }

  // Function to validate phone number (Pakistani number with country code)
  String? _validatePhone(String? value) {
    if (value!.isEmpty) {
      return 'Phone number is required';
    }
    // Check if phone number is 11 digits and starts with '+92' (Pakistan country code)
    if (!RegExp(r'^\+92\d{10}$').hasMatch(value)) {
      return 'Enter a valid Phone Number (+92)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade300,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign up to get started!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextFormField(
                    label: 'Full Name',
                    controller: _nameController,
                    validator: _validateName,
                    onChanged: (value) => _clearError('name'),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email is required';
                      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                          .hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                    onChanged: (value) => _clearError('email'),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    label: 'Password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      } else if (value.length < 8 ||
                          !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$')
                              .hasMatch(value)) {
                        return 'Password must contain letters, numbers, and special characters';
                      }
                      return null;
                    },
                    onChanged: (value) => _clearError('password'),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                    onChanged: (value) => _clearError('phone'),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    label: 'Location / Address',
                    controller: _addressController,
                    validator: (value) =>
                    value!.isEmpty ? 'Location/Address is required' : null,
                    onChanged: (value) => _clearError('address'),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextFormField(
                        label: 'Date of Birth',
                        controller: _dobController,
                        validator: (value) => value!.isEmpty ? 'Date of Birth is required' : null,
                        onChanged: (value) => _clearError('dob'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleSignUp,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade300,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LogIn()),
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

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}
