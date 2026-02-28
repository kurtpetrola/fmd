// dorm_detail_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:findmydorm/domain/models/dorm_model.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';
import 'package:findmydorm/data/local/database_helper.dart';
import 'package:findmydorm/data/services/auth_manager.dart';
import 'package:go_router/go_router.dart';

// -------------------------------------------------------------------
// ## REUSABLE WIDGET: _DetailItem
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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Aesthetic Icon Container
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
// ## MAIN WIDGET: DormDetailPage
// -------------------------------------------------------------------

class DormDetailPage extends StatefulWidget {
  final Dorms dorm;

  // Callback property to notify the parent list a change occurred (e.g., in favorites)
  final VoidCallback? onFavoriteToggled;

  const DormDetailPage(this.dorm, {super.key, this.onFavoriteToggled});

  @override
  State<DormDetailPage> createState() => _DormDetailPageState();
}

class _DormDetailPageState extends State<DormDetailPage> {
  // --- FIELDS & DB HELPER ---
  final dbHelper = DatabaseHelper.instance;
  bool _isFavorite = false;
  bool _favoriteStatusChanged = false; // Flag to track if the status changed
  bool _isDescriptionExpanded = false; // State for expanding the description

  // -------------------------------------------------------------------
  // ## LIFECYCLE METHODS
  // -------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Custom back button handler to pass the status change back to the parent.
  void _onBackPressed() {
    context.pop(_favoriteStatusChanged);
  }

  // -------------------------------------------------------------------
  // ## DATA/STATE LOGIC
  // -------------------------------------------------------------------

  /// Checks the initial favorite status of the dorm for the current user.
  Future<void> _checkFavoriteStatus() async {
    final currentUser = AuthManager.currentUser;
    if (currentUser != null && currentUser.usrId != null) {
      final isFav = await dbHelper.isDormFavorite(
        currentUser.usrId!,
        widget.dorm.dormId!,
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  /// Adds or removes the dorm from the user's favorites.
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

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _favoriteStatusChanged = true;
        });
      }
    } catch (e) {
      _showSnackbar('Failed to update favorite status: $e', Colors.red);
    }
  }

  /// Toggles the expansion state of the description text.
  void _toggleDescriptionExpansion() {
    setState(() {
      _isDescriptionExpanded = !_isDescriptionExpanded;
    });
  }

  // -------------------------------------------------------------------
  // ## NAVIGATION HANDLERS
  // -------------------------------------------------------------------

  /// Handles Geocoding for the user's address and navigates to the map route.
  Future<void> _navigateToMapRoute() async {
    final currentUser = AuthManager.currentUser;
    final dormLat = widget.dorm.latitude;
    final dormLng = widget.dorm.longitude;

    if (currentUser == null || currentUser.usrAddress.isEmpty) {
      _showSnackbar(
          'Please log in or update your profile with an address to view the route.',
          Colors.red);
      return;
    }
    if (dormLat == null || dormLng == null) {
      _showSnackbar('Dormitory location data is missing.', Colors.red);
      return;
    }

    _showSnackbar('Calculating shortest route...', Colors.blue);

    // Default values if geocoding fails (dorm location)
    double userLat = dormLat;
    double userLng = dormLng;

    try {
      // 1. Geocoding: Convert the user's address string to coordinates
      List<Location> locations =
          await locationFromAddress(currentUser.usrAddress);

      if (locations.isNotEmpty) {
        userLat = locations.first.latitude;
        userLng = locations.first.longitude;
        debugPrint('User Geocoded Location: Lat $userLat, Lng $userLng');
      } else {
        // Fallback: Show dorm location only if user address is invalid
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar(
            'Could not accurately locate your address. Showing dorm location only.',
            Colors.orange);
      }

      // 2. Navigate to MapsDetailPage
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.push(
          '/maps-detail',
          extra: {
            'latitude': dormLat,
            'longitude': dormLng,
            'dormName': widget.dorm.dormName,
            'userLatitude': userLat,
            'userLongitude': userLng,
          },
        );
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackbar(
          'Failed to get your location for routing. Showing dorm location only.',
          Colors.orange);
    }
  }

  // -------------------------------------------------------------------
  // ## UTILITY METHODS
  // -------------------------------------------------------------------

  /// Displays a SnackBar with a custom message and color.
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

  // -------------------------------------------------------------------
  // ## WIDGET BUILDER METHODS
  // -------------------------------------------------------------------

  /// Builds the stylized category chip (e.g., 'Male', 'Affordable').
  Widget _buildCategoryChip(String category, Color color, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --------------------------------------------------------------
      // Map Button (Bottom Bar)
      // --------------------------------------------------------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: ElevatedButton.icon(
          onPressed: _navigateToMapRoute,
          icon: const Icon(Ionicons.map, size: 28),
          label: const Text(
            'View Route to Dorm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
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
            backgroundColor: Colors.amber.shade700,

            // Leading: Custom back button to pass the status change
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _onBackPressed, // Use the dedicated handler
            ),

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
              titlePadding:
                  const EdgeInsets.only(left: 48, bottom: 16, right: 16),
              centerTitle: false,
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
                  // Dorm Image Asset
                  Image.asset(
                    widget.dorm.dormImageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay
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
          // Scrollable Details Section (Body)
          // ----------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey.shade50,
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

                    // --- 2. Categories CARD ---
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
                              "Categories",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lato',
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Divider(height: 25, thickness: 1),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildCategoryChip(
                                  widget.dorm.genderCategory,
                                  DormCategories.getGenderColor(
                                      widget.dorm.genderCategory),
                                  DormCategories.getGenderIcon(
                                      widget.dorm.genderCategory),
                                ),
                                _buildCategoryChip(
                                  widget.dorm.priceCategory,
                                  DormCategories.getPriceColor(
                                      widget.dorm.priceCategory),
                                  DormCategories.getPriceIcon(
                                      widget.dorm.priceCategory),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- 3. Description CARD (Dynamic Text) ---
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
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
                            Text(
                              widget.dorm.dormDescription,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lato',
                                height: 1.6,
                                color: Colors.black87,
                              ),
                              // Limit lines based on expansion state
                              maxLines: _isDescriptionExpanded ? null : 6,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            // Read More / Read Less button
                            if (widget.dorm.dormDescription.length > 250)
                              GestureDetector(
                                onTap: _toggleDescriptionExpansion,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _isDescriptionExpanded
                                        ? 'Read Less'
                                        : 'Read More',
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
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
