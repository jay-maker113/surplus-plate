import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart'; // Make sure this import path is correct

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  DateTime? _pickupDateTime;
  File? _imageFile;
  bool _isUploading = false;

  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final picker = ImagePicker();

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _pickupDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Capture from Camera'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => _imageFile = File(picked.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Select from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => _imageFile = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadListing({String? docId}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickupDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pickup date & time is required')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await ApiService.uploadImageToCloudinary(_imageFile!);
        if (imageUrl == null) {
          throw Exception("Image upload failed");
        }
      }

      final data = {
        'restaurant': _restaurantNameController.text.trim(),
        'item': _itemController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'originalPrice': double.tryParse(_originalPriceController.text.trim()) ?? 0.0,
        'discountedPrice': double.tryParse(_discountedPriceController.text.trim()) ?? 0.0,
        'pickupDateTime': _pickupDateTime != null ? Timestamp.fromDate(_pickupDateTime!) : null,
        'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
        'timestamp': FieldValue.serverTimestamp(),
        'uploadedBy': _uid,
        'imageUrl': imageUrl ?? ''
      };

      if (docId != null) {
        await FirebaseFirestore.instance.collection('food_listings').doc(docId).update(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing updated')));
      } else {
        await FirebaseFirestore.instance.collection('food_listings').add(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing uploaded')));
      }

      _restaurantNameController.clear();
      _itemController.clear();
      _quantityController.clear();
      _originalPriceController.clear();
      _discountedPriceController.clear();
      _pickupDateTime = null;
      _latitudeController.clear();
      _longitudeController.clear();
      setState(() => _imageFile = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Dashboard'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Upload Surplus Food Listing', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: const InputDecoration(labelText: 'Restaurant Name'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _itemController,
                  decoration: const InputDecoration(labelText: 'Food Item'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter food item' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter quantity' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _originalPriceController,
                  decoration: const InputDecoration(labelText: 'Original Price'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Enter original price' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _discountedPriceController,
                  decoration: const InputDecoration(labelText: 'Discounted Price'),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter discounted price';
                    double? disc = double.tryParse(val);
                    double? orig = double.tryParse(_originalPriceController.text);
                    if (disc != null && orig != null && disc >= orig) return 'Discounted price must be less than original';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_pickupDateTime == null ? 'Select Pickup Date & Time' : '${_pickupDateTime!.toLocal()}'.split('.')[0]),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Enter latitude' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Enter longitude' : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image'),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(_imageFile!, height: 120),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadListing,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Listing'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}