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
        final userData = docSnap.data();
        final String fullName =
            '${userData?['firstName']} ${userData?['middleName']} ${userData?['lastName']} ${userData?['suffix']}';
        return fullName;
      } else {
        debugPrint("User not found!");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
      return null;
    }
  }

  Future<String?> fetchUserProfilePicture(String userId) async {
    try {
      final docSnap = await _firestore.collection('users').doc(userId).get();
      if (docSnap.exists) {
        final userData = docSnap.data();
        return userData?['profilePic'];
      } else {
        debugPrint("User not found!");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile picture: $e");
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
      final String currentUserName =
          "${currentUserDetails.firstName} ${currentUserDetails.middleName} ${currentUserDetails.lastName} ${currentUserDetails.suffix}";
      final String? receiverProfilePicture =
          await fetchUserProfilePicture(receiverId);
      final Timestamp timestamp = Timestamp.now();

      final String? receiverName = await fetchUserName(receiverId);
      if (receiverName == null) {
        debugPrint("Receiver name not found.");
        return;
      }

      final List<String> ids = [currentUserId, receiverId]..sort();
      final String chatRoomId = ids.join('_');

      final Message newMessage = Message(
          senderId: currentUserId,
          senderName: currentUserName,
          receiverId: receiverId,
          message: message,
          timestamp: timestamp,
          isRead: false);

      await _firestore.collection('message rooms').doc(chatRoomId).set({
        'users': ids,
        'userNames': {
          currentUserId: currentUserName,
          receiverId: receiverName,
        },
        'profilePics': {
          currentUserId: currentUserDetails.profilePic,
          receiverId: receiverProfilePicture,
        }
      });

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

  Stream<QuerySnapshot> getNotificationsStream() {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .snapshots();
  }

  Future<void> markMessageAsRead(String messageId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}
