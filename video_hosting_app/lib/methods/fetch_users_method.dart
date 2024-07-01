import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corp_tale/models/user_model.dart';

Future<List<User>> fetchUsers() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();
  return querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
}
