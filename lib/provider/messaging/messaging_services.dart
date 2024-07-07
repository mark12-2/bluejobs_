import 'package:bluejobs/model/message_model.dart';
import 'package:bluejobs/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> fetchCurrentUserDetails() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final docRef = _firestore.collection('users').doc(currentUser.uid);
        final docSnap = await docRef.get();

        if (docSnap.exists) {
          return UserModel.fromMap(docSnap.data() ?? {});
        } else {
          debugPrint("No user found!");
          return null;
        }
      } else {
        debugPrint("No current user signed in.");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  Future<String?> fetchUserName(String userId) async {
    try {
      final docSnap = await _firestore.collection('users').doc(userId).get();
      if (docSnap.exists) {
        return docSnap.data()?['name'];
      } else {
        debugPrint("User not found!");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
      return null;
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint("No current user signed in.");
        return;
      }

      final UserModel? currentUserDetails = await fetchCurrentUserDetails();
      if (currentUserDetails == null) {
        debugPrint("Current user details not found.");
        return;
      }

      final String currentUserId = currentUser.uid;
      final String currentUserName = currentUserDetails.name;
      final Timestamp timestamp = Timestamp.now();

      final String? receiverName = await fetchUserName(receiverId);
      if (receiverName == null) {
        debugPrint("Receiver name not found.");
        return;
      }

      final List<String> ids = [currentUserId, receiverId]..sort();
      final String chatRoomId = ids.join('_');

      // Create a new message
      final Message newMessage = Message(
        senderId: currentUserId,
        senderName: currentUserName,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
      );

      // Store the other user's name in the message rooms collection
      await _firestore.collection('message rooms').doc(chatRoomId).set({
        'users': ids,
        'userNames': {
          currentUserId: currentUserName,
          receiverId: receiverName,
        }
      });

      // Add new message to database
      await _firestore
          .collection('message rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final List<String> ids = [userId, otherUserId]..sort();
    final String chatRoomId = ids.join("_");

    return _firestore
        .collection('message rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _firestore
        .collection('message rooms')
        .where('users', arrayContains: userId)
        .snapshots();
  }
}
