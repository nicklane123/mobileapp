import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<void> postToWordPress({
  required String title,
  required String content,
  File? imageFile,
  required String username,
  required String password,
}) async {
  int? mediaId;

// Upload image if provided
  if (imageFile != null) {
    final uploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost/wordpress/wp-json/wp/v2/media'),
    )
      ..headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    final imageResponse = await uploadRequest.send();
    final responseData = await http.Response.fromStream(imageResponse);

    if (responseData.statusCode == 201) {
      final imageJson = jsonDecode(responseData.body);
      mediaId = imageJson['id'];
    } else {
      print('❌ Image upload failed: ${responseData.body}');
      return;
    }
  }

// Post content to WordPress
  final postResponse = await http.post(
    Uri.parse('http://localhost/wordpress/wp-json/wp/v2/posts'),
    headers: {
      'Authorization':
      'Basic ${base64Encode(utf8.encode('$username:$password'))}',
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
    print('✅ Post uploaded to WordPress.');
  } else {
    print('❌ Failed to post: ${postResponse.body}');
  }
}