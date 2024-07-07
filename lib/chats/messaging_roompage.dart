import 'package:bluejobs/chats/chatbubble.dart';
import 'package:bluejobs/provider/messaging/messaging_services.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessagingBubblePage extends StatelessWidget {
  final String receiverName;
  final String receiverId;

  MessagingBubblePage(
      {super.key, required this.receiverName, required this.receiverId});

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage(BuildContext context) async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverId, _messageController.text);

      // Send notification
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.someNotification(
        receiverId: receiverId,
        senderId: _auth.currentUser!.uid,
        senderName: _auth.currentUser!.displayName ?? 'Unknown',
        title: 'New Message',
        notif: ' sent you a message: "${_messageController.text}"',
      );

      // clear message after sending
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receiverName)),
      body: Column(
        children: [
          // display messsages
          Expanded(child: _buildMessageList()),
          // user input
          _buildUserInput(context),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    String senderId = _auth.currentUser!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(receiverId, senderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(context, doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime yyyy-MM-dd
    String formattedTimestamp = DateFormat('hh:mm').format(dateTime);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: alignment,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          data['senderId'] == _auth.currentUser!.uid
              ? const Text(
                  'You',
                  style: CustomTextStyle.chatusernameRegularText,
                )
              : Text(
                  data['senderName'],
                  style: CustomTextStyle.chatusernameRegularText,
                ),
          Chatbubble(
            message: data['message'],
          ),
          Text(formattedTimestamp),
        ]),
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _messageController,
              maxLines: 100,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Type message...',
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => sendMessage(context),
        ),
      ],
    );
  }
}
