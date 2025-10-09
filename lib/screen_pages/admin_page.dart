// admin_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/server/sqlite.dart';
// NOTE: If you need to navigate to DormDetailPage from this admin list,
// you must also import it here:
// import 'package:findmydorm/dorms_detail_page.dart';

class AdminPage extends StatefulWidget {
  // 1. Class name renamed from DormsPage to AdminPage
  const AdminPage({super.key});

  @override
  // 2. State class creation renamed
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // 3. State class name renamed from _DormsPageState to _AdminPageState

  // Use the Singleton instance of your DatabaseHelper
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Future to hold the asynchronous data fetch result
  late Future<List<Dorms>> _dormsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching data as soon as the widget is created
    _refreshDorms();
  }

  // Function to refresh the list by re-fetching data from the database
  void _refreshDorms() {
    setState(() {
      _dormsFuture = _dbHelper.getDorms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Updated AppBar title for better context
        title: const Text('Admin: Dormitory CRUD'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: () =>
                _showAddDormDialog(context), // Show the dialog to add a dorm
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _refreshDorms, // Refresh the list manually
          ),
        ],
      ),
      body: FutureBuilder<List<Dorms>>(
        future: _dormsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message (e.g., if database access fails)
            return Center(
                child: Text('Error loading dorms: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no dorms are available
            return const Center(
                child: Text('No local dormitories found. Click + to add one.'));
          } else {
            // Data loaded successfully, display the list
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
          // You can use this onTap to open an EDIT dialog or the detail page.
          // if you want to navigate to the DormDetailPage:
          // Navigator.push(context, MaterialPageRoute(builder: (context) => DormDetailPage(dorm)));
        },
      ),
    );
  }

  // Method to handle deletion of a dorm
  void _deleteDorm(Dorms dorm) async {
    if (dorm.dormId != null) {
      await _dbHelper.deleteDorm(dorm.dormId!);
      _refreshDorms(); // Refresh the list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${dorm.dormName} deleted successfully!')),
      );
    }
  }

  // --- Dialog to Add Dorm ---
  Future<void> _showAddDormDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Dorm'),
        content: Column(
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
                decoration: const InputDecoration(labelText: 'Location')),
            // Other fields (like image URL/description) are commented out as requested
          ],
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
                  locationController.text.isNotEmpty) {
                final newDorm = Dorms(
                  dormName: nameController.text,
                  dormNumber: numberController.text.isEmpty
                      ? 'N/A'
                      : numberController.text,
                  dormLocation: locationController.text,
                  // IMPORTANT: Must pass placeholders if your Dorms model requires them
                  // dormImageUrl: '',
                  // dormDescription: '',
                  createdAt: DateTime.now().toIso8601String(),
                );

                try {
                  // Insert the new dorm into the SQLite database
                  await _dbHelper.insertDorm(newDorm);

                  // Close the dialog and refresh the list
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
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
