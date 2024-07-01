import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/methods/user_service.dart';

class UserProfile extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;

  const UserProfile({
    Key? key,
    required this.currentUserId,
    required this.targetUserId,
  }) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  DocumentSnapshot<Map<String, dynamic>>? userDoc;
  List<DocumentSnapshot<Map<String, dynamic>>>? userPosts;
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> fetchedUserDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.targetUserId)
              .get();

      QuerySnapshot<Map<String, dynamic>> fetchedUserPosts =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('uploadedBy', isEqualTo: widget.targetUserId)
              .get();

      setState(() {
        userDoc = fetchedUserDoc;
        userPosts = fetchedUserPosts.docs;
        isFollowing =
            userDoc!.data()?['followers']?.contains(widget.currentUserId) ??
                false;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (isFollowing) {
      await UserService()
          .unfollowUser(widget.currentUserId, widget.targetUserId);
    } else {
      await UserService().followUser(widget.currentUserId, widget.targetUserId);
    }

    setState(() {
      isFollowing = !isFollowing;
    });

    // Refresh user data to reflect the updated followers
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userDoc?.data()?['username'] ?? 'User Profile',
          style: const TextStyle(color: ColorConstants.textColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: ColorConstants.linearGradientColor4,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // User Profile Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      userDoc?.data()?['profilePictureUrl'] ?? '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userDoc?.data()?['username'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userDoc?.data()?['email'] ?? '',
                    style: const TextStyle(color: ColorConstants.textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userDoc?.data()?['mobileNumber'] ?? '',
                    style: const TextStyle(color: ColorConstants.textColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleFollow,
                    child: Text(
                      isFollowing ? 'Unfollow' : 'Follow',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // User Posts as Grid
            if (userPosts != null && userPosts!.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 15.0,
                      childAspectRatio:
                          0.86, // Adjust this value to make posts smaller or larger
                    ),
                    itemCount: userPosts!.length,
                    itemBuilder: (context, index) {
                      var post = userPosts![index].data();

                      if (post == null) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (post.containsKey('imageUrl') &&
                                post['imageUrl'] != null)
                              Image.network(
                                post['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                height: 120,
                              ),
                            if (!(post.containsKey('imageUrl') &&
                                post['imageUrl'] != null))
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  post['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (!(post.containsKey('imageUrl') &&
                                post['imageUrl'] != null))
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  post['description'] ?? 'No Description',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (userPosts == null || userPosts!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No posts available.',
                  style: TextStyle(color: ColorConstants.textColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
