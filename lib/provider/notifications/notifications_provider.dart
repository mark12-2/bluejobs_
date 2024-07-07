import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notification {
  String id;
  String title;
  String notif;
  String senderName;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.notif,
    required this.senderName,
    this.isRead = false,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      title: map['title'],
      notif: map['notif'],
      senderName: map['senderName'],
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notif': notif,
      'senderName': senderName,
      'isRead': isRead,
    };
  }
}

class NotificationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _notificationsCollection;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Notification> _notifications = [];
  int _unreadNotifications = 0;

  List<Notification> get notifications => _notifications;
  int get unreadNotifications => _unreadNotifications;

  NotificationProvider() {
    init();
  }

  void init() {
    final userId = _auth.currentUser!.uid;
    _notificationsCollection =
        _firestore.collection('users').doc(userId).collection('notifications');

    // Fetch notifications from the current user's notifications collection
    _notificationsCollection.snapshots().listen((snapshot) {
      _notifications = snapshot.docs
          .map(
              (doc) => Notification.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      _unreadNotifications =
          _notifications.where((notification) => !notification.isRead).length;
      notifyListeners();
    });

    // Fetch notifications from the notifications collection of the users who sent the notifications
    _firestore
        .collection('users')
        .where('sentNotifications', arrayContains: userId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final senderId = doc.id;
        final senderNotificationsCollection = _firestore
            .collection('users')
            .doc(senderId)
            .collection('notifications');

        senderNotificationsCollection.snapshots().listen((snapshot) {
          final senderNotifications = snapshot.docs
              .map((doc) =>
                  Notification.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          // Add the sender's notifications to the _notifications list
          _notifications.addAll(senderNotifications);
          _unreadNotifications = _notifications
              .where((notification) => !notification.isRead)
              .length;
          notifyListeners();
        });
      });
    });
  }

  Future<void> addNotification(Notification notification,
      {required String receiverId}) async {
    final receiverNotificationsCollection = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications');
    await receiverNotificationsCollection.add(notification.toMap());
    notifyListeners();
  }

  void markAsRead() async {
    final userId = _auth.currentUser!.uid;
    final batch = _firestore.batch();

    final unreadNotifications =
        _notifications.where((notification) => !notification.isRead).toList();

    for (var notification in unreadNotifications) {
      final notificationDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id);
      batch.update(notificationDoc, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    _unreadNotifications = 0;
    notifyListeners();
  }

  Future<void> someNotification(
      {required String receiverId,
      required String senderId,
      required String senderName,
      required String title,
      required String notif}) async {
    // Fetch the senderName from Firestore
    String? senderName;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get()
        .then((value) => senderName = value.data()?['name']);

    if (senderName != null) {
      Notification notification = Notification(
        id: _firestore
            .collection('users')
            .doc(receiverId)
            .collection('notifications')
            .doc()
            .id,
        title: title,
        notif: notif,
        senderName: senderName!,
        isRead: false,
      );

      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .add(notification.toMap());
    }
  }

  Stream<QuerySnapshot> getNotificationsStream(String jobId) {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('jobId', isEqualTo: jobId)
        .where('notif', isEqualTo: 'Applied for the job')
        .snapshots();
  }
}
