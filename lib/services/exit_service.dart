import 'package:flutter/material.dart';

class ExitService {
  static DateTime? _lastPressedAt;

  static Future<bool> onWillPop(BuildContext context) async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);
    final isWarning = _lastPressedAt == null ||
        now.difference(_lastPressedAt!) > maxDuration;

    if (isWarning) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
