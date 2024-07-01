import 'package:corp_tale/constants/color_const.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corp_tale/models/post_model.dart';

class PostListItem extends StatefulWidget {
  final Post post;
  final DocumentReference postRef; // Document reference for the post

  const PostListItem({Key? key, required this.post, required this.postRef})
      : super(key: key);

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  bool isLiked = false;
  int likeCount = 0;
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = [];

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes;
    isLiked = widget.post.likes > 0;
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add(_commentController.text);
      });

      // Update the comments array in Firestore
      await widget.postRef.update({
        'comments': FieldValue.arrayUnion([_commentController.text])
      });

      _commentController.clear();
    }
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    // Update the likes count in Firestore
    await widget.postRef.update({'likes': likeCount});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.post.imageUrl != null
                      ? NetworkImage(widget.post.imageUrl!)
                      : AssetImage('assets/images/default_user.png')
                          as ImageProvider,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.post.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textColorBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textColorBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.description,
              style: const TextStyle(color: ColorConstants.textColorBlack),
            ),
            const SizedBox(height: 8),
            if (widget.post.type == 'image')
              widget.post.imageUrl != null
                  ? Image.network(
                      widget.post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: const Text(
                          'Image Not Available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
            else
              const Text(
                'Text Post',
                style: TextStyle(color: ColorConstants.textColorBlack),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : ColorConstants.textColorBlack,
                  ),
                  onPressed: _toggleLike,
                ),
                Text(
                  '$likeCount likes',
                  style: const TextStyle(color: ColorConstants.textColorBlack),
                ),
                const Spacer(),
                Text(
                  '${widget.post.uploadedAt}',
                  style: const TextStyle(color: ColorConstants.textColorBlack),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.comment,
                      color: ColorConstants.textColorBlack),
                  onPressed: () {
                    _showCommentsBottomSheet(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        comments[index],
                        style: const TextStyle(
                            color: ColorConstants.textColorBlack),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style:
                          const TextStyle(color: ColorConstants.textColorBlack),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: ColorConstants.textColorBlack),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
