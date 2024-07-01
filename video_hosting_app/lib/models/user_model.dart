import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  String profilePictureUrl;
  List<String> following;
  List<String> followers;

  User({
    required this.id,
    required this.username,
    required this.profilePictureUrl,
    required this.following,
    required this.followers,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    // Ensure doc.data() is not null and is a Map
    if (doc.data() == null || !(doc.data() is Map<String, dynamic>)) {
      throw StateError('Missing or invalid document data');
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      username: data['username'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      following: List<String>.from(data['following'] ?? []),
      followers: List<String>.from(data['followers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'following': following,
      'followers': followers,
    };
  }
}
