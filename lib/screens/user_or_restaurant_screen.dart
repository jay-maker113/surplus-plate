import 'package:flutter/material.dart';
import 'package:surplus_plate/services/vibration_service.dart';
import 'package:surplus_plate/services/exit_service.dart';
import 'login_screen.dart'; // for user
import 'restaurant_login_screen.dart'; // for restaurant

class UserOrRestaurantScreen extends StatelessWidget {
  const UserOrRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ExitService.onWillPop(context),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Continue as", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  VibrationService.vibrate();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("User"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  VibrationService.vibrate();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RestaurantLoginScreen()),
                  );
                },
                child: const Text("Restaurant"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
