// favorite_dorms_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/dorms/pages/dorm_detail_page.dart';

class FavoriteDormsPage extends StatefulWidget {
  final Users currentUser;

  const FavoriteDormsPage({super.key, required this.currentUser});

  @override
  State<FavoriteDormsPage> createState() => _FavoriteDormsPageState();
}

class _FavoriteDormsPageState extends State<FavoriteDormsPage> {
  final DatabaseHelper handler = DatabaseHelper.instance;
  List<Dorms> _favoriteDorms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteDorms();
  }

  // Function to fetch the list of favorite dorms
  Future<void> _fetchFavoriteDorms() async {
    if (!mounted || widget.currentUser.usrId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final favorites =
          await handler.getFavoriteDorms(widget.currentUser.usrId!);

      if (mounted) {
        setState(() {
          _favoriteDorms = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching favorite dorms: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to navigate to the DormDetailPage
  void _openDormDetail(Dorms dorm) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => DormDetailPage(dorm),
      ),
    )
        .then((_) {
      // Refresh the list when returning
      _fetchFavoriteDorms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorite Dorms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        // Set a consistent color scheme
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white, // For the back button and text color
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildFavoriteDormsList(),
    );
  }

  // Widget to handle loading, empty state, and the list itself
  Widget _buildFavoriteDormsList() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.amber));
    }

    if (_favoriteDorms.isEmpty) {
      // Improved Empty State UI
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.heart_dislike_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                "Your favorites list is empty.\nTap the ♡ on any dorm to add it here!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ],
        ),
      );
    }

    // List View Builder for efficient display
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favoriteDorms.length,
      itemBuilder: (context, index) {
        final dorm = _favoriteDorms[index];
        return _FavoriteDormCard(
          dorm: dorm,
          onTap: () => _openDormDetail(dorm),
        );
      },
    );
  }
}

// ------------------------------------------------------------------
// --- NEW WIDGET: Reusable Card for Favorite Dorms (Card with Image) ---
// ------------------------------------------------------------------

class _FavoriteDormCard extends StatelessWidget {
  final Dorms dorm;
  final VoidCallback onTap;

  const _FavoriteDormCard({
    required this.dorm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a Card for a better elevated appearance
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 100, // Fixed height for the card
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              // 1. Image Preview - NOW USES ACTUAL DORM IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  dorm.dormImageAsset, // USE THE ACTUAL DORM IMAGE
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image fails to load
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 30),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),

              // 2. Dorm Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      dorm.dormName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Lato',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Ionicons.location_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dorm.dormLocation,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Lato',
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Trailing Heart Icon (Red Heart to confirm it's a favorite)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(Ionicons.heart,
                      size: 24, color: Colors.red.shade400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
