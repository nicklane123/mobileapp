class Message {
  int? id;
  String title;
  String content;
  String? imagePath;
  String createdAt;

  Message({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePath: map['imagePath'],
      createdAt: map['createdAt'],
    );
  }
}
