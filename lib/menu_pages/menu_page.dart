import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For base64Decode
import 'package:home_rental/auth/first_page.dart';
import 'package:home_rental/chat/ChatBotScreen.dart';
import 'package:home_rental/chat/ChatListPage.dart';
import 'package:home_rental/menu_pages/menu_list/favoritespage.dart';
import 'package:home_rental/menu_pages/menu_list/messages.dart';
import 'package:home_rental/menu_pages/menu_list/myads.dart';
import 'package:home_rental/menu_pages/menu_list/myprofilepage.dart';
import 'package:home_rental/menu_pages/alerts_page.dart';
import 'package:provider/provider.dart'; // ✅ Fix Consumer error
import 'package:home_rental/providers/data_provider.dart';
import 'package:home_rental/menu_pages/menu_list/schedulinglink.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: TextStyle(color: Colors.white,)),
        backgroundColor: Colors.red.shade300,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found'));
          }

          var userName = snapshot.data!['name'] ?? 'Default Name';
          var base64ProfilePic = snapshot.data!['profilePic'] ?? ''; // Fetch Base64 from Firestore

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(vertical: 20),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: base64ProfilePic.isNotEmpty
                            ? MemoryImage(base64Decode(base64ProfilePic)) // Decode Base64 to Image
                            : AssetImage('assets/profile/user.jpg') as ImageProvider,
                      ),
                      SizedBox(width: 15),
                      Expanded( // ✅ Wrap Text Column with Expanded
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis, // ✅ Truncate if too long
                            ),
                            SizedBox(height: 5),
                            Text(
                              user != null ? user.email ?? 'No email' : 'Not logged in',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              overflow: TextOverflow.ellipsis, // ✅ Truncate email if long
                              maxLines: 1, // ✅ Ensures it remains in one line
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(color: Colors.grey.shade300),

              _menuItem(Icons.person, 'My Profile', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfilePage()),
                );
              }),
              _menuItem(Icons.favorite, 'Favorites', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              }),
              _menuItem(Icons.list, 'My Ads', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Myads()),
                );
              }),
              _menuItem(Icons.assignment, 'All Queries', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessagesPage()),
                );
              }),

              _menuItem(Icons.wechat, 'Chats', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListPage()),
                );
              }),



              // _menuItem(Icons.schedule, 'Scheduling Link', context, onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => SchedulingLink()),
              //   );
              // }),


              // _menuItem(Icons.notifications_active, 'New Listing Alerts', context, onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => AlertsPage()),
              //   );
              // }),

              // ✅ Add Dark Mode Toggle Below Messages
              Consumer<DataProvider>(
                builder: (context, provider, child) {
                  return ListTile(
                    leading: Icon(Icons.dark_mode, color: Colors.red.shade300),
                    title: Text('Dark Mode'),
                    trailing: Builder( // ✅ Use Builder to correctly access context
                      builder: (context) {
                        return _buildCustomDarkModeSwitch(
                            context,
                            provider.themeMode == ThemeMode.dark,
                            provider.toggleTheme
                        );
                      },
                    ),
                  );
                },
              ),


              Divider(color: Colors.grey.shade300),

              _menuItem(Icons.exit_to_app, 'Log Out', context, isArrow: false, signOutAction: () {
                _signOut(context);
              }),

              Divider(color: Colors.grey.shade300),

              _menuItem(Icons.contact_support, 'Help', context, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotScreen()),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, BuildContext context, {Function()? signOutAction, bool isArrow = true, Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade300),
      title: Text(title),
      trailing: isArrow
          ? Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 12)
          : null,
      onTap: onTap ?? signOutAction,
    );
  }

  Widget _buildCustomDarkModeSwitch(BuildContext context, bool value, Function onChanged) {
    return GestureDetector(
      onTap: () {
        onChanged();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 22, // Compact height
        width: 40, // Compact width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? (Theme.of(context).brightness == Brightness.dark
              ? Colors.red.shade400  // 🔴 Dark Mode: Brighter red
              : Colors.red.shade300) // 🔴 Light Mode: Normal red
              : (Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade600  // 🌑 Dark Mode: Dark grey
              : Colors.grey.shade400), // 🌞 Light Mode: Normal grey
        ),
        child: Stack(
          children: [
            Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(3.0), // Compact padding
                child: Container(
                  height: 16, // Compact toggle button
                  width: 16, // Compact toggle button
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black // 🌑 Dark Mode: Black toggle button
                        : Colors.white, // 🌞 Light Mode: White toggle button
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => FirstPage()),
            (Route<dynamic> route) => false, // This removes all previous routes
      );
    } catch (e) {
      print('Sign-out error: $e');
    }
  }
}
