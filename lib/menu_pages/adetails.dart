import 'dart:convert';
import 'package:home_rental/menu_pages/list_property_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_rental/menu_pages/sendenquirypage.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Adetails extends StatefulWidget {
  dynamic data;
  final bool isForRent;

  Adetails({super.key, required this.data, required this.isForRent});

  @override
  _AdetailsState createState() => _AdetailsState();
}

class _AdetailsState extends State<Adetails> {
  String userName = "Loading...";
  bool _showFullDescription = false; // ✅ Control description length

  @override
  void initState() {
    super.initState();
    fetchUserName(); // ✅ Fetch user name when the page loads
  }

  /// **🔹 Fetch User's Name from Firestore**
  Future<void> fetchUserName() async {
    try {
      String userId = widget.data["userId"];
      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc["name"];
          });
        } else {
          setState(() {
            userName = "Unknown";
          });
        }
      } else {
        setState(() {
          userName = "Unknown";
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error";
      });
      print("Error fetching user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
        backgroundColor: Colors.red.shade300,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// **🔹 Image Carousel**
                Container(
                  height: 250.0,
                  child: PageView.builder(
                    itemCount: widget.data["images"].length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: Image.memory(base64Decode(widget.data["images"][index])).image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// **🔹 Property Info**
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.data["propertyType"] ?? 'Property'} | ${widget.isForRent ? 'For Rent' : 'For Sale'} | ${widget.data["location"]}, Pakistan",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'PKR ',
                            style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            NumberFormat("#,##0", "en_US").format(
                              widget.data["price"] % 1 == 0  // ✅ Check if price has decimals
                                  ? widget.data["price"].toInt()  // 🔹 Convert to int if no decimal
                                  : widget.data["price"],  // 🔹 Keep as double if decimal exists
                            ),
                            style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(),

                      /// **🔹 Agent Info**
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade300,
                          child: Text(userName.substring(0, 1), style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(userName), // ✅ Display User Name
                        subtitle: Text(widget.data["sellerType"]),
                      ),
                      Divider(),


                      /// **🔹 Property Details**
                      _buildSectionTitle('Property Details'),
                      if (widget.data["selectedPreference"] != null)
                        _buildPropertyDetail("Preferred Tenants", widget.data["selectedPreference"].toString()),
                      if (widget.data["singleRooms"] != null)
                        _buildPropertyDetail("Single Room", widget.data["singleRooms"].toString()),
                      if (widget.data["doubleRooms"] != null)
                        _buildPropertyDetail("Double Rooms", widget.data["doubleRooms"].toString()),
                      if (widget.data["enSuiteRooms"] != null)
                        _buildPropertyDetail("enSuiteRooms", widget.data["enSuiteRooms"].toString()),
                      if (widget.data["bathrooms"] != null)
                        _buildPropertyDetail("Bathrooms", widget.data["bathrooms"].toString()),
                      if (widget.data["selectedTenants"] != null)
                        _buildPropertyDetail("Share Tenants", widget.data["selectedTenants"].toString()),
                      if (widget.data["tax"] != null)
                        _buildPropertyDetail("Tax", widget.data["tax"].toString()),
                      if (widget.data["lease"] != null)
                        _buildPropertyDetail("MIN-Lease", widget.data["lease"].toString()),
                      if (widget.data["startDate"] != null)
                        _buildPropertyDetail("Lease Start-Date", widget.data["startDate"].toString()),
                      if (widget.data["propertySize"] != null)
                        _buildPropertyDetail("Property-Size", widget.data["propertySize"].toString()),
                      if (widget.data["sellerType"] != null)
                        _buildPropertyDetail("Seller Type", widget.data["sellerType"].toString()),

                      Divider(),

                      /// **🔹 Amenities**
                      _buildSectionTitle('Amenities'),
                      _buildAmenity("Owner Occupied", widget.data["ownerOccupied"] ?? false),
                      _buildAmenity("+1 Person Allowed", widget.data["isPlusOneAllowed"] ?? false),
                      _buildAmenity("Cable", widget.data["cable"]),
                      _buildAmenity("Electricity", widget.data["elecricity"]),
                      _buildAmenity("Gas", widget.data["gas"]),
                      _buildAmenity("Water Supply", widget.data["watersupply"]),
                      _buildAmenity("Wifi", widget.data["wifi"]),
                      _buildAmenity("Great Location", widget.data["greatlocation"]),


                      Divider(),

                      /// **🔹 Description (Show More / Less)**
                      _buildSectionTitle('Description'),
                      Text(
                        widget.data["description"].length > 100
                            ? _showFullDescription
                            ? widget.data["description"]
                            : '${widget.data["description"].substring(0, 100)}...'
                            : widget.data["description"],
                        style: TextStyle(fontSize: 16),
                      ),
                      widget.data["description"].length > 100
                          ? Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _showFullDescription = !_showFullDescription;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _showFullDescription ? 'Show Less' : 'Show More',
                                style: TextStyle(color: Colors.red.shade300),
                              ),
                              Icon(
                                _showFullDescription ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.red.shade300,
                              ),
                            ],
                          ),
                        ),
                      )
                          : SizedBox(),

                      Divider(),

                      /// **🔹 Location with Pakistan Map (Left-Aligned)**
                      _buildSectionTitle('Location'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,  // ✅ Align content to the left
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8), // ✅ Rounded Corners
                            child: Image.asset(
                              'assets/map/map1.png',  // ✅ Pakistan Map Image
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${widget.data["location"]}, Pakistan',
                            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium!.color),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      Divider(),

                      /// **🔹 New Ad Section Below Location**
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red.shade50, // Light pink at the top
                              Colors.red.shade100, // Slightly darker pink at the bottom
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// ✅ Heading
                            Text(
                              "Looking to LIST YOUR ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              "PROPERTY?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),

                            /// ✅ Pink Line
                            Divider(color: Colors.red.shade400, thickness: 2, indent: 110, endIndent: 110),
                            SizedBox(height: 8),

                            /// ✅ Home Rentals Text
                            Text(
                              "Home Rentals",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade300,
                              ),
                            ),
                            SizedBox(height: 4),

                            /// ✅ Adjusted Text with Line Break
                            Text(
                              "Get your ad up and",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold,),
                            ),
                            Text(
                              "running today!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold,),
                            ),
                            SizedBox(height: 16),

                            /// ✅ Post Your Ad Button
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ListPropertyPage(), // ✅ Send property data
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade300,
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "Post Your Ad",
                                style: TextStyle(fontSize: 15, color: Colors.white),
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
          ),

          /// **🔹 Send Enquiry Button**
          widget.data["userId"] != FirebaseAuth.instance.currentUser!.uid ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SendEnquiryPage(data: widget.data, isForRent: widget.isForRent,)));
                },
                child: Text('Send Enquiry', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ) : SizedBox(),
        ],
      ),
    );
  }

  /// **🔹 Helper Widgets**
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPropertyDetail(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAmenity(String label, bool isAvailable) {
    return isAvailable
        ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    )
        : SizedBox();
  }
}
