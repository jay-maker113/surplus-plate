import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surplus_plate/utils/constants.dart';
import 'package:surplus_plate/services/vibration_service.dart';
import 'package:surplus_plate/services/exit_service.dart';
import 'user_dashboard.dart';
import 'restaurant_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Attempting login for email: ${_emailController.text.trim()}');
      // Firebase Auth Sign In
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());

      String uid = userCredential.user!.uid;
      print('Login successful, UID: $uid');

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final role = data['role'];
        print('User data fetched, role: $role');
        // Navigate based on role
        if (role == 'User') {
          print('Navigating to UserDashboard');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserDashboard()),
          );
        } else if (role == 'Restaurant') {
          print('Navigating to RestaurantDashboard');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RestaurantDashboard()),
          );
        } else {
          setState(() {
            _error = 'Unknown user role';
          });
        }
      } else {
        print('User document does not exist in Firestore');
        setState(() {
          _error = 'User data not found in database.';
        });
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.message}');
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      print('General login error: $e');
      setState(() {
        _error = 'An error occurred. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ExitService.onWillPop(context),
      child: Scaffold(
      appBar: AppBar(title: const Text('Surplus Plate Login')),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to Surplus Plate!",
                style: kHeadlineStyle,
              ),
              const SizedBox(height: kLargePadding),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),

              const SizedBox(height: kSmallPadding),

              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your password' : null,
              ),

              const SizedBox(height: kLargePadding),

              if (_error != null)
                Text(_error!, style: TextStyle(color: kErrorColor)),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    VibrationService.vibrate();
                    _loginUser();
                  }
                },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),

              const SizedBox(height: kSmallPadding),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
