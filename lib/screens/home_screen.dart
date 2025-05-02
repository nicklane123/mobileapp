import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/message.dart';
import '../database/db_helper.dart';
import 'create_message_screen.dart';
import 'view_edit_message_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DBHelper();
  List<Message> messages = [];
  List<Message> filteredMessages = [];
  Set<int> selectedMessageIds = {};
  bool isSelectionMode = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void fetchMessages() async {
    final data = await dbHelper.getMessages();
    setState(() {
      messages = data;
      filteredMessages = _applySearchFilter(data);
    });
  }

  List<Message> _applySearchFilter(List<Message> data) {
    return data.where((msg) {
      return msg.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          msg.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  void deleteMessage(int id) async {
    await dbHelper.deleteMessage(id);
    fetchMessages();
  }

  void deleteSelectedMessages() async {
    await dbHelper.deleteMultiple(selectedMessageIds.toList());
    setState(() {
      isSelectionMode = false;
      selectedMessageIds.clear();
    });
    fetchMessages();
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredMessages = _applySearchFilter(messages);
    });
  }

  void toggleSelectionMode(bool enable) {
    setState(() {
      isSelectionMode = enable;
      selectedMessageIds.clear();
    });
  }

  void toggleMessageSelection(int id) {
    setState(() {
      if (selectedMessageIds.contains(id)) {
        selectedMessageIds.remove(id);
      } else {
        selectedMessageIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? 'Select Messages' : 'My Blog App'),
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteSelectedMessages,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => toggleSelectionMode(false),
          ),
        ]
            : [],
      ),
      body: Column(
          children: [
      Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search Messages',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: updateSearch,
      ),
    ),
    Expanded(
    child: filteredMessages.isEmpty
    ? const Center(child: Text("No messages found"))
        : ListView.builder(
    itemCount: filteredMessages.length,
    itemBuilder: (context, index) {
    final msg = filteredMessages[index];
    final isSelected = selectedMessageIds.contains(msg.id);
    return Card(
      child: ListTile(
        leading: isSelectionMode
            ? Checkbox(
          value: isSelected,
          onChanged: (checked) =>
              toggleMessageSelection(msg.id!),
        )
            : (msg.imagePath != null
            ? Image.file(
          File(msg.imagePath!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        )
            : const Icon(Icons.note)),
        title: Text(msg.title),
        subtitle: Text(msg.content),
        trailing: isSelectionMode
            ? null
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                final textToShare = '${msg.title}\n\n${msg.content}';
                if (msg.imagePath != null && File(msg.imagePath!).existsSync()) {
                  final file = XFile(msg.imagePath!);
                  await Share.shareXFiles([file], text: textToShare);
                } else {
                  await Share.share(textToShare);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteMessage(msg.id!),
            ),
          ],
        ),
        onLongPress: () {
          if (!isSelectionMode) {
            toggleSelectionMode(true);
            toggleMessageSelection(msg.id!);
          }
        },
        onTap: () {
          if (isSelectionMode) {
            toggleMessageSelection(msg.id!);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ViewEditMessageScreen(message: msg),
              ),
            ).then((_) => fetchMessages());
          }
        },
      ),
    );
    },
    ),
    ),
          ],
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateMessageScreen()),
          );
          fetchMessages();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}