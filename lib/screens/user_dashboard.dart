import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:surplus_plate/screens/user_profile_screen.dart';
import 'package:surplus_plate/screens/food_details_screen.dart';
import 'package:surplus_plate/utils/constants.dart';
import 'package:surplus_plate/services/vibration_service.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  String _filterText = '';
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surplus Plate - User'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              VibrationService.vibrate();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, User!',
                      style: kHeadlineStyle),
                  const SizedBox(height: kSmallPadding),
                  Text('Available surplus food near you:',
                      style: kBodyStyle),
                  const SizedBox(height: kSmallPadding),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by item or restaurant...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _filterText = val.toLowerCase().trim();
                      });
                    },
                  ),
                  const SizedBox(height: kLargePadding),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('food_listings')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child:
                                  Text('No food listings available right now.'));
                        }

                        final filteredDocs = snapshot.data!.docs.where((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};
                          final item = data['item']?.toString().toLowerCase() ?? '';
                          final restaurant =
                              data['restaurant']?.toString().toLowerCase() ?? '';
                          return item.contains(_filterText) ||
                              restaurant.contains(_filterText);
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(
                              child: Text('No matching results.'));
                        }

                        return ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocs[index];
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};

                            return FoodItemCard(
                              restaurantName: data['restaurant'] ?? 'Unknown',
                              item: data['item'] ?? 'Unknown item',
                              quantity: data['quantity'] ?? '',
                              originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
                              discountedPrice: (data['discountedPrice'] ?? 0.0).toDouble(),
                              pickupDateTime: data['pickupDateTime'] as Timestamp?,
                              imageUrl: data['imageUrl'] ?? '',
                              pickupLatitude:
                                  (data['latitude'] ?? 23.0225).toDouble(),
                              pickupLongitude:
                                  (data['longitude'] ?? 72.5714).toDouble(),
                              docId: doc.id,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: Text('History and Settings tabs coming soon.')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String restaurantName;
  final String item;
  final String quantity;
  final double originalPrice;
  final double discountedPrice;
  final Timestamp? pickupDateTime;
  final String imageUrl;
  final double pickupLatitude;
  final double pickupLongitude;
  final String docId;

  const FoodItemCard({
    super.key,
    required this.restaurantName,
    required this.item,
    required this.quantity,
    required this.originalPrice,
    required this.discountedPrice,
    required this.pickupDateTime,
    required this.imageUrl,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPickupTime = pickupDateTime != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(pickupDateTime!.toDate())
        : 'Not specified';

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: kSmallPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      child: InkWell(
        onTap: () {
          VibrationService.vibrate();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailsScreen(
                itemName: item,
                restaurant: restaurantName,
                quantity: quantity,
                timeLeft: formattedPickupTime,
                imageUrl: imageUrl,
                pickupLatitude: pickupLatitude,
                pickupLongitude: pickupLongitude,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(restaurantName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              const SizedBox(height: kSmallPadding),
              Text('Item: $item', style: kBodyStyle),
              Text('Quantity: $quantity', style: kBodyStyle),
              Row(
                children: [
                  Text('₹${discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(width: 8),
                  Text('₹${originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                ],
              ),
              Text('Pickup: $formattedPickupTime', style: kBodyStyle),
            ],
          ),
        ),
      ),
    );
  }
}
