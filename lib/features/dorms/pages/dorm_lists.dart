// dorm_lists.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/dorms/pages/dorm_detail_page.dart';

class DormList extends StatefulWidget {
  const DormList({Key? key}) : super(key: key);

  @override
  _DormListState createState() => _DormListState();
}

class _DormListState extends State<DormList> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Dorms> _allDorms = [];
  List<Dorms> _foundDorms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshDorms();
  }

  void _refreshDorms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedDorms = await _dbHelper.getDorms();
      setState(() {
        _allDorms = fetchedDorms;
        _foundDorms = fetchedDorms;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading dorms: $e");
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

  // -------------------------------------------------------------------
  // ## UPDATED: Dorm Card Widget with Image Placeholder
  // -------------------------------------------------------------------

  Widget _buildDormCard(Dorms dorm) {
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
            // 1. IMAGE/HEADER SECTION (Using static Image.asset)
            // If dormImageUrl were available, you would use Image.network or Image.asset here.
            Container(
              height: 150, // Fixed height for the image area
              decoration: BoxDecoration(
                // Top corners match card shape
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: Colors.grey.shade300, // Placeholder background color
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Ionicons.image_outline,
                      size: 40,
                      color: Colors.grey,
                    ),
                    Text(
                      'Image Preview (Dorm #${dorm.dormNumber})',
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  ],
                ),
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
        title: const Text(
          'All Dormitories List',
          style: TextStyle(
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
                      ? const Center(
                          child: Text(
                            'No dormitories found.',
                            style: TextStyle(fontSize: 20, color: Colors.grey),
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
