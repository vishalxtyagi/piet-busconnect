import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_action/slide_action.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<Map<String, dynamic>> _attendance = [];
  DateTime lastAttendanceMarked = DateTime(0);
  bool attendanceMarkedToday = false;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Firebase.initializeApp();
      await _fetchAttendanceData();
      await _getLastAttendanceDate();
    } catch (e) {
      _showErrorDialog('Initialization failed: $e');
    }
  }

  Future<void> _fetchAttendanceData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');

      if (uid != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .where('uid', isEqualTo: uid)
            .get();

        setState(() {
          _attendance.clear();
          _attendance.addAll(querySnapshot.docs.map((DocumentSnapshot document) {
            return document.data() as Map<String, dynamic>;
          }).toList());
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch attendance data: $e');
    }
  }

  Future<void> _getLastAttendanceDate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastAttendanceDateString = prefs.getString('lastAttendanceDate');

      if (lastAttendanceDateString != null) {
        lastAttendanceMarked = DateTime.parse(lastAttendanceDateString);
        setState(() {
          attendanceMarkedToday =
              DateTime.now().day == lastAttendanceMarked.day;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to fetch last attendance date: $e');
    }
  }

  Future<void> _checkLocationPermissionAndService() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
  }

  Future<LatLng?> _getBusLocation() async {
    try {
      DocumentSnapshot busLocationSnapshot =
      await FirebaseFirestore.instance.collection('locations').doc('bus2302').get();

      if (busLocationSnapshot.exists) {
        Map<String, dynamic> data = busLocationSnapshot.data() as Map<String, dynamic>;
        double latitude = data['latitude'];
        double longitude = data['longitude'];
        return LatLng(latitude, longitude);
      }
    } catch (e) {
      print('Failed to fetch bus location: $e');
    }
    return null;
  }


  Future<void> _markAttendance() async {
    try {
      if (attendanceMarkedToday) {
        _showErrorDialog('Attendance already marked for today.');
        return;
      }

      // LocationData? userLocation = await _location.getLocation();
      // LatLng? busLocation = await _getBusLocation();
      //
      // if (userLocation == null || busLocation == null) {
      //   _showErrorDialog('Unable to fetch location data.');
      //   return;
      // }
      //
      // num distance = SphericalUtil.computeDistanceBetween(
      //   LatLng(userLocation.latitude!, userLocation.longitude!),
      //   busLocation,
      // );

      // if (distance < 10) {
        DateTime now = DateTime.now();
        if (now.day != lastAttendanceMarked.day) {
          // Update attendanceMarkedToday
          setState(() {
            attendanceMarkedToday = true;
          });
          // await _storeAttendanceRecord(userLocation.latitude!, userLocation.longitude!);
          await _storeAttendanceRecord(0, 0);
          lastAttendanceMarked = now;
          //
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('lastAttendanceDate', lastAttendanceMarked.toIso8601String());


          // Update attendance data once after marking attendance
          _fetchAttendanceData();
        }
      // } else {
      //   _showErrorDialog('You are not within 10 meters of the bus.');
      // }
    } catch (e) {
      _showErrorDialog('Failed to mark attendance: $e');
    }
  }



  Future<void> _storeAttendanceRecord(double latitude, double longitude) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');

      if (uid != null) {
        CollectionReference attendance =
        FirebaseFirestore.instance.collection('attendance');
        await attendance.add({
          'uid': uid,
          'timestamp': DateTime.now(),
          'type': 'in',
          'latitude': latitude,
          'longitude': longitude,
        });
      } else {
        _showErrorDialog('Please try to login again in the application');
      }
    } catch (e) {
      _showErrorDialog('Failed to store attendance record: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAttendanceList(),
            _buildSlideAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: _attendance.isEmpty
            ? Center(
          child: Text('No attendance records available.'),
        )
            : ListView.builder(
          itemBuilder: (context, index) {
            Map<String, dynamic> attendanceRecord = _attendance[index];
            DateTime timestamp = attendanceRecord['timestamp'].toDate();
            String formattedDate = DateFormat('dd MMM yyyy').format(timestamp);
            String formattedTime = DateFormat('hh:mm a').format(timestamp);
            String type = attendanceRecord['type'];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    type,
                    style: TextStyle(
                      color: type == 'in' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: _attendance.length,
        ),
      ),
    );
  }

  Widget _buildSlideAction() {
    DateTime now = DateTime.now();
    bool attendanceMarkedToday = now.day == lastAttendanceMarked.day;
    print(lastAttendanceMarked);
    print(attendanceMarkedToday);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      child: SlideAction(
        trackHeight: 100,
        // disable action if attendance is already marked today
        trackBuilder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: attendanceMarkedToday ? Colors.green : Colors.white60,
              // Adjust the color
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 15,
                ),
              ],
            ),
            // text at the end of the slider and vertically centered
            child: Center(
              child: Text(
              attendanceMarkedToday ? '         Checked In' : '               Swipe to mark attendance',
                style: TextStyle(
                  color: attendanceMarkedToday ? Colors.white : Colors.black,
                  fontWeight: attendanceMarkedToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: attendanceMarkedToday ? 18 : 14,
                ),
              ),
            ),
          );
        },
        thumbBuilder: (context, state) {
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              // Show loading indicator if async operation is being performed
              child: state.isPerformingAction
                  ? const CupertinoActivityIndicator(
                color: Colors.white,
              )
                  : attendanceMarkedToday ? const Icon(
                Icons.thumb_up,
                color: Colors.white,
              ) : const Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ),
          );
        },
        action: _markAttendance,
      ),
    );
  }

}
