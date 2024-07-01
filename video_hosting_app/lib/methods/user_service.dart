import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> followUser(String currentUserId, String targetUserId) async {
    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);
    DocumentReference targetUserRef =
        _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserRef);
      DocumentSnapshot targetUserSnapshot =
          await transaction.get(targetUserRef);

      if (!currentUserSnapshot.exists || !targetUserSnapshot.exists) {
        throw Exception('User not found');
      }

      // Update following and followers lists
      List<String> currentUserFollowing = List<String>.from(
          (currentUserSnapshot.data() as Map<String, dynamic>)['following'] ??
              []);
      List<String> targetUserFollowers = List<String>.from(
          (targetUserSnapshot.data() as Map<String, dynamic>)['followers'] ??
              []);

      if (!currentUserFollowing.contains(targetUserId)) {
        currentUserFollowing.add(targetUserId);
        targetUserFollowers.add(currentUserId);

        transaction.update(currentUserRef, {'following': currentUserFollowing});
        transaction.update(targetUserRef, {'followers': targetUserFollowers});
      }
    });
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);
    DocumentReference targetUserRef =
        _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserRef);
      DocumentSnapshot targetUserSnapshot =
          await transaction.get(targetUserRef);

      if (!currentUserSnapshot.exists || !targetUserSnapshot.exists) {
        throw Exception('User not found');
      }

      // Update following and followers lists
      List<String> currentUserFollowing = List<String>.from(
          (currentUserSnapshot.data() as Map<String, dynamic>)['following'] ??
              []);
      List<String> targetUserFollowers = List<String>.from(
          (targetUserSnapshot.data() as Map<String, dynamic>)['followers'] ??
              []);

      if (currentUserFollowing.contains(targetUserId)) {
        currentUserFollowing.remove(targetUserId);
        targetUserFollowers.remove(currentUserId);

        transaction.update(currentUserRef, {'following': currentUserFollowing});
        transaction.update(targetUserRef, {'followers': targetUserFollowers});
      }
    });
  }
}
