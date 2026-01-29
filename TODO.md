# TODO List for UI/UX Improvements and New Features

## Completed
- [x] Custom ColorScheme and theming in main.dart and constants.dart.
- [x] Updated login_screen.dart, register_screen.dart, user_dashboard.dart, food_details_screen.dart with new styling.
- [x] Added Google Fonts and Razorpay integration.

## New Features Plan
1. [x] Add audioplayers package to pubspec.yaml.
2. [x] Create lib/services/sound_service.dart for sound management.
3. [x] Implement double-tap to exit in main.dart with WillPopScope.
4. [x] Add sound effects to buttons in login_screen.dart.
5. [x] Add sound effects to buttons in register_screen.dart.
6. [x] Add sound effects to buttons/cards in user_dashboard.dart.
7. [x] Add sound effects to buttons in food_details_screen.dart.
8. [x] Add sound assets to pubspec.yaml and create assets/sounds/ directory.

## Followup:
- [x] Created assets/sounds/ directory.
- [x] Added click.mp3 and tap.mp3 (tap.mp3 not used, can be removed if desired).
- [x] Preloaded click sound to eliminate delay.
- Test double-tap exit on Android back button.
- Test sound playback on button interactions (should be instant now).
- Ensure no breaking of existing logic.

## Remove Sound and Add Vibration
- [x] Remove audioplayers from pubspec.yaml
- [x] Add vibration to pubspec.yaml
- [x] Delete lib/services/sound_service.dart
- [x] Remove assets/sounds/ from pubspec.yaml
- [x] Delete assets/sounds/ directory
- [x] Create lib/services/vibration_service.dart
- [x] Update lib/screens/login_screen.dart: remove sound, add vibration
- [x] Update lib/screens/register_screen.dart: remove sound, add vibration
- [x] Update lib/screens/user_dashboard.dart: remove sound, add vibration
- [x] Update lib/screens/food_details_screen.dart: remove sound, add vibration
- [x] Update TODO.md
