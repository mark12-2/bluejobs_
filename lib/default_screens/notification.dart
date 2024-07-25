import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart'
    as notifications;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await notificationProvider.markAsRead();
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<NotificationProvider>(context, listen: false)
            .getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No notifications'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                reverse: false,
                itemBuilder: (context, index) {
                  final notificationData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final notification =
                      notifications.Notification.fromMap(notificationData);
                  Timestamp timestamp = notification.timestamp;
                  DateTime dateTime = timestamp.toDate();

                  String formattedDate =
                      DateFormat('MMM dd, yyyy').format(dateTime);
                  String formattedTime = DateFormat('hh:mm a').format(dateTime);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(width: 1, color: Colors.grey),
                      ),
                      child: ListTile(
                          leading: notification.isRead
                              ? Icon(Icons.check, color: Colors.grey)
                              : Icon(Icons.circle, color: Colors.blue),
                          title: Text(
                            notification.title,
                            style: CustomTextStyle.semiBoldText,
                          ),
                          subtitle: Text(
                            (notification.senderName + notification.notif),
                            style: CustomTextStyle.regularText,
                          ),
                          trailing: Column(
                            children: [
                              Text(
                                formattedDate,
                              ),
                              Text(
                                formattedTime,
                              ),
                            ],
                          )),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
