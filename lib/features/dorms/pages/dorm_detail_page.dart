// dorm_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/features/maps/pages/maps_detail_page.dart';

// -------------------------------------------------------------------
// 1. Reusable Widget for Detail Rows
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
      // --------------------------------------------------------------
      // Map Button (Bottom Bar)
      // --------------------------------------------------------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
            16, 8, 16, 24), // Increased bottom padding
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
            backgroundColor:
                Colors.amber.shade700, // Use a consistent amber shade
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8, // Added subtle elevation
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
            backgroundColor: Colors.amber.shade700, // Consistent color

            // Favorite Button moved to AppBar actions
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Ionicons.heart : Ionicons.heart_outline,
                  color: _isFavorite ? Colors.red.shade400 : Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],

            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              centerTitle: false,
              // Dorm Name as the actual title (appears on scroll)
              title: Text(
                widget.dorm.dormName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lato',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/dorm.jpeg',
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay for text contrast
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------------
          // 3. Scrollable Details Section (Card Design)
          // ----------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: Colors
                  .grey.shade50, // Slight off-white background for the body
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- 1. Key Details CARD ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Key Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lato',
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Divider(height: 25, thickness: 1),
                            _DetailItem(
                              icon: Ionicons.location_outline,
                              label: 'Physical Location',
                              value: widget.dorm.dormLocation,
                            ),
                            _DetailItem(
                              icon: Ionicons.qr_code_outline,
                              label: 'Dorm ID/Number',
                              value: widget.dorm.dormNumber,
                            ),
                            _DetailItem(
                              icon: Ionicons.calendar_outline,
                              label: 'Listed On',
                              value: widget.dorm.createdAt.substring(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- 2. Description CARD (Dynamic Text) ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lato',
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Divider(height: 25, thickness: 1),
                            // DYNAMIC DESCRIPTION IMPLEMENTATION
                            Text(
                              // Use the dynamic description from the Dorms model
                              widget.dorm.dormDescription,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lato',
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 40), // Spacing above the bottom nav bar/button
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
