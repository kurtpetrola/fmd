// screen_pages/favorite_dorms_page.dart (Create this new file)

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/server/sqlite.dart';
import 'package:findmydorm/dorms_directory/dorm_detail_page.dart';

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
    // If the page is not mounted or the user ID is null, stop.
    if (!mounted || widget.currentUser.usrId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final favorites =
          await handler.getFavoriteDorms(widget.currentUser.usrId!);

      // Update the state to display the fetched data
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
    // The await allows us to refresh the list when we return,
    // in case the user removed the dorm from favorites on the detail page.
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => DormDetailPage(dorm),
      ),
    )
        .then((_) {
      // Refresh the list when returning to this page
      _fetchFavoriteDorms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.amber,
        centerTitle: true,
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            "You have no favorite dorms yet.\nTap the ♡ icon on any dorm to add it!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // List View Builder for efficient display
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _favoriteDorms.length,
      itemBuilder: (context, index) {
        final dorm = _favoriteDorms[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: GestureDetector(
            onTap: () => _openDormDetail(dorm), // Navigate to detail page
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Ionicons.heart, color: Colors.red),
                title: Text(
                  dorm.dormName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Lato'),
                ),
                subtitle: Text(
                  dorm.dormLocation,
                  style:
                      const TextStyle(fontFamily: 'Lato', color: Colors.grey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }
}
