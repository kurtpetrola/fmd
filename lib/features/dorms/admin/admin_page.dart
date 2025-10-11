// admin_page.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // REQUIRED for LatLng
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/sqlite.dart';
// IMPORTANT: Adjust this import path if you put the picker file elsewhere!
import 'package:findmydorm/features/maps/tools/admin_location_picker.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Future<List<Dorms>> _dormsFuture;

  @override
  void initState() {
    super.initState();
    _refreshDorms();
  }

  void _refreshDorms() {
    setState(() {
      _dormsFuture = _dbHelper.getDorms();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your build method remains mostly the same, only the title changed) ...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Dormitory CRUD'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: () => _showAddDormDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _refreshDorms,
          ),
        ],
      ),
      body: FutureBuilder<List<Dorms>>(
        future: _dormsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading dorms: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No local dormitories found. Click + to add one.'));
          } else {
            return _buildDormList(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildDormList(List<Dorms> dorms) {
    return ListView.builder(
      itemCount: dorms.length,
      itemBuilder: (context, index) {
        final dorm = dorms[index];
        return _buildDormCard(dorm);
      },
    );
  }

  Widget _buildDormCard(Dorms dorm) {
    // ... (Your _buildDormCard remains the same) ...
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        title: Text(dorm.dormName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text('Location: ${dorm.dormLocation} | Number: ${dorm.dormNumber}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _deleteDorm(dorm),
        ),
        onTap: () {
          // TODO: Navigate to the DormDetailPage
        },
      ),
    );
  }

  void _deleteDorm(Dorms dorm) async {
    // ... (Your _deleteDorm remains the same) ...
    if (dorm.dormId != null) {
      await _dbHelper.deleteDorm(dorm.dormId!);
      _refreshDorms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dorm.dormName} deleted successfully!')),
      );
    }
  }

  // --- UPDATED Dialog to Add Dorm ---
  Future<void> _showAddDormDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    // NEW: Controllers for Latitude and Longitude
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Dorm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Dorm Name')),
              TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Dorm Number')),
              TextField(
                  controller: locationController,
                  decoration:
                      const InputDecoration(labelText: 'Location Text')),

              const SizedBox(height: 15),

              // Location Picker Button
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(latController.text.isEmpty
                    ? 'Pick Location on Map'
                    : 'Location Selected'),
                onPressed: () async {
                  // Launch the map picker and wait for a result
                  final LatLng? pickedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLocationPicker(),
                    ),
                  );

                  // Update controllers if a location was picked
                  if (pickedLocation != null) {
                    // Using a dummy setState here since this isn't the primary state of the AdminPage,
                    // but it forces the dialog UI to update the button text.
                    (context as Element).markNeedsBuild();
                    latController.text =
                        pickedLocation.latitude.toStringAsFixed(6);
                    lngController.text =
                        pickedLocation.longitude.toStringAsFixed(6);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: latController.text.isEmpty
                        ? Colors.amber
                        : Colors.green,
                    foregroundColor: Colors.white),
              ),

              const SizedBox(height: 10),

              // Read-only fields to display the chosen coordinates
              TextField(
                  controller: latController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Latitude (Auto-filled)'),
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              TextField(
                  controller: lngController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Longitude (Auto-filled)'),
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Basic validation check
              if (nameController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  latController.text.isNotEmpty && // Check if lat/lng are set
                  lngController.text.isNotEmpty) {
                final newDorm = Dorms(
                  dormName: nameController.text,
                  dormNumber: numberController.text.isEmpty
                      ? 'N/A'
                      : numberController.text,
                  dormLocation: locationController.text,

                  // NEW: Parse and save the location data
                  latitude: double.tryParse(latController.text),
                  longitude: double.tryParse(lngController.text),

                  // Required placeholders for image/description
                  // dormImageUrl: '',
                  // dormDescription: '',
                  createdAt: DateTime.now().toIso8601String(),
                );

                try {
                  await _dbHelper.insertDorm(newDorm);

                  if (mounted) {
                    Navigator.pop(context);
                    _refreshDorms();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${newDorm.dormName} added locally!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to add dorm to local DB: $e')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Please fill all required fields and pick a map location.')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
