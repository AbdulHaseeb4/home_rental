import 'dart:convert'; // For Base64 encoding
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  File? _imageFile;
  bool _isUploading = false;
  bool _isChanged = false;  // Flag to track changes
  String? _imageUrl;
  String buttonText = 'Choose Photo';
  String? _joinedDate;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  // Function to format date properly:
  String _formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);  // Convert string to DateTime
    return DateFormat('d MMMM, yyyy').format(parsedDate);  // Example: 21 February, 2025
  }

  Future<void> _submitDeleteRequest() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final email = FirebaseAuth.instance.currentUser?.email;

      if (userId == null || email == null) return;

      await FirebaseFirestore.instance.collection('delete_requests').doc(userId).set({
        'email': email,
        'requestTime': FieldValue.serverTimestamp(),
        'status': 'Pending', // Admin review karega
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your delete request has been submitted. Admin will review it within 24 hours.')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit delete request: $e')),
      );
    }
  }


  Future<void> _fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        userData = snapshot.data();
        _nameController.text = userData?['name'] ?? '';
        _phoneController.text = userData?['phone'] ?? '';
        _emailController.text = userData?['email'] ?? '';
        _imageUrl = userData?["profilePic"] ?? '';  // Load Base64 from Firestore

        // Fetching 'createdAt' field from user data
        _joinedDate = userData?['createdAt'] != null
            ? userData!['createdAt'].toDate().toString()
            : 'No Date Available';

        setState(() {});
      } else {
        print("User data not found.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  // Function to save changes
  Future<void> _saveChanges() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() {
        _isChanged = false;  // Reset the change flag after saving
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
    }
  }

  // Function to check if the field value has changed
  void _checkForChanges() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _isChanged = _nameController.text.trim() != userData?['name'] ||
          _phoneController.text.trim() != userData?['phone'];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int fileSize = await imageFile.length();  // Get image file size in bytes

      // 1MB = 1,048,576 bytes
      if (fileSize > 1048576) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image size exceeds 1MB. Please select a smaller image.')),
        );
        return;  // Stop further processing
      }

      setState(() {
        _imageFile = imageFile;
        buttonText = 'Upload Photo';
      });
    }
  }


  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
      buttonText = 'Uploading...';
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Convert image file to Base64 string
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Save Base64 string in Firestore
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "profilePic": base64Image,  // Save Base64 in Firestore
      });

      setState(() {
        _imageUrl = base64Image;  // Update UI with new image
        _isUploading = false;
        _imageFile = null;  // Reset the file after uploading
        buttonText = 'Choose Photo';  // Reset button text
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
        buttonText = 'Upload Photo';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }



  ImageProvider _getImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_imageUrl!));  // Convert Base64 back to image
      } catch (e) {
        print("Error decoding Base64: $e");
        return AssetImage('assets/profile/user.jpg');
      }
    } else {
      return AssetImage('assets/profile/user.jpg');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade300,
        title: Text('My Profile', style: TextStyle(color: Colors.white)),
      ),
      body: userData == null
          ? SizedBox(width: double.infinity, height: double.infinity,
          child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
            child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _getImage(),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.red.shade300, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : (_imageFile == null ? _pickImage : _uploadImage),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isUploading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    else
                      Icon(_imageFile == null ? Icons.image : Icons.upload, color: Colors.white,size: 18,),  // Set icon color to white
                    SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: TextStyle(color: Colors.white,),  // Set the text color to white
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 6),
                ),
              ),
              SizedBox(height: 16),
              Divider(thickness: 1.5),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (_) => _checkForChanges(),  // Check for changes
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: FirebaseAuth.instance.currentUser?.emailVerified == true  // Check from Firebase Auth
                      ? Icon(Icons.task_alt, color: Colors.red.shade300,size: 18,)  // Show a green checkmark if verified
                      : null,  // If not verified, no icon is displayed
                ),
                readOnly: true,
                enabled: false,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _checkForChanges(),  // Check for changes
              ),
              SizedBox(height: 16),
              // Save Changes Button
              if (_isChanged)  // Only show if there are changes
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.red.shade300),  // Set the text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              SizedBox(height: 16),
              // Divider Line
              if (_isChanged)
                Divider(thickness: 1.5),
              SizedBox(height: 16),

              // Display Joined Date
              if (_joinedDate != null)
                Text(
                  'Join Date:',
                  style: TextStyle(fontSize: 16,  color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
              SizedBox(height: 8),
              if (_joinedDate != null)
                Text(
                  _formatDate(_joinedDate!),  // Call function to format date
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),

              // Divider under Joined Date
              Divider(thickness: 1.5),
              SizedBox(height: 16),
              // Delete Account Text aligned left
              Align(
                alignment: Alignment.centerLeft,  // This will align it to the left
                child: Padding(
                  padding: EdgeInsets.zero,  // No padding here
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,  // Align the text to the start
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId == null) return;

                          final docRef = FirebaseFirestore.instance.collection('delete_requests').doc(userId);
                          final docSnapshot = await docRef.get();

                          if (docSnapshot.exists) {
                            final requestTime = docSnapshot.data()?['requestTime'] as Timestamp?;
                            final email = docSnapshot.data()?['email'] as String? ?? "Unknown Email";

                            if (requestTime != null) {
                              final elapsedTime = DateTime.now().difference(requestTime.toDate());

                              if (elapsedTime.inHours < 24) {
                                int remainingHours = 23 - elapsedTime.inHours;
                                int remainingMinutes = 59 - elapsedTime.inMinutes % 60;
                                int remainingSeconds = 59 - elapsedTime.inSeconds % 60;

                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Request Pending"),
                                      content: Text(
                                        "Your previous delete request is already submitted with email: $email.\n\n"
                                            "You can submit a new request in $remainingHours hours, $remainingMinutes minutes, and $remainingSeconds seconds.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                            }
                          }

                          // Show confirmation dialog if no pending request
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm Delete"),
                                content: Text("Are you sure you want to delete your account permanently?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            _submitDeleteRequest();
                          }
                        },
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),

                      SizedBox(height: 2),  // Add some space between the texts
                      Text(
                        'Permanently delete my account and all my ads from Home Rentals.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
                    ),
                  ),
          ),
    );
  }
}
