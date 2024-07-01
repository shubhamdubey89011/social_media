import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/methods/user_service.dart';
import 'package:corp_tale/models/user_model.dart';
import 'package:corp_tale/pages/profile_pages/user_profile.dart'; // Make sure to import the UserProfile page

class UserListPage extends StatelessWidget {
  final String currentUserId;

  const UserListPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: ColorConstants.textColor),
        backgroundColor: ColorConstants.blue1,
        title: const Text(
          'Users',
          style: TextStyle(color: ColorConstants.textColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: ColorConstants.linearGradientColor6,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<DocumentSnapshot> docs = snapshot.data!.docs;
            List<User> users = docs
                .map((doc) => User.fromFirestore(doc))
                .where((user) => user.id != currentUserId)
                .toList();

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                User user = users[index];
                bool isFollowing = user.followers.contains(currentUserId);

                return ListTile(
                  title: Text(
                    user.username,
                    style: const TextStyle(color: ColorConstants.textColor),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      if (isFollowing) {
                        await UserService()
                            .unfollowUser(currentUserId, user.id);
                      } else {
                        await UserService().followUser(currentUserId, user.id);
                      }
                    },
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(
                          currentUserId: currentUserId,
                          targetUserId: user.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
