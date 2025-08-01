import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String renterId;
  final String renterName;
  final String landlordId;

  ChatScreen({required this.renterId, required this.renterName, required this.landlordId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String chatId = "";
  String chatPartnerName = "User";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    generateChatId();
    fetchChatPartnerName();
    markMessagesAsRead();
  }

  // ✅ Generate Chat ID
  void generateChatId() {
    List<String> sortedIds = [widget.landlordId, widget.renterId]..sort();
    chatId = sortedIds.join("_");
  }

  // ✅ Fetch chat partner name
  void fetchChatPartnerName() async {
    String chatPartnerId =
    (_auth.currentUser!.uid == widget.renterId) ? widget.landlordId : widget.renterId;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(chatPartnerId).get();
    if (userDoc.exists) {
      setState(() {
        chatPartnerName = userDoc['name'] ?? "User";
        isLoading = false;
      });
    }
  }

  // ✅ Mark unread messages as read
  void markMessagesAsRead() async {
    QuerySnapshot unreadMessages = await _firestore
        .collection("chats")
        .doc(chatId)
        .collection("messages")
        .where("receiverId", isEqualTo: _auth.currentUser!.uid)
        .where("isRead", isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await doc.reference.update({"isRead": true});
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;
    String receiverId = (currentUserId == widget.renterId) ? widget.landlordId : widget.renterId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? "Loading..." : chatPartnerName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red.shade300,
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("chats")
                  .doc(chatId)
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet! Start the conversation."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = messageData["senderId"] == currentUserId;

                    // ✅ Ensure timestamp is valid
                    var timestamp = messageData["timestamp"] != null
                        ? (messageData["timestamp"] as Timestamp).toDate()
                        : DateTime.now();

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messageData["message"],
                              style: TextStyle(
                                fontSize: 16,
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${timestamp.hour}:${timestamp.minute}",
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                                SizedBox(width: 5),
                                if (isMe) // ✅ Show ticks only for sender
                                  Icon(
                                    messageData["isRead"] == true
                                        ? Icons.done_all // ✅ Seen message (double tick)
                                        : Icons.check, // ✅ Delivered message (single tick)
                                    size: 16,
                                    color: messageData["isRead"] == true
                                        ? Colors.red.shade300 // ✅ Seen (red tick)
                                        : Colors.white70, // ✅ Sent (grey tick)
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => sendMessage(chatId, currentUserId, receiverId),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Send message function
  void sendMessage(String chatId, String senderId, String receiverId) async {
    if (_messageController.text.trim().isEmpty) return;

    print("🔥 Sending message from: $senderId to: $receiverId");

    // ✅ Ensure chat exists in chat list
    await _firestore.collection("chats").doc(chatId).set({
      "participants": [widget.renterId, widget.landlordId],
      "lastMessage": _messageController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection("chats").doc(chatId).collection("messages").add({
      "senderId": senderId,
      "receiverId": receiverId,
      "message": _messageController.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
      "isRead": false, // ✅ Initially unread
    }).catchError((error) {
      print("🔥 Firestore Error: $error");
    });

    print("✅ Message Sent to: $receiverId");
    _messageController.clear();
  }
}
