import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
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
        },
      ),
    );
  }
}
