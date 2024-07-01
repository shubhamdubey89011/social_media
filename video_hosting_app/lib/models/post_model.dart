import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final DateTime uploadedAt;
  final String? imageUrl;
  int likes;
  List<String> comments;
  final String type;
  final String uploadedBy;
  String username;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.uploadedAt,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.type,
    required this.uploadedBy,
    required this.username,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      comments: List<String>.from(data['comments'] ?? []),
      type: data['type'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      username: '', // Initialize username as empty string
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'uploadedBy': uploadedBy,
      'username': username,
      'title': title,
      'description': description,
      'type': type,
      'imageUrl': imageUrl,
      'likes': likes,
      'uploadedAt': uploadedAt,
    };
  }

  void updateLikes(int newLikes) {
    likes = newLikes;
  }
}
