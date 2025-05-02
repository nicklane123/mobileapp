import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<bool> postToWordPress({
  required String title,
  required String content,
  File? imageFile,
  required String username,
  required String password,
}) async {
  const String baseUrl = 'http://10.0.2.2/wordpress';
  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));

  int? mediaId;

  try {
// Step 1: Upload image if it exists
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      final imageName = imageFile.path.split('/').last;
      final mediaResponse = await http.post(
        Uri.parse('$baseUrl/wp-json/wp/v2/media'),
        headers: {
          'Authorization': basicAuth,
          'Content-Disposition': 'attachment; filename="$imageName"',
          'Content-Type': 'image/jpeg',
        },
        body: imageBytes,
      );  if (mediaResponse.statusCode == 201) {
        final mediaJson = jsonDecode(mediaResponse.body);
        mediaId = mediaJson['id'];
      } else {
        print('Image upload failed: ${mediaResponse.body}');
        return false;
      }
    }

// Step 2: Post content
    final postResponse = await http.post(
      Uri.parse('$baseUrl/wp-json/wp/v2/posts'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'status': 'publish',
        if (mediaId != null) 'featured_media': mediaId,
      }),
    );

    if (postResponse.statusCode == 201) {
      print('Post created successfully.');
      return true;
    } else {
      print('Post failed: ${postResponse.body}');
      return false;
    }
  } catch (e) {
    print('Error posting to WordPress: $e');
    return false;
  }
}