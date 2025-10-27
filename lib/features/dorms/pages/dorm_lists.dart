// dorm_lists.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/dorms/pages/dorm_detail_page.dart';

class DormList extends StatefulWidget {
  // Only keep initialSearchQuery, as the filtering is done inside this page.
  final String? initialSearchQuery;

  const DormList({
    Key? key,
    this.initialSearchQuery,
  }) : super(key: key);

  @override
  _DormListState createState() => _DormListState();
}

class _DormListState extends State<DormList> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Dorms> _allDorms = [];
  List<Dorms> _foundDorms = [];
  bool _isLoading = true;
  // Controller for the search field to set initial value
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDormsAndFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDormsAndFilter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedDorms = await _dbHelper.getDorms();
      _allDorms = fetchedDorms;

      if (widget.initialSearchQuery != null &&
          widget.initialSearchQuery!.isNotEmpty) {
        _searchController.text = widget.initialSearchQuery!;
        _runFilter(widget.initialSearchQuery!);
      } else {
        _foundDorms = fetchedDorms;
      }
    } catch (e) {
      print("Error loading dorms: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Dorms> results;
    if (enteredKeyword.isEmpty) {
      results = _allDorms;
    } else {
      results = _allDorms
          .where((dorm) =>
              dorm.dormName
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              dorm.dormLocation
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundDorms = results;
    });
  }

  void _navigateToDormPage(Dorms dorm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DormDetailPage(dorm),
      ),
    );
  }

  Widget _buildDormCard(Dorms dorm) {
    // Helper function to truncate the description
    String getSnippet(String description) {
      const int maxLength = 100; // Max characters for the snippet
      if (description.length <= maxLength) {
        return description;
      }
      return '${description.substring(0, maxLength).trim()}...';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () => _navigateToDormPage(dorm),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE/HEADER SECTION - FIXED TO DISPLAY ACTUAL IMAGES
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                dorm.dormImageAsset,
                height: 180, // Fixed height for consistency
                width: double.infinity,
                fit: BoxFit
                    .cover, // This ensures the image fills the space properly
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Ionicons.image_outline,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 2. DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Row 1: Dorm Name and Number ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dorm.dormName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Highlight Dorm Number
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber
                              .withOpacity(0.2), // Light amber background
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#${dorm.dormNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- Row 2: Location ---
                  Row(
                    children: [
                      const Icon(Ionicons.location_outline,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          dorm.dormLocation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Added spacing

                  // Row 3: Description Snippet
                  Text(
                    getSnippet(dorm.dormDescription),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialSearchQuery != null
              ? 'Results for "${widget.initialSearchQuery}"'
              : 'All Dormitories List',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            // 1. IMPROVED SEARCH BAR STYLE
            TextField(
              controller: _searchController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                hintText: 'Search by Name or Location',
                prefixIcon:
                    const Icon(Ionicons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 20.0),
              ),
            ),
            const SizedBox(height: 20),

            // 2. LIST VIEW
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber))
                  : _foundDorms.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'No dormitories available.'
                                : 'No dormitories found for this search.',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _foundDorms.length,
                          itemBuilder: (context, index) {
                            final dorm = _foundDorms[index];
                            return _buildDormCard(dorm);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
