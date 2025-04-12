import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/message.dart';
import '../database/db_helper.dart';

class ViewEditMessageScreen extends StatefulWidget {
  final Message message;

  const ViewEditMessageScreen({Key? key, required this.message}) : super(key: key);

  @override
  State<ViewEditMessageScreen> createState() => _ViewEditMessageScreenState();
}

class _ViewEditMessageScreenState extends State<ViewEditMessageScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.message.title);
    _contentController = TextEditingController(text: widget.message.content);
    if (widget.message.imagePath != null) {
      _image = File(widget.message.imagePath!);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(picked.path);
      final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');

      setState(() {
        _image = savedImage;
      });
    }
  }

  void saveChanges() async {
    final updatedMessage = Message(
      id: widget.message.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      imagePath: _image?.path,
      createdAt: widget.message.createdAt,
    );

    await DBHelper().updateMessage(updatedMessage);
    Navigator.pop(context); // return to HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View/Edit Message")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 150)
                : const Text("No image selected"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                  onPressed: () => pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () => pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              onPressed: saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
