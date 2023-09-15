import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  final String title = 'Notifications';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Hey, Bus no. 2 is arriving in 5 minutes',
      'time': '5 minutes ago',
      'read': false,
    },
    {
      'title': 'Bus no. 1 has been cancelled',
      'time': '1 hour ago',
      'read': true,
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
  }

  void _clearAllNotofications() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_notifications[index]['title']),
              subtitle: Text(_notifications[index]['time']),
              trailing: _notifications[index]['read'] ? null : const Icon(Icons.circle, color: Colors.red),
              onTap: () => _markAsRead(index),
            ),
          );
        }, itemCount: _notifications.length,),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAllNotofications,
        tooltip: 'Clear All',
        child: const Icon(Icons.clear_all),
      ),
    );
  }
}
