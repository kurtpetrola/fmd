// dorms_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/features/maps/pages/maps_detail_page.dart';

// 1. Convert to a StatefulWidget to manage the favorite state
class DormDetailPage extends StatefulWidget {
  final Dorms dorm;

  const DormDetailPage(this.dorm, {super.key});

  @override
  State<DormDetailPage> createState() => _DormDetailPageState();
}

class _DormDetailPageState extends State<DormDetailPage> {
  // State variable to hold the favorite status
  bool _isFavorite = false;

  // FIX: Define dbHelper here, inside the state class, so all methods can use it
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Function to check initial favorite status from the database
  Future<void> _checkFavoriteStatus() async {
    final currentUser = AuthManager.currentUser;

    // FIX: Use currentUser.usrId, as confirmed by the Users model
    if (currentUser != null && currentUser.usrId != null) {
      final isFav = await dbHelper.isDormFavorite(
        currentUser.usrId!,
        widget.dorm.dormId!, // Use the actual INTEGER ID of the dorm
      );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  // Function to toggle the favorite status
  Future<void> _toggleFavorite() async {
    final currentUser = AuthManager.currentUser;

    // FIX: Ensure the user is logged in and has a usrId
    if (currentUser == null || currentUser.usrId == null) {
      _showSnackbar('Please log in to add favorites.', Colors.red);
      return;
    }

    try {
      if (_isFavorite) {
        // Remove from favorites
        await dbHelper.removeFavorite(
          currentUser.usrId!,
          widget.dorm.dormId!,
        );
        _showSnackbar(
            'Removed ${widget.dorm.dormName} from favorites.', Colors.orange);
      } else {
        // Add to favorites
        await dbHelper.addFavorite(
          currentUser.usrId!,
          widget.dorm.dormId!,
        );
        _showSnackbar(
            'Added ${widget.dorm.dormName} to favorites!', Colors.green);
      }
      // Update the state to change the icon immediately
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      _showSnackbar('Failed to update favorite status: $e', Colors.red);
    }
  }

  // Helper to show a simple Snackbar message
  void _showSnackbar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dorm.dormName),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _isFavorite ? Ionicons.heart : Ionicons.heart_outline,
              color: _isFavorite ? Colors.red : Colors.white,
              size: 28,
            ),
            onPressed: _toggleFavorite, // Call the toggle function
          ),
          const SizedBox(width: 10), // Spacing from the edge
        ],
      ),
      body: Column(
        children: <Widget>[
          // Image Section
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: Image.asset(
              'assets/images/dorm.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Details Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.dorm.dormName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Location Detail
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Location: ${widget.dorm.dormLocation}',
                        style:
                            const TextStyle(fontSize: 18, fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dorm Number Detail
                  Row(
                    children: [
                      const Icon(Icons.pin, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Dorm ID/Number: ${widget.dorm.dormNumber}',
                        style:
                            const TextStyle(fontSize: 18, fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Created At Detail
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Listed on: ${widget.dorm.createdAt.substring(0, 10)}',
                        style:
                            const TextStyle(fontSize: 18, fontFamily: 'Lato'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Placeholder for a longer description
                  const Text(
                    "This is a brief description of the dorm amenities, rules, and general information. It's a quiet place suitable for students looking for a focus environment near campus.",
                    style: TextStyle(
                        fontSize: 16, fontFamily: 'Lato', color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar (Map Button)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the MapsDetailPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapsDetailPage(
                      latitude: widget.dorm.latitude ??
                          51.5, // Use actual data or safe default
                      longitude: widget.dorm.longitude ??
                          -0.09, // Use actual data or safe default
                      dormName: widget.dorm.dormName,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                minimumSize: WidgetStateProperty.all<Size>(const Size(280, 60)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.amber, width: 2),
                  ),
                ),
              ),
              child: const Icon(
                Ionicons.map,
                size: 40,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
