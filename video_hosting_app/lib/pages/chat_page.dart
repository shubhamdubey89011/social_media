// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:corp_tale/methods/chat_service.dart';
// import 'package:corp_tale/models/chat_model.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatPage extends StatefulWidget {
//   final String otherUserId;

//   ChatPage({required this.otherUserId});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final ChatService _chatService = ChatService();

//   User? _currentUser;
//   late String _chatRoomId;

//   @override
//   void initState() {
//     super.initState();
//     _currentUser = _auth.currentUser;
//     _chatRoomId =
//         _chatService.getChatRoomId(_currentUser!.uid, widget.otherUserId);
//     _chatService.createChatRoom(_currentUser!.uid, widget.otherUserId);
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     Message message = Message(
//       senderId: _currentUser!.uid,
//       text: _messageController.text.trim(),
//       timestamp: Timestamp.now(),
//     );

//     await _chatService.sendMessage(_chatRoomId, message);

//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.otherUserId}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Message>>(
//               stream: _chatService.getMessages(_chatRoomId),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 List<Message> messages = snapshot.data!;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     Message message = messages[index];
//                     return MessageBubble(
//                       sender: message.senderId,
//                       text: message.text,
//                       isMe: _currentUser!.uid == message.senderId,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final String sender;
//   final String text;
//   final bool isMe;

//   MessageBubble({required this.sender, required this.text, required this.isMe});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment:
//             isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Text(
//             sender,
//             style: const TextStyle(
//               fontSize: 12.0,
//               color: Colors.black54,
//             ),
//           ),
//           Material(
//             borderRadius: isMe
//                 ? const BorderRadius.only(
//                     topLeft: Radius.circular(30.0),
//                     bottomLeft: Radius.circular(30.0),
//                     bottomRight: Radius.circular(30.0),
//                   )
//                 : const BorderRadius.only(
//                     topRight: Radius.circular(30.0),
//                     bottomLeft: Radius.circular(30.0),
//                     bottomRight: Radius.circular(30.0),
//                   ),
//             elevation: 5.0,
//             color: isMe ? Colors.lightBlueAccent : Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 10.0,
//                 horizontal: 20.0,
//               ),
//               child: Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: 15.0,
//                   color: isMe ? Colors.white : Colors.black54,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
