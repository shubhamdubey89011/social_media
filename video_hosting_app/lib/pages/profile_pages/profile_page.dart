import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:corp_tale/auth_pages/auth_controllers.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/pages/profile_pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String username = "Loading...";
  String userImageUrl = "";
  List<DocumentSnapshot<Map<String, dynamic>>> userPosts = [];
  bool isLoading = true;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      QuerySnapshot<Map<String, dynamic>> userPostsSnapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('uploadedBy', isEqualTo: user.uid)
              .get();
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          username = data['username'] ?? 'No Username';
          userImageUrl = data['profilePictureUrl']?.isNotEmpty == true
              ? data['profilePictureUrl']
              : '';
          userPosts = userPostsSnapshot.docs;
          isLoading = false;
        });
      }
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    ).then((_) {
      // Refresh profile data after returning from EditProfilePage
      _loadUserProfile();
    });
  }

  void _refreshProfile() {
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: ColorConstants.linearGradientColor5,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Make the scaffold background transparent
        appBar: AppBar(
          iconTheme: const IconThemeData(color: ColorConstants.textColor),
          backgroundColor: ColorConstants.blue1,
          title: const Text(
            'Profile',
            style: TextStyle(color: ColorConstants.textColor),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined,
                  color: ColorConstants.textColor),
              onPressed: () async {
                Navigator.pop(context);
                await authController.logout(context);
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: userImageUrl.isNotEmpty
                                ? NetworkImage(userImageUrl)
                                : const AssetImage(
                                        'assets/images/default_user.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.textColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _editProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.blue1,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorConstants.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    if (userPosts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 15.0,
                            mainAxisSpacing: 15.0,
                            childAspectRatio: 0.86,
                          ),
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            var post = userPosts[index].data();

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
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    if (userPosts.isEmpty)
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
      ),
    );
  }
}
