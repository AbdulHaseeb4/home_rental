import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_rental/chat/ChatScreen.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Queries', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade300,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fetchUserQueries(), // ✅ Fetching queries
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) return Center(child: Text("No Queries Found"));

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String senderName = data['name'] ?? 'Unknown'; // ✅ Sender Name
              String firstLetter = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U';
              String propertyName = data['propertyName'] ?? "No Title";

              return GestureDetector(
                onTap: () {
                  // ✅ Clicking anywhere opens chat screen
                  openChatScreen(data);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade300, // ✅ Avatar Color
                      child: Text(
                        firstLetter,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.home, color: Colors.red.shade300, size: 20), // ✅ Property Icon
                        SizedBox(width: 5), // ✅ Small spacing
                        Expanded(
                          child: Text(
                            propertyName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis, // ✅ Handle long names
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("💬 Message: ${data['message'] ?? 'No Message'}"),
                        Text("📩 Sender: $senderName"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.chat, color: Colors.red.shade300),
                      onPressed: () {
                        openChatScreen(data);
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void openChatScreen(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          renterId: data['sentBy'],  // ✅ Renter ID
          renterName: data['name'],  // ✅ Sender Name
          landlordId: data['userId'], // ✅ Landlord ID
        ),
      ),
    );
  }

  Stream<QuerySnapshot> fetchUserQueries() {
    String currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection("allQueries")
        .where("userId", isEqualTo: currentUserId)
        .snapshots();
  }
}
