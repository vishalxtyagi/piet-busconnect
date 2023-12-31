import 'package:busconnect/ui/screens/guest_screen.dart';
import 'package:flutter/material.dart';
import 'package:busconnect/ui/screens/home_screen.dart';
import 'package:busconnect/ui/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  Future<void> _checkIfRegistered(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRegistered = prefs.getBool('isRegistered') ?? false;
    bool isGuest = prefs.getBool('isGuest') ?? false;

    if (isRegistered) {
      if (isGuest) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GuestScreen()),
        );
      } else {
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
  }

  @override
  Widget build(BuildContext context) {
    _checkIfRegistered(context);
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/splash_screen.png'),
      ),
    );
  }
}