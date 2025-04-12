import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../database/db_helper.dart';
import 'create_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Message> allMessages = [];
  List<Message> messages = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void fetchMessages() async {
    final data = await dbHelper.getMessages();
    print("Fetched ${data.length} messages");
    setState(() {
      allMessages = data;
      messages = data;
    });
  }

  void deleteMessage(int id) async {
    await dbHelper.deleteMessage(id);
    fetchMessages();
  }

  void filterMessages(String query) {
    final filtered = allMessages.where((msg) {
      final titleLower = msg.title.toLowerCase();
      final contentLower = msg.content.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) || contentLower.contains(searchLower);
    }).toList();

    setState(() {
      messages = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Blog App")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterMessages,
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages found"))
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Card(
                  child: ListTile(
                    leading: msg.imagePath != null
                        ? Image.file(
                      File(msg.imagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.note),
                    title: Text(msg.title),
                    subtitle: Text(msg.content),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteMessage(msg.id!),
                    ),
                    onTap: () {
                      // Optional: Navigate to a view/edit screen
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMessageScreen()),
          );
          fetchMessages();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
