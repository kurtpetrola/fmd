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

  // PRIMARY STYLING REFERENCE from user_page.dart
  final Color _appBarColor = Colors.amber;
  final Color _foregroundColor = Colors.black;

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
    return Scaffold(
      appBar: AppBar(
        // 1. CENTER TEXT & USE USER PAGE STYLE
        title: const Text('Admin: Dormitory CRUD'),
        backgroundColor: _appBarColor,
        foregroundColor: _foregroundColor,
        centerTitle: true,

        // 2. REMOVE BACK BUTTON (from previous request)
        automaticallyImplyLeading: false,

        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_sharp),
            onPressed: () => _showAddDormDialog(context),
            tooltip: 'Add New Dorm',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDorms,
            tooltip: 'Refresh List',
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
                child: Text('Error loading dorms: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
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

  // --- Card/List Tile UI ---
  Widget _buildDormCard(Dorms dorm) {
    final Color adminDeleteColor = Colors.red.shade700;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        child: Row(
          children: [
            // Dorm Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dorm Name (Primary Title)
                  Text(
                    dorm.dormName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // Using a different, strong color for list items for contrast with the amber bar
                      color: Colors.deepPurple,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Location Details (Secondary Information)
                  Text(
                    'ID: ${dorm.dormId ?? 'N/A'} | Location: ${dorm.dormLocation}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Coordinates (Tertiary information - helpful for Admin)
                  Text(
                    'Lat: ${dorm.latitude?.toStringAsFixed(6)}, Lng: ${dorm.longitude?.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () {
                // TODO: Implement _showEditDormDialog(context, dorm);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Edit feature not yet implemented')),
                );
              },
              tooltip: 'Edit Dorm',
            ),
            IconButton(
              icon:
                  Icon(Icons.delete_forever, color: adminDeleteColor, size: 28),
              onPressed: () => _deleteDorm(dorm),
              tooltip: 'Delete Dorm',
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDorm(Dorms dorm) async {
    if (dorm.dormId != null) {
      await _dbHelper.deleteDorm(dorm.dormId!);
      _refreshDorms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dorm.dormName} deleted successfully!')),
      );
    }
  }

  // --- Helper methods for Dialog UI ---
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        fillColor: Colors.grey.shade100,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      style: const TextStyle(
          fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
    );
  }

  // --- Dialog uses StatefulBuilder for map selection update ---
  Future<void> _showAddDormDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        // Use StatefulBuilder to manage local state changes within the dialog
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Add New Dormitory',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: _appBarColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Fields
                    _buildStyledTextField(
                      controller: nameController,
                      label: 'Dorm Name',
                    ),
                    _buildStyledTextField(
                      controller: numberController,
                      label: 'Dorm Number (Optional)',
                      keyboardType: TextInputType.number,
                    ),
                    _buildStyledTextField(
                      controller: locationController,
                      label: 'Location/Address Text',
                    ),

                    const SizedBox(height: 20),

                    // Location Picker Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: Text(
                        latController.text.isEmpty
                            ? 'SELECT LOCATION ON MAP'
                            : 'LOCATION SELECTED',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final LatLng? pickedLocation = await Navigator.push(
                          stfContext, // Use the StatefulBuilder context
                          MaterialPageRoute(
                            builder: (context) => const AdminLocationPicker(),
                          ),
                        );

                        if (pickedLocation != null) {
                          stfSetState(() {
                            // Call local setState to update the button text
                            latController.text =
                                pickedLocation.latitude.toStringAsFixed(6);
                            lngController.text =
                                pickedLocation.longitude.toStringAsFixed(6);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: latController.text.isEmpty
                            ? Colors.amber.shade700
                            : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Read-only coordinates display
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField(
                            controller: latController,
                            label: 'Latitude',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildReadOnlyField(
                            controller: lngController,
                            label: 'Longitude',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(stfContext),
                  child:
                      const Text('CANCEL', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Basic validation check
                    if (nameController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        latController.text.isNotEmpty &&
                        lngController.text.isNotEmpty) {
                      final newDorm = Dorms(
                        dormName: nameController.text,
                        dormNumber: numberController.text.isEmpty
                            ? 'N/A'
                            : numberController.text,
                        dormLocation: locationController.text,
                        latitude: double.tryParse(latController.text),
                        longitude: double.tryParse(lngController.text),
                        createdAt: DateTime.now().toIso8601String(),
                      );

                      try {
                        await _dbHelper.insertDorm(newDorm);

                        if (mounted) {
                          Navigator.pop(stfContext);
                          _refreshDorms();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('${newDorm.dormName} added locally!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to add dorm to local DB: $e')),
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
                  child: const Text('ADD DORM',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: _appBarColor),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
