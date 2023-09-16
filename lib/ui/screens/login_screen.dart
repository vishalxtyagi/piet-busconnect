import 'package:busconnect/ui/screens/registrations/student_registration_screen.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:busconnect/ui/screens/home_screen.dart';
import 'package:busconnect/ui/screens/registrations/guest_registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _checkIfUserRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRegistered = prefs.getBool('isRegistered') ?? false;

    if (isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger Google Sign-In and get authentication details
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

      // Create AuthCredential from access token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User user = userCredential.user!;

      // save google user data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', user.uid);
      prefs.setString('name', user.displayName ?? '');
      prefs.setString('email', user.email ?? '');
      prefs.setString('photoUrl', user.photoURL ?? '');


      // Check if user already exists in Firestore
      final userDoc = await _db.collection('students').doc(user.uid).get();
      print(userDoc.data());

      if (userDoc.exists) {
        print('User already exists in Firestore');
        prefs.setBool('isRegistered', true);
        prefs.setBool('isGuest', false);
        // store userdata
        for (var key in userDoc.data()!.keys) {
          prefs.setString(key, userDoc.data()![key]);
        }

        // Continue to app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('User does not exist in Firestore');
        // Navigate to registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentRegistrationScreen()),
        );
      }
    } catch (error) {
      // Handle authentication errors
      print('Error signing in with Google: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfUserRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Login'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : DotLottieLoader.fromAsset("assets/animations/authentication.lottie",
                    frameBuilder: (BuildContext ctx, DotLottie? dotlottie) {
                      if (dotlottie != null) {
                        return Lottie.memory(dotlottie.animations.values.single,
                            repeat: false,
                            height: 256
                        );
                      } else {
                        return Image.asset("assets/images/logo_vp.png");
                      }
                    }),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 250,
                    child: FilledButton(
                      onPressed: () async {
                        await _signInWithGoogle();
                      },
                      child: Text('Continue as Student'),
                    ),
                    margin: EdgeInsets.only(bottom: 10),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    margin: EdgeInsets.zero,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestRegistrationScreen(),
                          ),
                        );
                      },
                      child: Text('Guest Register'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
