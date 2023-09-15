import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<dynamic>? _routes; // List to store fetched routes
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

  Future<List<dynamic>> fetchRoutes() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? busCode = prefs.getString('busCode');

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('routes')
        .doc(busCode)
        .get();

    // get keys from doc.data()
    

    return doc['routes'];
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
                value: _selectedRouteIndex,
                onChanged: (index) {
                  setState(() {
                    _selectedRouteIndex = index!;
                  });
                },
                items: List<DropdownMenuItem<int>>.generate(
                  _routes!.length,
                      (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text('Route ${index + 1}'),
                    );
                  },
                ),
              ),
            ),
            // schedule
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _routes![_selectedRouteIndex].length,
                itemBuilder: (context, index) {
                  var stop = _routes![_selectedRouteIndex][index];
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(stop['stop_name']),
                        trailing: Text(stop['stop_time']),
                      ),
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
