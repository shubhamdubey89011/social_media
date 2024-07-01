// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:corp_tale/models/chat_model.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<ChatRoom> createChatRoom(String userId, String otherUserId) async {
//     String chatRoomId = getChatRoomId(userId, otherUserId);

//     DocumentReference chatRoomRef =
//         _firestore.collection('chats').doc(chatRoomId);

//     DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
//     if (!chatRoomSnapshot.exists) {
//       await chatRoomRef.set({
//         'users': [userId, otherUserId],
//       });
//     }

//     return ChatRoom(id: chatRoomId, users: [userId, otherUserId]);
//   }

//   String getChatRoomId(String userId, String otherUserId) {
//     return userId.hashCode <= otherUserId.hashCode
//         ? '$userId$otherUserId'
//         : '$otherUserId$userId';
//   }

//   Stream<List<Message>> getMessages(String chatRoomId) {
//     return _firestore
//         .collection('chats')
//         .doc(chatRoomId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) =>
//             snapshot.docs.map((doc) => Message.fromDocument(doc)).toList());
//   }

//   Future<void> sendMessage(String chatRoomId, Message message) async {
//     await _firestore
//         .collection('chats')
//         .doc(chatRoomId)
//         .collection('messages')
//         .add(message.toMap());
//   }
// }
