import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  bool isRead;

  Message({
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.isRead
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      "timestamp": timestamp,
      'isRead': isRead
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      senderName: map['senderName'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: map['timestamp'],
      isRead: map['isRead']
    );
  }
}
