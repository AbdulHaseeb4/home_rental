import 'package:flutter/material.dart';
import 'package:home_rental/menu_pages/propertylisting/rent/rentresidential.dart';
import 'package:home_rental/menu_pages/propertylisting/rent/shareroomrent.dart';
import 'package:home_rental/menu_pages/propertylisting/rent/rentcommerical.dart'; // Import for Commercial Rent

class Rentlistingpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Ad', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade300,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Heading
            Text(
              "What are you listing for rent?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            // Subheading
            Text(
              "Select one from the options below",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),

            // Options Section
            Expanded(
              child: ListView(
                children: [
                  // Share Room Rent Option
                  _buildShareRoomRentOption(context),
                  // Residential Rent Option
                  _buildResidentialRentOption(context),
                  // Commercial Rent Option
                  _buildCommercialRentOption(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Share Room Rent Option
  Widget _buildShareRoomRentOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Share Room Rent Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Shareroomrent()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.room,  // Changed icon to room
              size: 30,
              color: Colors.red.shade300,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Share (Rent a Room)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Apartment, House",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Residential Rent Option
  Widget _buildResidentialRentOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Residential Rent Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Rentresidential()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home,  // Changed icon to home
              size: 30,
              color: Colors.red.shade300,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rent Residential",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Apartment, House, Holiday Home, Etc",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Commercial Rent Option
  Widget _buildCommercialRentOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Commercial Rent Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Rentcommerical()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.business_center,  // Changed icon to business_center
              size: 30,
              color: Colors.red.shade300,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Commercial (To Let)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Office Space, Serviced Office, Retail Units, Etc.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
