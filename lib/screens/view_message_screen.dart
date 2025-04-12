import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message.dart';

class ViewMessageScreen extends StatelessWidget {
  final Message message;

  const ViewMessageScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Message')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${message.createdAt}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (message.imagePath != null)
              Image.file(File(message.imagePath!), height: 200),
            const SizedBox(height: 16),
            Text(message.content, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
