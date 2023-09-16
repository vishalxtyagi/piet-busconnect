import 'package:busconnect/ui/screens/registrations/guest_registration_screen.dart';
import 'package:busconnect/ui/screens/registrations/student_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  final String title = 'Guest';

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {

  String name = 'Guest';

  Future<String?> _guestData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRegistered = prefs.getBool('isRegistered') ?? false;
    bool isGuest = prefs.getBool('isGuest') ?? false;

    if (isRegistered) {
      if (!isGuest) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }

    return prefs.getString('name');
  }

  @override
  Widget build(BuildContext context) {
_guestData(context).then((value) => setState(() {
      name = value!;
    }));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Guest'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Image.asset('assets/images/splash_screen.png',
                height: 156),
                const SizedBox(height: 50),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10)
                ,child:

                Text(
                  'Welcome, ${name}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10)
            ,child:

            Text(
                  'You are currently logged in as a guest.\nYou can register as a student to get more features.',
                  textAlign: TextAlign.center,
                ),
          ),
                const SizedBox(height: 80),
                Container(
                  height: 50,
                  width: 250,
                  // logout button
                  child: FilledButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      await prefs.clear(); // Clear all data from SharedPreferences
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                            (route) => false,
                      ); // Navigate to LoginScreen and remove all previous routes
                    },
                    child: Text('Logout'),
                  ),
                  margin: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
