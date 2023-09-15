import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  final String title = 'Attendance';

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  final List<Map<String, dynamic>> _attendance = [
    {
      'timestamp': '2021-09-01 07:00:00',
      'type': 'in',
      'lat': 28.987,
      'long': 77.123,
      'distance_from_bus': 0.5,
    },
    {
      'timestamp': '2021-09-01 16:00:00',
      'type': 'out',
      'lat': 28.987,
      'long': 77.123,
      'distance_from_bus': 0.5,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // show attendance history and mark attendance button at the bottom
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(_attendance[index]['timestamp']),
                  subtitle: Text(_attendance[index]['type']),
                  trailing: _attendance[index]['type'] == 'in' ? const Icon(Icons.arrow_forward_ios) : null,
                  onTap: () {},
                ),
              );
            }, itemCount: _attendance.length,),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Mark Attendance'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
