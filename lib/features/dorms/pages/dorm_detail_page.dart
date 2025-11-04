// dorm_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/services/auth_manager.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';
import 'package:findmydorm/features/maps/pages/maps_detail_page.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

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
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Increased padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Aesthetic Icon Container
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50, // Light background for the icon
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, color: Colors.deepPurple, size: 26), // Larger icon
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
                    // Slightly more distinct label color
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18, // Increased size for dynamic value
                    fontWeight: FontWeight.bold, // Bolder for high hierarchy
                    color: Colors.black, // Stark color for readability
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
  // State for expanding the description
  bool _isDescriptionExpanded = false;
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

  // Toggle method
  void _toggleDescriptionExpansion() {
    setState(() {
      _isDescriptionExpanded = !_isDescriptionExpanded;
    });
  }

  // Handles Geocoding and Navigation
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

    // Default values if geocoding fails (we still need them for the MapsDetailPage)
    double userLat = dormLat;
    double userLng = dormLng;

    try {
      // 1. Geocoding: Convert the user's address string to coordinates
      List<Location> locations =
          await locationFromAddress(currentUser.usrAddress);

      if (locations.isNotEmpty) {
        userLat = locations.first.latitude;
        userLng = locations.first.longitude;

        // Print for debug. Check your console!
        print('User Geocoded Location: Lat $userLat, Lng $userLng');

        // 3. Navigate to MapsDetailPage, passing the Directions URL
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapsDetailPage(
                latitude: dormLat,
                longitude: dormLng,
                dormName: widget.dorm.dormName,
                userLatitude: userLat,
                userLongitude: userLng,
              ),
            ),
          );
        }
      } else {
        // Fallback: Show dorm location only if user address is invalid
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar(
            'Could not accurately locate your address. Showing dorm location only.',
            Colors.orange);
      }
    } catch (e) {
      // Handle network or permission errors for geocoding
      print("Geocoding error: $e");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackbar(
          'Failed to get your location for routing. Showing dorm location only.',
          Colors.orange);
    }
  }

  Widget _buildCategoryChip(String category, Color color, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
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
          // Call the new asynchronous method
          onPressed: _navigateToMapRoute,
          icon: const Icon(Ionicons.map, size: 28),
          label: const Text(
            'View Route to Dorm', // Updated button text for clarity
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

            // Add leading property to control back button
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
              // Adjust padding to account for back button
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
                      elevation:
                          2, // Reduced elevation for a modern, lighter look
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1), // Crisp border
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
                            // DYNAMIC DESCRIPTION IMPLEMENTATION
                            Text(
                              widget.dorm.dormDescription,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Lato',
                                height:
                                    1.6, // Increased line height for better readability
                                color: Colors
                                    .black87, // Slightly softer than pure black
                              ),
                              // Limit lines based on expansion state
                              maxLines: _isDescriptionExpanded ? null : 6,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            // Read More / Read Less button
                            if (widget.dorm.dormDescription.length >
                                250) // Only show if long enough
                              GestureDetector(
                                onTap: _toggleDescriptionExpansion,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _isDescriptionExpanded
                                        ? 'Read Less'
                                        : 'Read More',
                                    style: const TextStyle(
                                      color: Colors
                                          .deepPurple, // Use a primary accent color
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
