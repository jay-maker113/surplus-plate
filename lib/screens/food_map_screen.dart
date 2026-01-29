import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class FoodMapScreen extends StatefulWidget {
  final double pickupLatitude;
  final double pickupLongitude;
  final bool showUserLocation;

  const FoodMapScreen({
    super.key,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.showUserLocation,
  });

  @override
  State<FoodMapScreen> createState() => _FoodMapScreenState();
}

class _FoodMapScreenState extends State<FoodMapScreen> {
  List<Marker> markers = [];
  List<LatLng> routePoints = [];
  double routeDistance = 0.0;
  bool isLoading = true;
  String selectedMapStyle = 'street';
  late MapController mapController;

  // Map styles
  final Map<String, Map<String, dynamic>> mapStyles = {
    'street': {
      'url': "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      'subdomains': ['a', 'b', 'c'],
      'name': 'Street'
    },
    'dark': {
      'url': "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
      'subdomains': ['a', 'b', 'c', 'd'],
      'name': 'Dark'
    },
    'satellite': {
      'url': "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
      'subdomains': <String>[],
      'name': 'Satellite'
    },
    'light': {
      'url': "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
      'subdomains': ['a', 'b', 'c', 'd'],
      'name': 'Light'
    }
  };

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadMarkers();
  }

  Future<void> loadMarkers() async {
    setState(() => isLoading = true);
    
    List<Marker> loadedMarkers = [];

    try {
      // Firestore restaurant markers with custom design
      final restaurantSnapshot = await FirebaseFirestore.instance.collection('restaurants').get();
      final firestoreMarkers = restaurantSnapshot.docs.map((doc) {
        final data = doc.data();
        final lat = data['latitude'];
        final lng = data['longitude'];
        final name = data['name'] ?? 'Restaurant';

        if (lat != null && lng != null) {
          return Marker(
            width: 80,
            height: 80,
            point: LatLng(lat, lng),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.deepOrange,
                size: 28,
              ),
            ),
          );
        }
        return null;
      }).whereType<Marker>().toList();
      loadedMarkers.addAll(firestoreMarkers);

      // User location marker with modern design
      LatLng? userLocation;
      if (widget.showUserLocation) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
          if (userDoc.exists) {
            final data = userDoc.data()!;
            final lat = data['latitude'];
            final lng = data['longitude'];
            if (lat != null && lng != null) {
              userLocation = LatLng(lat, lng);
              loadedMarkers.add(
                Marker(
                  width: 80,
                  height: 80,
                  point: userLocation!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              );
            }
          }
        }
      }

      // Pickup marker with custom design
      final pickupLocation = LatLng(widget.pickupLatitude, widget.pickupLongitude);
      loadedMarkers.add(
        Marker(
          width: 80,
          height: 80,
          point: pickupLocation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_pin,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );

      // Load POIs
      final overpassMarkers = await fetchOverpassPOIs(widget.pickupLatitude, widget.pickupLongitude);
      loadedMarkers.addAll(overpassMarkers);

      // Calculate route
      if (widget.showUserLocation && userLocation != null) {
        print('User location: $userLocation');
        final route = await getRoutePoints(userLocation, pickupLocation);
        print('Route points count: ${route.length}');
        final distance = calculateDistance(route);
        print('Calculated distance: $distance');

        if (distance == 0) {
          print('Calculated distance is zero, route might be invalid');
        }

        setState(() {
          routePoints = route;
          routeDistance = distance;
        });
      }

      setState(() {
        markers = loadedMarkers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading markers: $e');
    }
  }

  // Your existing methods remain the same...
  Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    const apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjhhNDliNTU5YjFjOGEyNzExMWNlMjQyODIzMDljZTVlYWQ4M2I5NzY3NTEyMGQyMmI3OGQwYWM2IiwiaCI6Im11cm11cjY0In0=';
    final url = Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car/geojson');

    final body = jsonEncode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': apiKey,
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      print('Route error: ${response.body}');
      return [];
    }
  }

  double calculateDistance(List<LatLng> points) {
    double total = 0;
    final distance = Distance();
    for (int i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Kilometer, points[i], points[i + 1]);
    }
    return total;
  }

  Future<List<Marker>> fetchOverpassPOIs(double lat, double lon) async {
    const radius = 1000;
    final query = """
    [out:json];
    (
      node["amenity"="restaurant"](around:$radius,$lat,$lon);
      node["amenity"="fast_food"](around:$radius,$lat,$lon);
      node["amenity"="cafe"](around:$radius,$lat,$lon);
    );
    out body;
    """;

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List<dynamic>;

        return elements.map<Marker>((element) {
          final double lat = element['lat'];
          final double lon = element['lon'];
          final name = element['tags']?['name'] ?? 'POI';

          return Marker(
            width: 60,
            height: 60,
            point: LatLng(lat, lon),
            child: GestureDetector(
              onTap: () => _showPOIInfo(name),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_dining, color: Colors.white, size: 24),
              ),
            ),
          );
        }).toList();
      }
    } catch (e) {
      print('Overpass API error: $e');
    }
    return [];
  }

  void _showPOIInfo(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(name),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _changeMapStyle() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Map Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...mapStyles.entries.map((entry) => ListTile(
              leading: Icon(
                Icons.map,
                color: selectedMapStyle == entry.key ? Colors.orange : Colors.grey,
              ),
              title: Text(entry.value['name']),
              trailing: selectedMapStyle == entry.key ? const Icon(Icons.check, color: Colors.orange) : null,
              onTap: () {
                setState(() => selectedMapStyle = entry.key);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = mapStyles[selectedMapStyle]!;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Food Map', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _changeMapStyle,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              mapController.move(
                LatLng(widget.pickupLatitude, widget.pickupLongitude),
                14.0,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.pickupLatitude, widget.pickupLongitude),
              initialZoom: 14.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: currentStyle['url'],
                subdomains: currentStyle['subdomains'],
                userAgentPackageName: 'com.example.surplus_plate',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4,
                      color: Colors.orange,
                      pattern: StrokePattern.dotted(),
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
            ],
          ),
          
          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.orange),
                        SizedBox(height: 16),
                        Text('Loading restaurants...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Distance info card
          if (routeDistance > 0)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.directions_car, color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Distance to pickup',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${routeDistance.toStringAsFixed(1)} km",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "~${(routeDistance * 3).toInt()} min",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}