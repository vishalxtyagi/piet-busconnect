import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:busconnect/ui/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({Key? key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;
  String? _userUid;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _busStopController = TextEditingController();
  final _semesterController = TextEditingController();
  final _cityController = TextEditingController();
  final _rollNumberController = TextEditingController();

  // function user data from shared preferences
  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('name') ?? '';
    _phoneController.text = prefs.getString('phone') ?? '';
    _emailController.text = prefs.getString('email') ?? '';

    _userUid = prefs.getString('uid');
  }

  Future<void> _submitDataToCloud(String code) async {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Prepare data
    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'busStop': _busStopController.text,
      'semester': _semesterController.text,
      'city': _cityController.text,
      'rollNumber': _rollNumberController.text,
      'busCode': code,
    };

    // Add a new document with a user.uid as the document ID
    await firestore.collection('students').doc(_userUid).set(userData);

    // Save registration preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isRegistered', true);
    prefs.setBool('isGuest', false);
    // store userdata
    for (var key in userData.keys) {
      prefs.setString(key, userData[key]);
    }

    // Navigate to home screen after successful submission
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Registration'),
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // ... (existing code for text fields)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Full Name',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email Address',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _busStopController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Bus Stop',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _semesterController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Semester',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'City',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _rollNumberController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Roll Number',
                  ),
                ),
              ),
              Container(
                height: 50,
                width: 250,
                margin: EdgeInsets.only(top: 50),
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                        context: context,
                        onCode: (code) {
                          setState(() {
                            this.code = code;
                          });

                          if (code != null) {
                            print(code);
                            // Submit data to cloud
                          }
                        },
                      );
                      _submitDataToCloud('bus2302');
                    }
                  },
                  child: Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
