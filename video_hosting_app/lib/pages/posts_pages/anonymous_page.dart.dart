import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/models/post_model.dart';
import 'package:corp_tale/pages/posts_pages/post_list_item.dart';
import 'package:corp_tale/widgets/custom_drawer.dart';

class AnonymousPage extends StatefulWidget {
  const AnonymousPage({super.key});

  @override
  _AnonymousPageState createState() => _AnonymousPageState();
}

class _AnonymousPageState extends State<AnonymousPage> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = fetchPosts();
    });
    await _postsFuture;
  }

  Future<List<Post>> fetchPosts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uploadedBy', isEqualTo: 'anonymous')
        .get();

    return querySnapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: ColorConstants.linearGradientColor8,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No posts found.'));
            }

            List<Post> posts = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostListItem(
                    post: posts[index],
                    postRef: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(posts[index].id),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
