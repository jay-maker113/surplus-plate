import 'package:flutter/material.dart';
import 'package:surplus_plate/screens/food_map_screen.dart';
import 'package:surplus_plate/services/payment_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:surplus_plate/utils/constants.dart';
import 'package:surplus_plate/services/vibration_service.dart';

class FoodDetailsScreen extends StatefulWidget {
  final String itemName;
  final String restaurant;
  final String quantity;
  final String timeLeft;
  final String imageUrl;
  final double pickupLatitude;
  final double pickupLongitude;

  const FoodDetailsScreen({
    super.key,
    required this.itemName,
    required this.restaurant,
    required this.quantity,
    required this.timeLeft,
    required this.imageUrl,
    required this.pickupLatitude,
    required this.pickupLongitude,
  });

  @override
  _FoodDetailsScreenState createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Details")),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(kBorderRadius),
                child: Image.network(widget.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: kLargePadding),
            Text(widget.itemName, style: kHeadlineStyle),
            const SizedBox(height: kSmallPadding),
            Text("Restaurant: ${widget.restaurant}", style: kBodyStyle),
            Text("Quantity: ${widget.quantity}", style: kBodyStyle),
            Text("Pickup Time: ${widget.timeLeft}", style: kBodyStyle),
            const SizedBox(height: kLargePadding),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("View on Map"),
              onPressed: () {
                VibrationService.vibrate();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodMapScreen(
                      pickupLatitude: widget.pickupLatitude,
                      pickupLongitude: widget.pickupLongitude,
                      showUserLocation: true, // or false, depending on your requirement
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: kSmallPadding),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Add to Cart & Pay"),
              onPressed: () {
                VibrationService.vibrate();
                // Add to cart logic here if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🛒 Added to cart. Opening payment...")),
                );
                // Open Razorpay checkout
                _paymentService.openCheckout(
                  amount: 10000, // ₹100 in paisa
                  name: 'Surplus Plate',
                  description: widget.itemName,
                  contact: '9999999999', // Dummy contact
                  email: 'user@example.com', // Dummy email
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
