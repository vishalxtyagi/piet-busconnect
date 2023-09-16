import 'package:busconnect/ui/screens/features/attendance_screen.dart';
import 'package:busconnect/ui/screens/features/notification_screen.dart';
import 'package:busconnect/ui/screens/features/profile_screen.dart';
import 'package:busconnect/ui/screens/features/schedule_screen.dart';
import 'package:busconnect/ui/screens/login_screen.dart'; // Import the LoginScreen
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  final String title = 'Bus Connect';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  static List<Widget> pages = <Widget>[
    AttendanceScreen(),
    ScheduleScreen(),
    NotificationScreen(),
    ProfileScreen()
  ];

  Future<void> _checkIfRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRegistered = prefs.getBool('isRegistered') ?? false;

    if (!isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.directions_bus),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Updates',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
