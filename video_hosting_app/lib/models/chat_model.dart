// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatRoom {
//   String id;
//   List<String> users; // List of user IDs

//   ChatRoom({required this.id, required this.users});

//   factory ChatRoom.fromDocument(DocumentSnapshot doc) {
//     return ChatRoom(
//       id: doc.id,
//       users: List<String>.from(doc['users']),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'users': users,
//     };
//   }
// }

// class Message {
//   String senderId;
//   String text;
//   Timestamp timestamp;

//   Message(
//       {required this.senderId, required this.text, required this.timestamp});

//   factory Message.fromDocument(DocumentSnapshot doc) {
//     return Message(
//       senderId: doc['senderId'],
//       text: doc['text'],
//       timestamp: doc['timestamp'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'senderId': senderId,
//       'text': text,
//       'timestamp': timestamp,
//     };
//   }
// }
