import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notification {
  String id;
  String title;
  String notif;
  String senderName;
  bool isRead;
  final Timestamp timestamp;

  Notification(
      {required this.id,
      required this.title,
      required this.notif,
      required this.senderName,
      this.isRead = false,
      required this.timestamp});

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      title: map['title'],
      notif: map['notif'],
      senderName: map['senderName'],
      isRead: map['isRead'] ?? false,
      timestamp: map['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notif': notif,
      'senderName': senderName,
      'isRead': isRead,
      "timestamp": timestamp
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

    _notificationsCollection.snapshots().listen((snapshot) {
      _notifications = snapshot.docs
          .map(
              (doc) => Notification.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _unreadNotifications =
          _notifications.where((notification) => !notification.isRead).length;
      notifyListeners();
    });

    _notificationsCollection
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadNotifications = snapshot.docs.length;
      notifyListeners();
    });

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

  Future<void> markAsRead() async {
    final userId = _auth.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({'isRead': true});
      }
      _unreadNotifications = 0;
      notifyListeners();
    });
  }

  Future<void> someNotification({
    required String receiverId,
    required String senderId,
    required String title,
    required String senderName,
    required String notif,
  }) async {
    // Fetch the senderName from Firestore
    String? senderName;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get()
        .then((value) {
      final userData = value.data();
      if (userData != null) {
        senderName =
            '${userData['firstName']} ${userData['middleName']} ${userData['lastName']} ${userData['suffix']}';
      }
    });

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
        timestamp: Timestamp.now(),
      );

      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .add(notification.toMap());
    }
  }

  Stream<QuerySnapshot> getNotificationsStream() {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .snapshots();
  }
}
