import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:home_rental/providers/data_provider.dart';
import 'package:provider/provider.dart';


class SendEnquiryPage extends StatefulWidget {
  dynamic data;
  final bool isForRent;


  SendEnquiryPage({super.key, required this.data, required this.isForRent});
  @override
  _SendEnquiryPageState createState() => _SendEnquiryPageState();
}

class _SendEnquiryPageState extends State<SendEnquiryPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool sending = false;


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        final userData = snapshot.data();
        setState(() {
          _nameController.text = userData?['name'] ?? 'Unknown';
          _emailController.text = userData?['email'] ?? 'No Email';
          _phoneController.text = userData?['phone'] ?? 'No Phone';
        });
      } else {
        print("User data not found.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    int totalRooms = (widget.data["singleRooms"] ?? 0) +
        (widget.data["doubleRooms"] ?? 0) +
        (widget.data["enSuiteRooms"] ?? 0);
    return Scaffold(
      backgroundColor: Colors.white, // PAGE BACKGROUND IS WHITE
      appBar: AppBar(
        title: Text('Send Enquiry', style: TextStyle(color: Colors.white,)),
        backgroundColor: Colors.red.shade300,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),

              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Broker Info (Including Prime Partner Logo)
                    Row(
                      children: [
                        // Container(
                        //   height: 40,  // Same as the previous placeholder image
                        //   width: 40,   // Make it square
                        //   decoration: BoxDecoration(
                        //     color: Colors.black,  // Background color
                        //     borderRadius: BorderRadius.circular(8),  // Slightly rounded corners (similar to the placeholder image)
                        //   ),
                        //   alignment: Alignment.center, // Center the text inside the box
                        //   child: Text(
                        //     (widget.data["sellerType"] != null && widget.data["sellerType"].isNotEmpty)
                        //         ? widget.data["sellerType"][0].toUpperCase()  // ✅ First letter of sellerType
                        //         : "?",
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 18,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        Container(
                          height: 40,  // Keep square shape
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,  // Background color
                            borderRadius: BorderRadius.circular(8),  // Rounded corners like an image
                          ),
                          alignment: Alignment.center, // Center the text
                          child: Text(
                            ('Abdul Haseeb'.isNotEmpty)
                                ? 'Abdul Haseeb'[0].toUpperCase()  // ✅ First letter of the displayed name
                                : "?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Abdul Haseeb',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.data["sellerType"],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Property Image and Details
                    Row(
                      children: [
                        // Second image (Actual Property Image)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (widget.data["images"] != null &&
                              widget.data["images"] is List &&
                              widget.data["images"].length > 1 &&
                              widget.data["images"][1] != null &&
                              widget.data["images"][1] != "")
                              ? Image.memory(
                            base64Decode(widget.data["images"][1]),  // ✅ Decode and Show Property Image
                            height: 60,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 60,
                                width: 80,
                                color: Colors.grey,
                                child: Icon(Icons.image, color: Colors.white),
                              );
                            },
                          )
                              : Container(
                            height: 60,
                            width: 80,
                            color: Colors.grey,
                            child: Icon(Icons.image, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                 "${widget.data["propertyType"] ?? 'Property'} | ${widget.isForRent ? 'For Rent' : 'For Sale'} | ${widget.data["location"]}, Pakistan",
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                              ),

                              SizedBox(height: 4),

                              Text(
                                '🛏 $totalRooms Rooms Available  |  🛁 ${widget.data["bathrooms"] ?? 0} Bathrooms  |  📏 ${widget.data["propertySize"] ?? "N/A"}',
                                style: TextStyle(color: Colors.grey,fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'PKR ',  // PKR text
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black, // Black color for PKR
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: NumberFormat("#,##0", "en_US").format(
                                        widget.data["price"] % 1 == 0
                                            ? widget.data["price"].toInt()
                                            : widget.data["price"],
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.blueAccent, // Blue color for price
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Full Name (Non-Editable)
            Text('Full name', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _nameController,
              readOnly: true,
              enabled: false,
              style: TextStyle(color: Colors.black54),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Email (Non-Editable)
            Text('Your email', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _emailController,
              readOnly: true,
              enabled: false,
              style: TextStyle(color: Colors.black54),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Phone Number (Now Fetched & Non-Editable)
            Text('Your phone number', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              readOnly: true, // Non-editable
              enabled: false, // Disabled input
              style: TextStyle(color: Colors.black54),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Message Field (Increased Height)
            Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            TextField(
              controller: _messageController,
              maxLines: 8, // INCREASED HEIGHT
              decoration: InputDecoration(
                hintText: 'Enter your message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Send Enquiry Button with WHITE TEXT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if(_messageController.text.isNotEmpty){
                    setState(() {
                      sending = true;
                    });
                    var p = Provider.of<DataProvider>(context,listen: false);
                    await p.saveQueryData(
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                        propertyName: widget.data["propertyType"],
                        propertyPrice: widget.data["price"].toString(),
                        userID: widget.data["userId"],
                        message: _messageController.text);
                    await p.sendNotification(widget.data["userFcmToken"], _nameController.text);
                    setState(() {
                      sending = false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Enquiry Sent Successfully!'),
                    ));
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Enter Something!'),
                    ));
                  }
                },
                child: sending ? CircularProgressIndicator() : Text(
                  'Send Enquiry',
                  style: TextStyle(color: Colors.white), // BUTTON TEXT COLOR IS WHITE
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300, // Button Background Red
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
