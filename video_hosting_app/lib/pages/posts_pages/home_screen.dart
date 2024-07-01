import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:corp_tale/auth_pages/auth_controllers.dart';
import 'package:corp_tale/constants/color_const.dart';
import 'package:corp_tale/models/post_model.dart';
import 'package:corp_tale/pages/posts_pages/anonymous_page.dart.dart';
import 'package:corp_tale/pages/posts_pages/post_list_item.dart';

class ImageListPage extends StatefulWidget {
  final String currentUserId;

  const ImageListPage({super.key, required this.currentUserId});

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Post>> _postsFuture;
  late TabController _tabController;
  late ScrollController _homeScrollController;
  late ScrollController _anonymousScrollController;
  bool _showScrollUpButton = false;
  double _homeScrollPosition =
      0.0; // Variable to store the home tab scroll position
  double _anonymousScrollPosition =
      0.0; // Variable to store the anonymous tab scroll position

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchPosts();
    _tabController = TabController(length: 2, vsync: this);
    _homeScrollController =
        ScrollController(initialScrollOffset: _homeScrollPosition);
    _anonymousScrollController =
        ScrollController(initialScrollOffset: _anonymousScrollPosition);
    _homeScrollController.addListener(_scrollListener);
    _tabController.addListener(_tabListener);
  }

  void _scrollListener() {
    if (_tabController.index == 0) {
      if (_homeScrollController.position.pixels > 300) {
        setState(() {
          _showScrollUpButton = true;
        });
      } else {
        setState(() {
          _showScrollUpButton = false;
        });
      }
    }
  }

  void _tabListener() {
    if (_tabController.index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_homeScrollController.hasClients) {
          _homeScrollController.jumpTo(_homeScrollPosition);
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_anonymousScrollController.hasClients) {
          _anonymousScrollController.jumpTo(_anonymousScrollPosition);
        }
      });
    }
  }

  @override
  void dispose() {
    _homeScrollPosition = _homeScrollController
        .position.pixels; // Save the home tab scroll position
    _anonymousScrollPosition = _anonymousScrollController
        .position.pixels; // Save the anonymous tab scroll position
    _homeScrollController.removeListener(_scrollListener);
    _homeScrollController.dispose();
    _anonymousScrollController.dispose();
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    super.dispose();
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
        .where('uploadedBy', isNotEqualTo: 'anonymous')
        .get();

    List<Post> posts = [];
    for (var doc in querySnapshot.docs) {
      Post post = Post.fromFirestore(doc);

      // Fetch user information
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(post.uploadedBy)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        post.username =
            userData['username'] ?? userData['mobileNumber'] ?? 'Unknown';
      } else {
        post.username = 'Unknown';
      }
      posts.add(post);
    }

    return posts;
  }

  void _scrollToTop() {
    if (_tabController.index == 0) {
      _homeScrollController.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate);
    } else {
      _anonymousScrollController.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chatPage');
              },
              icon: Icon(Icons.chat_bubble_outline_rounded)),
          iconTheme: const IconThemeData(color: ColorConstants.textColorBlack),
          title: const Text(
            'Posts',
            style: TextStyle(color: ColorConstants.textColorBlack),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.home,
                  color: Color.fromARGB(255, 132, 132, 132),
                  size: 30,
                ),
                text: 'Home',
              ),
              Tab(
                text: 'Anonymous',
                icon: Image(
                  image: AssetImage('assets/images/anonymous_icon.png'),
                  height: 25,
                  color: Color.fromARGB(255, 132, 132, 132),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<Post>>(
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
                        controller: _homeScrollController,
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
                // Display the AnonymousPage directly in the TabBarView
                const AnonymousPage(),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _showScrollUpButton
                    ? IconButton(
                        onPressed: _scrollToTop,
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ))
                    : Container(),
              ),
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: ColorConstants.newColor4,
          foregroundColor: Colors.white,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          spacing: 12,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: ColorConstants.newColor2,
              onTap: () => Navigator.pushNamed(context, '/addImage'),
            ),
            SpeedDialChild(
              child: const Icon(Icons.search_outlined),
              backgroundColor: ColorConstants.newColor2,
              onTap: () => Navigator.pushNamed(
                context,
                '/usersList',
                arguments: {'currentUserId': widget.currentUserId},
              ),
            ),
            SpeedDialChild(
              child: const Icon(Icons.people_alt_outlined),
              backgroundColor: ColorConstants.newColor2,
              onTap: () => Navigator.pushNamed(context, '/profilePage'),
            ),
            SpeedDialChild(
              child: const Icon(Icons.notifications),
              backgroundColor: ColorConstants.newColor2,
              onTap: () => Navigator.pushNamed(context, '/notificationsPage'),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
