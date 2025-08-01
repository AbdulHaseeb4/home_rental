import 'package:flutter/material.dart';
import 'package:home_rental/menu_pages/propertylisting/rentlistingpage.dart';
import 'package:home_rental/menu_pages/propertylisting/salelistingpage.dart';

class ListPropertyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Listing', style: TextStyle(color: Colors.white)),
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
              "What are you listing?",
              style: TextStyle(
                fontSize: 22,
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
                  // Property for Rent Option
                  _buildOption(
                    context,
                    title: "Property for Rent",
                    subtitle: "Share (Rent a room), Rent Residential, Commercial (To Let)",
                    icon: Icons.house,
                    onTap: () {
                      // Navigate to Rent Listing Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Rentlistingpage()),
                      );
                    },
                  ),
                  // Property for Sale Option
                  _buildOption(
                    context,
                    title: "Property FOR SALE",
                    subtitle: "Residential, Commercial",
                    icon: Icons.shopping_cart,
                    onTap: () {
                      // Navigate to Sale Listing Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Salelistingpage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Widget for Options
  Widget _buildOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
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
              icon,
              size: 30,
              color: Colors.red.shade300,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
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



