import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;


  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message)
    {
      // Handle notification when app is in foreground
      // This callback triggers when the app is in foreground.
      // You can use this to display a heads up notification or update the UI.
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      // Add notification to Firestore
      FirebaseFirestore.instance.collection('notifications').add({
        'title': message.notification!.title,
        'body': message.notification!.body,
        'time': DateTime.now().toString(),
        'read': false
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification when app is in background
      // This callback triggers when the app is in background.
      // You can use this to display a heads up notification or update the UI.
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      // Add notification to Firestore
      FirebaseFirestore.instance.collection('notifications').add({
        'title': message.notification!.title,
        'body': message.notification!.body,
        'time': DateTime.now().toString(),
        'read': true
      });
    });

    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _fcmToken = token;
        print('FCM Token: $_fcmToken');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No notifications available.'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.data!.docs[index];
                  return ListTile(
                    tileColor: doc['read'] ? Colors.grey[300] : Colors.green[100],
                    title: Text(doc['title']),
                    subtitle: Text(doc['body']),
                  );
                },
              );
            },
          ),
    );
  }
}
