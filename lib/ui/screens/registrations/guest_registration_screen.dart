import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:busconnect/ui/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../guest_screen.dart';

class GuestRegistrationScreen extends StatefulWidget {
  const GuestRegistrationScreen({Key? key}) : super(key: key);

  @override
  _GuestRegistrationScreenState createState() => _GuestRegistrationScreenState();
}

class _GuestRegistrationScreenState extends State<GuestRegistrationScreen> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _busStopController = TextEditingController();
  final _purposeController = TextEditingController();

  Future<void> _submitDataToCloud(String code) async {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Prepare data
    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'busStop': _busStopController.text,
      'purpose': _purposeController.text,
      'busCode': code,
    };

    // Add a new document with a generated ID
    await firestore.collection('guests').add(userData);

    // Save registration preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isRegistered', true);
    prefs.setBool('isGuest', true);
    // store userdata
    for (var key in userData.keys) {
      prefs.setString(key, userData[key]);
    }

    // Navigate to home screen after successful submission
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GuestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest Registration'),
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30),
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
                    icon: Icon(Icons.person),
                    labelText: 'Full Name',
                    hintText: 'Enter you full name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Phone Number',
                    hintText: 'Enter you phone number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email Address',
                    hintText: 'Enter you email address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                  controller: _busStopController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.bus_alert),
                    labelText: 'Bus Stop',
                    hintText: 'Enter you bus stop',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: TextField(
                  controller: _purposeController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter you purpose',
                    border: OutlineInputBorder(),
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
                            // Submit data to cloud
                            _submitDataToCloud(code);
                          }
                        },
                      );
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
