import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_rental/providers/data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'consts.dart';

class DialogflowService {
  final String sessionId;
  final String projectId;
  final AutoRefreshingAuthClient client;

  DialogflowService._(this.sessionId, this.projectId, this.client);
  final dataCollection = FirebaseFirestore.instance.collection("ChatData");

  // ✅ Step 1: Create DialogflowService with API Credentials
  static Future<DialogflowService> create(BuildContext context) async {
    // ✅ Show Loading Indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Please wait..."),
            ],
          ),
        );
      },
    );

    final sessionId = const Uuid().v4();
    const projectId = 'home-rental-95294'; // ✅ Replace with your Dialogflow project ID

    // ✅ Load the service account credentials
    final credentials = ServiceAccountCredentials.fromJson(json.decode(jsonString!));

    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    Navigator.pop(context); // ✅ Hide Loading Indicator
    return DialogflowService._(sessionId, projectId, client);
  }

  Future<void> sendMessage(String message, BuildContext context) async {
    final url = 'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent';
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "queryInput": {
        "text": {
          "text": message,
          "languageCode": "en"
        }
      }
    });

    var provider = Provider.of<DataProvider>(context, listen: false);

    if (provider.userId == null) return; // ✅ Use the getter instead of redefining userId

    // ✅ Store User Message in Firestore & DataProvider
    provider.addNewChatMessage(isUser: true, message: message);
    FirebaseFirestore.instance.collection("ChatData").doc(provider.userId).collection("messages").add({
      "isUser": true,
      "message": message,
      "timestamp": FieldValue.serverTimestamp()
    });

    final response = await client.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      String aiResponse = jsonResponse['queryResult']['fulfillmentText'] ?? "Sorry, I couldn't understand.";

      // ✅ Store AI Response in Firestore & DataProvider
      provider.addNewChatMessage(isUser: false, message: aiResponse);
      FirebaseFirestore.instance.collection("ChatData").doc(provider.userId).collection("messages").add({
        "isUser": false,
        "message": aiResponse,
        "timestamp": FieldValue.serverTimestamp()
      });
    } else {
      provider.addNewChatMessage(isUser: false, message: "Sorry, I couldn't understand.");
    }
  }

}
