import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

class SurplusPlateApp extends StatelessWidget {
  const SurplusPlateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surplus Plate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
