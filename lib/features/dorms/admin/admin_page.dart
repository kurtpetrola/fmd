// admin_page.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/maps/tools/admin_location_picker.dart';

// NOTE: You would typically import 'package:http/http.dart' as http; for real API calls

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

  // ==========================================================
  // Server Synchronization Method (Used 'endpoint' in print)
  // ==========================================================
  Future<void> _syncDormToServer(Dorms dorm, String action) async {
    if (dorm.dormId == null && action != 'create') {
      print('Warning: Cannot sync dorm without an ID for action: $action');
      return;
    }

    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: IMPLEMENT YOUR ACTUAL SERVER API CALLS HERE
    // The endpoint variable is intentionally defined here for your future use.
    // It will now be used in the print statement to clear the warning.
    final endpoint = 'YOUR_SERVER_API_ENDPOINT/dorms/${dorm.dormId}';

    switch (action) {
      case 'create':
        // http.post(Uri.parse('YOUR_SERVER_API_ENDPOINT/dorms'), body: dormsToJson(dorm), ...);
        print(
            'Dorm ID NEW added. Target endpoint (POST): YOUR_SERVER_API_ENDPOINT/dorms');
        break;
      case 'update':
        // http.put(Uri.parse(endpoint), body: dormsToJson(dorm), ...);
        print(
            'Dorm ID ${dorm.dormId} updated. Target endpoint (PUT/PATCH): $endpoint');
        break;
      case 'delete':
        // http.delete(Uri.parse(endpoint), ...);
        print(
            'Dorm ID ${dorm.dormId} deleted. Target endpoint (DELETE): $endpoint');
        break;
      default:
        throw Exception('Invalid sync action: $action');
    }

    // NOTE: You should check the HTTP response status code (e.g., 200 or 204)
    // and throw an exception if the sync fails.
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
                // EDIT DIALOG
                _showEditDormDialog(context, dorm);
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

  // ==========================================================
  // Delete Method with Server Sync
  // ==========================================================
  void _deleteDorm(Dorms dorm) async {
    if (dorm.dormId == null) {
      // Safety check for dorms without an ID (shouldn't happen for displayed dorms)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Dormitory ID is missing.')),
      );
      return;
    }

    try {
      // 1. Delete from local SQLite DB
      await _dbHelper.deleteDorm(dorm.dormId!);

      // 2. Delete from server
      await _syncDormToServer(dorm, 'delete'); // 🚨 Action: 'delete'

      // 3. Refresh UI and show success message
      _refreshDorms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${dorm.dormName} deleted locally and synced to server!')),
      );
    } catch (e) {
      // Handle potential sync errors
      _refreshDorms(); // Try to refresh even on error to see current local state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete or sync ${dorm.dormName}. Error: $e')),
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
          // Set the color of the label when it is inside the field
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

  // --- ADD DORM DIALOG  ---
  Future<void> _showAddDormDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();
    // 🚨 NEW CONTROLLER
    final TextEditingController descriptionController = TextEditingController();

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
                    // 🚨 NEW: Dorm Description Field
                    _buildStyledTextField(
                      controller: descriptionController,
                      label: 'Dorm Description/Details',
                      keyboardType: TextInputType.multiline,
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
                        // Pass the description
                        dormDescription: descriptionController.text.isEmpty
                            ? 'No description provided.'
                            : descriptionController.text,
                        latitude: double.tryParse(latController.text),
                        longitude: double.tryParse(lngController.text),
                        createdAt: DateTime.now().toIso8601String(),
                      );

                      try {
                        // Insert locally and get the new ID
                        final newId = await _dbHelper.insertDorm(newDorm);
                        final dormWithId =
                            newDorm.copyWith(dormId: newId); // Need ID for sync

                        // Sync to server (Action: 'create')
                        await _syncDormToServer(dormWithId, 'create');

                        if (mounted) {
                          Navigator.pop(stfContext);
                          _refreshDorms();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${newDorm.dormName} added and synced!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add dorm: $e')),
                          );
                        }
                      }
                    } else {
                      // Show inline validation error
                      stfSetState(() {
                        validationError =
                            'Please fill all fields and pick a location.';
                      });
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

  // --- EDIT DORM DIALOG  ---
  Future<void> _showEditDormDialog(
      BuildContext context, Dorms dormToEdit) async {
    // Initialize controllers with existing data
    final TextEditingController nameController =
        TextEditingController(text: dormToEdit.dormName);
    final TextEditingController numberController =
        TextEditingController(text: dormToEdit.dormNumber);
    final TextEditingController locationController =
        TextEditingController(text: dormToEdit.dormLocation);
    final TextEditingController descriptionController =
        TextEditingController(text: dormToEdit.dormDescription);
    final TextEditingController latController = TextEditingController(
        text: dormToEdit.latitude?.toStringAsFixed(6) ?? '');
    final TextEditingController lngController = TextEditingController(
        text: dormToEdit.longitude?.toStringAsFixed(6) ?? '');

    // Local state for validation feedback
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
                'Edit Dormitory: ${dormToEdit.dormName}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: _appBarColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Fields (reusing existing helpers)
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
                    _buildStyledTextField(
                      controller: descriptionController,
                      label: 'Dorm Description/Details',
                      keyboardType: TextInputType.multiline,
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

                    // Location Picker Button (Same logic)
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

                    // Read-only coordinates display (Same logic)
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
                // CANCEL Button
                TextButton(
                  onPressed: () => Navigator.pop(stfContext),
                  child: const Text('CANCEL',
                      style: TextStyle(color: Colors.grey)),
                ),
                // UPDATE Button (Primary action)
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        latController.text.isNotEmpty &&
                        lngController.text.isNotEmpty) {
                      // 1. Create the updated Dorm object
                      final updatedDorm = Dorms(
                        dormId: dormToEdit.dormId, // KEEP the original ID!
                        dormName: nameController.text,
                        dormNumber: numberController.text.isEmpty
                            ? 'N/A'
                            : numberController.text,
                        dormDescription: descriptionController.text.isEmpty
                            ? 'No description provided.'
                            : descriptionController.text,
                        dormLocation: locationController.text,
                        latitude: double.tryParse(latController.text),
                        longitude: double.tryParse(lngController.text),
                        createdAt:
                            dormToEdit.createdAt, // Keep original creation date
                      );

                      try {
                        // 2. Update local SQLite DB (using your existing method)
                        await _dbHelper.updateDorm(updatedDorm);

                        // 3. Update the remote server (Action: 'update')
                        await _syncDormToServer(updatedDorm, 'update');

                        if (mounted) {
                          Navigator.pop(stfContext);
                          _refreshDorms();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${updatedDorm.dormName} updated locally and server synced!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          // Display error in the main app context
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to update dorm and sync server: $e')),
                          );
                        }
                      }
                    } else {
                      // Show inline validation error
                      stfSetState(() {
                        validationError =
                            'Please fill all fields and pick a location.';
                      });
                    }
                  },
                  child: const Text('UPDATE DORM',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue.shade700, // Distinct color for UPDATE
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
