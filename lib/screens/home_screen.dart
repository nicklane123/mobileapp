import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../database/db_helper.dart';
import 'create_message_screen.dart';
import 'view_edit_message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Message> messages = [];
  List<Message> filteredMessages = [];
  String searchQuery = '';
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // Fetch messages from the database
  void fetchMessages() async {
    final data = await dbHelper.getMessages();
    print("Fetched ${data.length} messages");
    setState(() {
      messages = data;
      filteredMessages = data;  // Initially, display all messages
    });
  }

  // Delete a message by ID
  void deleteMessage(int id) async {
    await dbHelper.deleteMessage(id);
    fetchMessages();  // Refresh the list after deleting
  }

  // Handle search filtering
  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredMessages = messages.where((msg) {
        return msg.title.toLowerCase().contains(query.toLowerCase()) ||
            msg.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Blog App")),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Messages',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: updateSearch,  // Update filtered messages on text change
            ),
          ),

          // List view to display messages
          Expanded(
            child: filteredMessages.isEmpty
                ? const Center(child: Text("No messages found"))
                : ListView.builder(
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final msg = filteredMessages[index];
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewEditMessageScreen(message: msg),
                        ),
                      );
                      fetchMessages(); // Refresh after editing
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
          fetchMessages();  // Refresh after adding a new message
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
