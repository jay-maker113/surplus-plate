import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surplus_plate/utils/constants.dart';
import 'package:surplus_plate/services/vibration_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _password = '';
  String _latitude = '';
  String _longitude = '';
  bool _loading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    _formKey.currentState!.save();

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      String uid = userCredential.user!.uid;
      print('User created with UID: $uid');

      // Save user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': _name,
        'email': _email,
        'latitude': double.parse(_latitude),
        'longitude': double.parse(_longitude),
        'role': 'User', // Default role, can be changed later
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('User data saved to Firestore');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to Login Screen
      print('Navigating to login screen after registration');
      Navigator.pushReplacementNamed(context, '/login');
      print('Navigation to login screen completed');
    } catch (e) {
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Join Surplus Plate!",
                style: kHeadlineStyle,
              ),
              const SizedBox(height: kLargePadding),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: kSmallPadding),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                onSaved: (val) => _email = val!,
              ),
              const SizedBox(height: kSmallPadding),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
                onSaved: (val) => _password = val!,
              ),
              const SizedBox(height: kSmallPadding),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter latitude';
                  final num? lat = double.tryParse(val);
                  if (lat == null || lat < -90 || lat > 90) return 'Enter valid latitude (-90 to 90)';
                  return null;
                },
                onSaved: (val) => _latitude = val!,
              ),
              const SizedBox(height: kSmallPadding),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter longitude';
                  final num? lng = double.tryParse(val);
                  if (lng == null || lng < -180 || lng > 180) return 'Enter valid longitude (-180 to 180)';
                  return null;
                },
                onSaved: (val) => _longitude = val!,
              ),
              const SizedBox(height: kLargePadding),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        VibrationService.vibrate();
                        registerUser();
                      },
                      child: const Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
