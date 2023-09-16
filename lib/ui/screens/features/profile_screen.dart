import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _busStopController = TextEditingController();
  final _semesterController = TextEditingController();
  final _cityController = TextEditingController();
  final _rollNumberController = TextEditingController();

  late String _uid; // Store the user's ID
  String? _photoUrl;
  late Stream<DocumentSnapshot> _userStream; // Stream to listen for user updates

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid') ?? ''; // Get user ID from SharedPreferences
    _photoUrl = prefs.getString('photoUrl') ?? '';

    // Get user data stream
    _userStream = FirebaseFirestore.instance
        .collection('students')
        .doc(_uid)
        .snapshots();

    // Listen for data updates
    _userStream.listen((event) {
      // Update the UI when user data changes
      if (event.exists) {
        setState(() {
          // Update text controllers with new data
          _nameController.text = event['name'] ?? '';
          _phoneController.text = event['phone'] ?? '';
          _emailController.text = event['email'] ?? '';
          _busStopController.text = event['busStop'] ?? '';
          _semesterController.text = event['semester'] ?? '';
          _cityController.text = event['city'] ?? '';
          _rollNumberController.text = event['rollNumber'] ?? '';
        });
      }
    });
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      // Update the data in Firestore
      await FirebaseFirestore.instance.collection('students').doc(_uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'busStop': _busStopController.text,
        'semester': _semesterController.text,
        'city': _cityController.text,
        'rollNumber': _rollNumberController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }


  Widget _userPhoto() {
    // Check if photoUrl exists
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          _photoUrl!, // Display the user's photo
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Display a default person icon
      return Icon(Icons.person, size: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        shadowColor: Theme.of(context).shadowColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // ... other fields

              // avatar if photoUrl exists else show person icon
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircleAvatar(
                  radius: 50,
                  child: _userPhoto(), // Display user's photo or default person icon
                ),
              ),
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
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _updateUserData,
                    child: Text('Update Profile'),
                  ),
                ),
              ),
              // logout button
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
