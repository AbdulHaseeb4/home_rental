import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:home_rental/menu_pages/adetails.dart';
import 'package:home_rental/menu_pages/sendenquirypage.dart';
import 'package:home_rental/providers/data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> with AutomaticKeepAliveClientMixin {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredProperties = [];
  String selectedFilter = 'All'; // Default filter
  String noResultsMessage = "";
  int totalAds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTotalAds();
    });
    _searchController.addListener(() {
      final provider = Provider.of<DataProvider>(context, listen: false);
      filterProperties(_searchController.text, provider);
    });
  }

  Future<void> fetchTotalAds() async {
    try {
      int ads = await Provider.of<DataProvider>(context, listen: false).getTotalAdsCount1();

      if (!mounted) return; // ✅ Ensure widget is still in the tree

      setState(() {
        totalAds = ads;
      });
    } catch (e) {
      print("Error fetching total ads: $e");
    }
  }


  void filterProperties(String query, DataProvider provider) {
    setState(() {
      List<dynamic> allProperties = [];

      // ✅ Select properties based on filter type
      if (selectedFilter == 'Residential') {
        allProperties = provider.propertyList2; // ✅ Buy Residential
      } else if (selectedFilter == 'Commercial') {
        allProperties = provider.propertyList; // ✅ Buy Commercial
      } else {
        allProperties = provider.propertyList + provider.propertyList2; // ✅ All Properties
      }

      // ✅ Apply search filter
      if (query.isEmpty) {
        filteredProperties = allProperties; // Show all if search is empty
        noResultsMessage = "";
      } else {
        filteredProperties = allProperties.where((property) {
          String location = (property["location"] ?? "").toLowerCase();
          return location.contains(query.toLowerCase());
        }).toList();

        // ✅ If no properties match the search query
        if (filteredProperties.isEmpty) {
          noResultsMessage = "No properties found in the searched location.";
        } else {
          noResultsMessage = "";
        }
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buy Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade300,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by City Name | Pakistan.',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    label: 'All',
                    icon: Icons.filter_list,
                    isSelected: selectedFilter == 'All',
                    onTap: () => setState(() {
                      selectedFilter = 'All';
                      filterProperties(_searchController.text, Provider.of<DataProvider>(context, listen: false));
                    }),
                  ),
                  FilterButton(
                    label: 'Residential',
                    icon: Icons.home,
                    isSelected: selectedFilter == 'Residential',
                    onTap: () => setState(() {
                      selectedFilter = 'Residential';
                      filterProperties(_searchController.text, Provider.of<DataProvider>(context, listen: false));
                    }),
                  ),
                  FilterButton(
                    label: 'Commercial',
                    icon: Icons.business,
                    isSelected: selectedFilter == 'Commercial',
                    onTap: () => setState(() {
                      selectedFilter = 'Commercial';
                      filterProperties(_searchController.text, Provider.of<DataProvider>(context, listen: false));
                    }),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalAds ads',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Row(
                  children: [
                    Text(
                      'All Listings',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(width: 4), // Space between text and icon
                    Icon(Icons.grid_view, color: Colors.red.shade300, size: 14),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey),


          // ✅ Display Properties Based on Search & Filters
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, provider, child) {
                return StreamBuilder<List<dynamic>>(
                  stream: selectedFilter == 'Residential'
                      ? provider.getProperties2()
                      : selectedFilter == 'Commercial'
                      ? provider.getProperties()
                      : combineStreams(provider),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // ✅ Get properties from snapshot
                    List<dynamic> displayedProperties = snapshot.data ?? [];

                    // ✅ Apply search filter if search is active
                    if (_searchController.text.isNotEmpty) {
                      displayedProperties = filteredProperties;
                    }

                    // ✅ Show "No properties found" if nothing matches
                    if (displayedProperties.isEmpty) {
                      return Center(
                        child: Text(
                          noResultsMessage.isNotEmpty ? noResultsMessage : "No properties available for sale at the moment.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: displayedProperties.length,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return PropertyCard(data: displayedProperties[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<dynamic>> combineStreams(DataProvider provider) async* {
    List<dynamic> allProperties = [];
    Stream<List<dynamic>> commercialStream = provider.getProperties();
    Stream<List<dynamic>> residentialStream = provider.getProperties2();

    await for (var commercial in commercialStream) {
      allProperties = commercial;
      var residential = await residentialStream.first;
      allProperties.addAll(residential);
      yield allProperties;
    }
  }
}



// ✅ Filter Button Widget
class FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? Colors.red.shade300 : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.red.shade300 : Colors.grey,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.red.shade300 : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Property Card Widget
class PropertyCard extends StatefulWidget {
  final bool isForRent;
  dynamic data;
  bool? fromMyAds;
  String? collectionName;

  PropertyCard({super.key, required this.data,this.isForRent = false, this.fromMyAds,this.collectionName});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  String userName = "Loading...";
  Future<void> fetchUserName() async {
    try {
      String userId = widget.data["userId"];
      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          if (mounted) { // ✅ Check if the widget is still in the tree
            setState(() {
              userName = userDoc["name"];
            });
          }
        } else {
          if (mounted) { // ✅ Check before updating state
            setState(() {
              userName = "Unknown";
            });
          }
        }
      } else {
        if (mounted) { // ✅ Avoid calling setState() after dispose
          setState(() {
            userName = "Unknown";
          });
        }
      }
    } catch (e) {
      if (mounted) { // ✅ Prevent calling setState() if disposed
        setState(() {
          userName = "Error";
        });
      }
      print("Error fetching user name: $e");
    }
  }

  Future<void> _deleteDocument(BuildContext context, String collectionName, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: $e')),
      );
    }
  }

  // Function to show confirmation dialog
  void _showDeleteConfirmation(BuildContext context, String collectionName, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this document?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                Navigator.of(dialogContext).pop(); // Close dialog
                _deleteDocument(context,collectionName,docId); // Delete document
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    fetchUserName(); // ✅ Fetch user name when widget loads
  }
  Widget build(BuildContext context) {
    // Calculate total rooms dynamically
    int totalRooms = (widget.data["singleRooms"] ?? 0) +
        (widget.data["doubleRooms"] ?? 0) +
        (widget.data["enSuiteRooms"] ?? 0);
    return GestureDetector(
      onTap: () {
        // Navigate to Adetails page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Adetails(data: widget.data, isForRent: widget.isForRent,), // No parameters required
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade300,
                    child: Text(userName.substring(0, 1), style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName, // ✅ Ye Firebase se fetched user name show karega
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text(
                        widget.data["sellerType"],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Image Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade300,
                            image: DecorationImage(image: Image.memory(base64Decode(widget.data["images"][0])).image,
                                fit: BoxFit.cover) // Placeholder for large image
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.data["isVerified"] == true ? Colors.green.shade400 : Colors.red.shade400, // ✅ Green for Verified, Red for Not Verified
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified, size: 16, color: Colors.white), // ✅ Verified Icon
                              SizedBox(width: 5),
                              Text(
                                widget.data["isVerified"] == true ? "Verified" : "Not Verified",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        left: 10,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Adetails(data: widget.data, isForRent: widget.isForRent,), // ✅ Send property data
                              ),
                            );
                          },
                          icon: Icon(Icons.collections, size: 16, color: Colors.white),
                          label: Text(
                            'View All Photos',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.1),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            minimumSize: Size(0, 33),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Consumer<DataProvider>(builder: (BuildContext context, value, Widget? child) {
                        return Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () {
                              if(!value.userFavourite.contains(widget.data["docId"])){
                                value.addToFavourite(widget.data["docId"]);
                              }else{
                                value.removeFromFavourite(widget.data["docId"]);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.3),
                              radius: 20,
                              child: Icon(value.userFavourite.contains(widget.data["docId"]) ? Icons.favorite   : Icons.favorite_border, color: value.userFavourite.contains(widget.data["docId"]) ? Colors.red : Colors.white),
                            ),
                          ),
                        );
                      },)
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade300,
                              image: DecorationImage(image: Image.memory(base64Decode(widget.data["images"][1]),
                                fit: BoxFit.cover,).image,
                              ),
                            ),
                          )),
                      SizedBox(width: 8),
                      Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade300,
                              image: DecorationImage(image: Image.memory(base64Decode(widget.data["images"][2]),
                                fit: BoxFit.cover,).image,
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.data["propertyType"] ?? 'Property'} | ${widget.isForRent ? 'For Rent' : 'For Sale'} | ${widget.data["location"]}, Pakistan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  SizedBox(height: widget.data["propertySize"] == null ? 0 : 4),
                  widget.data["propertySize"] == null ? SizedBox() :
                  Text(
                    '🛏 $totalRooms Rooms Available  |  🛁 ${widget.data["bathrooms"] ?? 0} Bathrooms  |  📏 ${widget.data["propertySize"] ?? "N/A"}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'PKR ', // ✅ PKR Text ko separate rakhein
                        style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium!.color, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        NumberFormat("#,##0", "en_US").format(
                          widget.data["price"] % 1 == 0
                              ? widget.data["price"].toInt()
                              : widget.data["price"],
                        ),
                        style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  FirebaseAuth.instance.currentUser != null ? widget.data["userId"] != FirebaseAuth.instance.currentUser!.uid ?  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendEnquiryPage(data: widget.data, isForRent: widget.isForRent,),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red.shade300,
                      ),
                      child: Center(
                        child: Text(
                          "Send Enquiry",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ) : widget.fromMyAds != null ? GestureDetector(
                    onTap: () => _showDeleteConfirmation(context, widget.collectionName!, widget.data["docId"]),
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red.shade300,
                      ),
                      child: Center(
                        child: Text(
                          "Delete",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ) : SizedBox() : SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
