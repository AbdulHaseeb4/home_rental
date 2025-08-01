import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:home_rental/auth/log_in.dart';
import 'package:home_rental/auth/sign_up.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.25), // Adjust height dynamically
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/icon/rent.png', width: screenWidth * 0.15),
                ),
              ),
              Text(
                'Housoo',
                style: TextStyle(fontSize: screenWidth * 0.1, fontWeight: FontWeight.w900),
              ),
              Text(
                'Your Home Journey Begins Here.',
                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.w300),
              ),
              SizedBox(height: screenHeight * 0.2), // Adjust spacing dynamically
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text.rich(
                TextSpan(
                  text: 'Have an account? ',
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w300),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Log In',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade300,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
