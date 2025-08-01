import 'package:flutter/material.dart';
import 'package:home_rental/consts.dart';
import 'package:home_rental/dialogflow_service.dart';
import 'package:home_rental/providers/data_provider.dart';
import 'package:provider/provider.dart';


class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();

  void sendMessage(BuildContext context) async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    await DialogflowService.create(context).then((dialogflowService) {
      dialogflowService.sendMessage(userMessage, context);
    });

    _controller.clear();
  }

  @override
  void initState() {
    super.initState();
    initializeString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help"), backgroundColor: Colors.red.shade300),
      body: Column(
        children: [
          Expanded(
            child: Consumer<DataProvider>(
              builder: (context, provider, child) {
                List<Map<String, dynamic>> messages = provider.userMessages; // ✅ Fetch only logged-in user messages

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isUser = message["isUser"];

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(message["message"]!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about property renting/buying...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
