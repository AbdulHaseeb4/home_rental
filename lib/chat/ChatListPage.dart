import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_rental/chat/ChatScreen.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade300,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("allQueries")
            .where("sentBy", isEqualTo: currentUserId) // ✅ Fetch only renter's chats
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) return Center(child: Text("No Chats Found"));

          Set<String> uniqueLandlords = {};
          List<DocumentSnapshot> uniqueChats = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String landlordId = data['userId'] ?? "";

            if (uniqueLandlords.contains(landlordId)) {
              return false; // Skip duplicate landlords
            } else {
              uniqueLandlords.add(landlordId);
              return true;
            }
          }).toList();

          return ListView.builder(
            itemCount: uniqueChats.length,
            itemBuilder: (context, index) {
              var data = uniqueChats[index].data() as Map<String, dynamic>;
              String landlordId = data['userId'];
              String landlordName = data['landlordName'] ?? "Unknown";
              String landlordInitial = landlordName.isNotEmpty ? landlordName[0].toUpperCase() : "?";

              // ✅ Generate Chat ID
              List<String> sortedIds = [landlordId, currentUserId]..sort();
              String chatId = sortedIds.join("_");

              return FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection("chats")
                    .doc(chatId)
                    .collection("messages")
                    .orderBy("timestamp", descending: true)
                    .limit(1)
                    .get(),
                builder: (context, messageSnapshot) {
                  String lastMessage = "No messages yet";

                  if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                    var messageData = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                    lastMessage = messageData["message"] ?? "No messages yet";
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            renterId: currentUserId,
                            renterName: data['name'],
                            landlordId: landlordId,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade300,
                          child: Text(
                            landlordInitial,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          landlordName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: Icon(Icons.chat, color: Colors.red.shade300),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  renterId: currentUserId,
                                  renterName: data['name'],
                                  landlordId: landlordId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
