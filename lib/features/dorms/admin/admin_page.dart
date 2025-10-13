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

  // PRIMARY STYLING REFERENCE
  final Color _appBarColor = Colors.amber.shade700;
  //final Color _backgroundColor = Colors.white;

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
        title: const Text(
          'Admin: Dormitory CRUD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // refresh for quick data update
            onPressed: _refreshDorms,
            tooltip: 'Refresh List',
          ),
          IconButton(
            // Changed to the standard 'add' icon
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDormDialog(context),
            tooltip: 'Add New Dorm',
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
    final Color primaryAmber = Colors.amber.shade700;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5, // Slightly deeper shadow
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Increased horizontal margin
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 12.0, horizontal: 16.0), // Increased padding
        child: Row(
          children: [
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
                      color: Colors.black87, // Stronger text color
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Increased spacing

                  // Location Details
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    dorm.dormLocation,
                    primaryAmber, // Highlight location
                  ),
                  const SizedBox(height: 2),

                  // Coordinates (Tertiary information - helpful for Admin)
                  Text(
                    'Coords: ${dorm.latitude?.toStringAsFixed(6)}, ${dorm.longitude?.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey, // Subtle grey for coordinates
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons (Keep current functionality but with consistent icon colors)
            IconButton(
              icon: Icon(Icons.edit,
                  color: primaryAmber), // Use primary color for edit
              onPressed: () {
                // ...
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

  // NEW HELPER WIDGET for cleaner data presentation
  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
    bool isRequired = false,
  }) {
    final Color primaryAmber = Colors.amber.shade700;
    const borderRadius = BorderRadius.all(Radius.circular(15.0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: isRequired ? '(Required)' : '',
          hintStyle: TextStyle(color: Colors.red.shade400, fontSize: 12),
          fillColor: Colors.grey.shade100,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

          // Set the color of the label when it floats up
          floatingLabelStyle: TextStyle(
            color: primaryAmber, // Use your primary amber color
            fontWeight: FontWeight.bold,
          ),
          // FIX 3: Set the color of the label when it is inside the field
          labelStyle: TextStyle(
            color: Colors.grey.shade600, // Use a neutral color
          ),

          border: const OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: primaryAmber, width: 2.0),
          ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Consistent radius
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.grey.shade200, // Slightly darker fill for read-only
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      style: const TextStyle(
          fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
    );
  }

  // --- Dialog uses StatefulBuilder for map selection update ---
  Future<void> _showAddDormDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();

    // local state for validation feedback
    String validationError = '';
    final Color errorRed = Colors.red.shade700;

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

                    // Display validation error below fields
                    if (validationError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          validationError,
                          style: TextStyle(
                              color: errorRed, fontWeight: FontWeight.bold),
                        ),
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
                // CANCEL Button (Secondary action: TextButton with Red color)
                TextButton(
                  onPressed: () => Navigator.pop(stfContext),
                  child: const Text('CANCEL',
                      style: TextStyle(
                          color:
                              Colors.grey)), // Use a neutral color for Cancel
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Basic validation check
                    if (nameController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        latController.text.isNotEmpty &&
                        lngController.text.isNotEmpty) {
                      // Clear error on success attempt
                      if (validationError.isNotEmpty) {
                        stfSetState(() => validationError = '');
                      }
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
                          color: Colors.black,
                          fontWeight:
                              FontWeight.bold)), // Black text on Amber button
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.amber.shade700, // Consistent Amber
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10)) // Nicer shape
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
