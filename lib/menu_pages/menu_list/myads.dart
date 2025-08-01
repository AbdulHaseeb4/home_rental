import 'package:flutter/material.dart';
import 'package:home_rental/menu_pages/buy_page.dart';
import 'package:home_rental/providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Myads extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Ads', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade300,
      ),
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          stream: Provider.of<DataProvider>(context, listen: false).getAllMyAds(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator()); // ✅ Loading state
            }

            // ✅ Filter Only Current User's Ads
            List<dynamic> myAds = snapshot.data!.where((property) {
              return property["userId"] == FirebaseAuth.instance.currentUser!.uid;
            }).toList();

            // ✅ If Current User Has No Ads, Show "No Ads"
            if (myAds.isEmpty) {
              return Center(child: Text("No Ads", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)));
            }

            return ListView.builder(
              itemCount: myAds.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                dynamic property = myAds[index];

                bool isForRent = property["collection"] == "Rentcommercial" ||
                    property["collection"] == "Rentresidential" ||
                    property["collection"] == "Shareroomrent";

                return PropertyCard(
                  data: property,
                  fromMyAds: true,
                  collectionName: property["collection"],
                  isForRent: isForRent,
                );
              },
            );
          },
        ),
      ),

    );
  }
}
