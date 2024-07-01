// // ignore_for_file: library_private_types_in_public_api

// import 'package:flutter/material.dart';
// import 'package:corp_tale/models/video_model.dart';
// import 'package:corp_tale/pages/fetch_videos_method.dart';
// import 'package:corp_tale/widgets/custom_bottom_navigation_bar.dart';
// import 'package:video_player/video_player.dart';

// class VideoListPage extends StatefulWidget {
//   const VideoListPage({super.key});

//   @override
//   _VideoListPageState createState() => _VideoListPageState();
// }

// class _VideoListPageState extends State<VideoListPage> {
//   late Future<List<Video>> _videosFuture;

//   @override
//   void initState() {
//     super.initState();
//     _videosFuture = fetchVideos();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video List'),
//       ),
//       body: FutureBuilder<List<Video>>(
//         future: _videosFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No videos found.'));
//           }

//           List<Video> videos = snapshot.data!;
//           return ListView.builder(
//             itemCount: videos.length,
//             itemBuilder: (context, index) {
//               return VideoListItem(video: videos[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class VideoListItem extends StatefulWidget {
//   final Video video;

//   const VideoListItem({super.key, required this.video});

//   @override
//   _VideoListItemState createState() => _VideoListItemState();
// }

// class _VideoListItemState extends State<VideoListItem> {
//   late VideoPlayerController _controller;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
//           ..initialize().then((_) {
//             setState(() {});
//           });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: Card(
//         margin: const EdgeInsets.all(8.0),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(widget.video.title,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(widget.video.description),
//               const SizedBox(height: 8),
//               Text('Category: ${widget.video.category}'),
//               const SizedBox(height: 8),
//               Text('Uploaded At: ${widget.video.uploadedAt}'),
//               const SizedBox(height: 8),
//               _controller.value.isInitialized
//                   ? AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: VideoPlayer(_controller),
//                     )
//                   : const Center(child: CircularProgressIndicator()),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: Icon(_controller.value.isPlaying
//                         ? Icons.pause
//                         : Icons.play_arrow),
//                     onPressed: () {
//                       setState(() {
//                         _controller.value.isPlaying
//                             ? _controller.pause()
//                             : _controller.play();
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: AppBottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (int index) {
//           // Navigate to AddVideoPage when tapping "Add Video" icon
//           if (index == 1) {
//             Navigator.pushNamed(context, '/addVideo');
//           } else {
//             setState(() {
//               _currentIndex = index;
//             });
//           }
//         },
//       ),
//     );
//   }
// }
