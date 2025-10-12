// dorm_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/features/maps/pages/maps_detail_page.dart';

// -------------------------------------------------------------------
// 1. Reusable Widget for Detail Rows (Retained improved typography)
// -------------------------------------------------------------------

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Retained spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2. DormDetailPage (The Main Widget)
// -------------------------------------------------------------------

class DormDetailPage extends StatefulWidget {
  final Dorms dorm;

  const DormDetailPage(this.dorm, {super.key});

  @override
  State<DormDetailPage> createState() => _DormDetailPageState();
}

class _DormDetailPageState extends State<DormDetailPage> {
  bool _isFavorite = false;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final currentUser = AuthManager.currentUser;
    if (currentUser != null && currentUser.usrId != null) {
      final isFav = await dbHelper.isDormFavorite(
        currentUser.usrId!,
        widget.dorm.dormId!,
      );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final currentUser = AuthManager.currentUser;
    if (currentUser == null || currentUser.usrId == null) {
      _showSnackbar('Please log in to add favorites.', Colors.red);
      return;
    }

    try {
      if (_isFavorite) {
        await dbHelper.removeFavorite(currentUser.usrId!, widget.dorm.dormId!);
        _showSnackbar(
            'Removed ${widget.dorm.dormName} from favorites.', Colors.orange);
      } else {
        await dbHelper.addFavorite(currentUser.usrId!, widget.dorm.dormId!);
        _showSnackbar(
            'Added ${widget.dorm.dormName} to favorites!', Colors.green);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      _showSnackbar('Failed to update favorite status: $e', Colors.red);
    }
  }

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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapsDetailPage(
                  latitude: widget.dorm.latitude ?? 51.5,
                  longitude: widget.dorm.longitude ?? -0.09,
                  dormName: widget.dorm.dormName,
                ),
              ),
            );
          },
          icon: const Icon(Ionicons.map, size: 28),
          label: const Text(
            'View on Map',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      // --------------------------------------------------------------
      // CustomScrollView with SliverAppBar (Header)
      // --------------------------------------------------------------
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.35,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.amber,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              centerTitle: false,
              title: const SizedBox.shrink(),
              background: Image.asset(
                'assets/images/dorm.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ----------------------------------------------------------
          // 3. Scrollable Details Section (Reverted to plain box adapter)
          // ----------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              // REMOVED: BoxDecoration, BorderRadius, and BoxShadow
              color: Colors
                  .white, // Explicitly set background color for the details
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- Dorm Name and Favorite Button (Retained updated typography/size) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.dorm.dormName,
                            style: const TextStyle(
                              fontSize: 32, // Retained size
                              fontWeight: FontWeight.w800, // Retained weight
                              color: Colors.deepPurple,
                              fontFamily: 'Lato',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // The Favorite Button (Retained size)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: IconButton(
                            icon: Icon(
                              _isFavorite
                                  ? Ionicons.heart
                                  : Ionicons.heart_outline,
                              color: _isFavorite
                                  ? Colors.red
                                  : Colors.grey.shade400,
                              size: 36, // Retained size
                            ),
                            onPressed: _toggleFavorite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25), // Retained spacing

                    // --- Dormitory Details Header (Retained updated typography) ---
                    const Text(
                      "Dormitory Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const Divider(
                        height: 25, thickness: 1), // Retained divider style

                    // --- Key Details (using updated _DetailItem) ---
                    _DetailItem(
                      icon: Icons.location_on,
                      label: 'Physical Location',
                      value: widget.dorm.dormLocation,
                    ),
                    _DetailItem(
                      icon: Icons.tag,
                      label: 'Dorm ID/Number',
                      value: widget.dorm.dormNumber,
                    ),
                    _DetailItem(
                      icon: Icons.calendar_today,
                      label: 'Listed On',
                      value: widget.dorm.createdAt.substring(0, 10),
                    ),

                    const SizedBox(height: 35),

                    // --- Description Section (Retained updated typography) ---
                    const Text(
                      "Description:",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "This is a brief description of the dorm amenities, rules, and general information. It's a quiet place suitable for students looking for a focus environment near campus. Future features will include a dynamic description from your database.",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lato',
                          height: 1.5,
                          color: Colors.black54),
                    ),

                    const SizedBox(height: 50),
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
