// dorm_lists.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';
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

  String? _selectedGenderFilter;
  String? _selectedPriceFilter;

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
    List<Dorms> results = _allDorms;

    // Text search filter
    if (enteredKeyword.isNotEmpty) {
      results = results
          .where((dorm) =>
              dorm.dormName
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              dorm.dormLocation
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Gender category filter
    if (_selectedGenderFilter != null) {
      results = results
          .where((dorm) => dorm.genderCategory == _selectedGenderFilter)
          .toList();
    }

    // Price category filter
    if (_selectedPriceFilter != null) {
      results = results
          .where((dorm) => dorm.priceCategory == _selectedPriceFilter)
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Gender Filter Chips
          ...DormCategories.genderCategories.map((category) {
            final isSelected = _selectedGenderFilter == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${DormCategories.getGenderIcon(category)} $category',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedGenderFilter = selected ? category : null;
                    _runFilter(_searchController.text);
                  });
                },
                selectedColor: Colors.deepPurple,
                backgroundColor: DormCategories.getGenderColor(category),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),

          const SizedBox(width: 8),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          const SizedBox(width: 8),

          // Price Filter Chips
          ...DormCategories.priceCategories.map((category) {
            final isSelected = _selectedPriceFilter == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${DormCategories.getPriceIcon(category)} $category',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriceFilter = selected ? category : null;
                    _runFilter(_searchController.text);
                  });
                },
                selectedColor: Colors.amber.shade700,
                backgroundColor: DormCategories.getPriceColor(category),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDormCard(Dorms dorm) {
    String getSnippet(String description) {
      const int maxLength = 100;
      if (description.length <= maxLength) return description;
      return '${description.substring(0, maxLength).trim()}...';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () => _navigateToDormPage(dorm),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
                dorm.dormImageAsset,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Ionicons.image_outline,
                            size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('Image not found',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Dorm Name and Number
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
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

                  // Row 2: Location
                  Row(
                    children: [
                      const Icon(Ionicons.location_outline,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          dorm.dormLocation,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // NEW: Category Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSmallCategoryChip(
                        dorm.genderCategory,
                        DormCategories.getGenderColor(dorm.genderCategory),
                        DormCategories.getGenderIcon(dorm.genderCategory),
                      ),
                      _buildSmallCategoryChip(
                        dorm.priceCategory,
                        DormCategories.getPriceColor(dorm.priceCategory),
                        DormCategories.getPriceIcon(dorm.priceCategory),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 3: Description Snippet
                  Text(
                    getSnippet(dorm.dormDescription),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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

// Category chip widget

  Widget _buildSmallCategoryChip(String category, Color color, String icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
      appBar: AppBar(
        title: Text(
          widget.initialSearchQuery != null
              ? 'Results for "${widget.initialSearchQuery}"'
              : 'All Dormitories List',
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Lato'),
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
            // Search Bar
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
            const SizedBox(height: 15),

            // Filter Chips Row
            _buildFilterChips(),

            // Clear Filters Button (if any filter is active)
            if (_selectedGenderFilter != null || _selectedPriceFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filters'),
                    onPressed: () {
                      setState(() {
                        _selectedGenderFilter = null;
                        _selectedPriceFilter = null;
                        _runFilter(_searchController.text);
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // List View
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber))
                  : _foundDorms.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty &&
                                    _selectedGenderFilter == null &&
                                    _selectedPriceFilter == null
                                ? 'No dormitories available.'
                                : 'No dormitories match your filters.',
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
