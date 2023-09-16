import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Map<String, dynamic>? _routes = {
    'bus_code': '1234',
    'route': [
      {
        'route_name': 'Route 1',
        'stops': [
          {'stop_name': 'Stop 1', 'stop_time': '10:00'},
          {'stop_name': 'Stop 2', 'stop_time': '10:10'},
          {'stop_name': 'Stop 3', 'stop_time': '10:20'},
        ]
      },
      {
        'route_name': 'Route 2',
        'stops': [
          {'stop_name': 'Stop 5', 'stop_time': '10:00'},
          {'stop_name': 'Stop 8', 'stop_time': '10:10'},
          {'stop_name': 'Stop 3', 'stop_time': '10:20'},
        ]
      },
    ],
  };

  int _selectedRouteIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data from Firestore
    fetchRoutes().then((routes) {
      setState(() {
        _routes = routes;
      });
    });
  }

  Future<Map<String, dynamic>> fetchRoutes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String busCode = prefs.getString('busCode') ?? '';

    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the document
    DocumentSnapshot documentSnapshot =
        await firestore.collection('routes').doc(busCode).get();

    // If the document exists
    if (documentSnapshot.exists) {
      // Return the document data
      return documentSnapshot.data() as Map<String, dynamic>;
    } else {
      // Return an empty map
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_routes == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Schedule'),
          shadowColor: Theme.of(context).shadowColor,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.schedule, size: 50),
              ),
            ),
            // select route dropdown
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Route',
                ),
value: _routes!['route'][0]['route_name'],
                items: [
                  for (var route in _routes!['route'])
                    DropdownMenuItem(
                      value: route['route_name'],
                      child: Text(route['route_name']),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _routes!['route'].forEach((route) {
                      if (route['route_name'] == value) {
                        _selectedRouteIndex = _routes!['route'].indexOf(route);
                      }
                    });
                  });
                },
              ),
            ),
            // schedule
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _routes!['route'][_selectedRouteIndex]['stops'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(
                      _routes!['route'][_selectedRouteIndex]['stops'][index]
                          ['stop_name'],
                    ),
                    subtitle: Text(
                      _routes!['route'][_selectedRouteIndex]['stops'][index]
                          ['stop_time'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
