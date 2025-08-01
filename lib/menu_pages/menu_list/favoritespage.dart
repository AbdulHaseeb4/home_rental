import 'package:flutter/material.dart';
import 'package:home_rental/menu_pages/buy_page.dart';
import 'package:home_rental/providers/data_provider.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade300,
      ),
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          stream: Provider.of<DataProvider>(context, listen: false).getFavouriteProperties(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No Favourite Property", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)));
            }

            List<dynamic> favoriteProperties = snapshot.data!;

            return ListView.builder(
              itemCount: favoriteProperties.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                dynamic property = favoriteProperties[index];

                // ✅ Identify property type based on collection name
                bool isForRent = property["collection"] == "Rentcommercial" ||
                    property["collection"] == "Rentresidential" ||
                    property["collection"] == "Shareroomrent";

                return PropertyCard(
                  data: property,
                  isForRent: isForRent, // ✅ Correctly identify rent properties
                );
              },
            );
          },
        ),
      ),
    );
  }
}
