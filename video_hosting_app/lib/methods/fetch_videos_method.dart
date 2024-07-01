import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corp_tale/models/post_model.dart';

Future<List<Post>> fetchPosts() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('posts').get();
  return querySnapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
}
