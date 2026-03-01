// dorm_lists.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/features/dorms/domain/models/dorm_model.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/features/dorms/presentation/viewmodels/dorm_viewmodel.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/widgets/custom_text_field.dart';

// -------------------------------------------------------------------
// ## DORM LIST WIDGET
// -------------------------------------------------------------------

class DormList extends StatefulWidget {
  final String? initialSearchQuery;

  const DormList({
    super.key,
    this.initialSearchQuery,
  });

  @override
  State<DormList> createState() => _DormListState();
}

class _DormListState extends State<DormList> {
  // -------------------------------------------------------------------
  // ## FIELDS & STATE
  // -------------------------------------------------------------------

  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _selectedGenderFilter;
  String? _selectedPriceFilter;

  // -------------------------------------------------------------------
  // ## LIFECYCLE METHODS
  // -------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // ## DATA & FILTER LOGIC (Business Logic)
  // -------------------------------------------------------------------

  /// Navigates to the Dorm Detail Page and refreshes the list if favorites changed.
  void _navigateToDormPage(Dorms dorm) async {
    final bool? favoriteChanged =
        await context.push<bool>('/dorm-detail', extra: dorm);

    // If a favorite was toggled, run loadDorms to update the global state
    if (favoriteChanged == true && mounted) {
      context.read<DormViewModel>().loadDorms();
    }
  }

  /// Clears all active filters.
  void _clearFilters() {
    setState(() {
      _selectedGenderFilter = null;
      _selectedPriceFilter = null;
      _searchController.clear();
    });
  }

  // -------------------------------------------------------------------
  // ## WIDGET BUILDERS
  // -------------------------------------------------------------------

  /// Builds the small, colored chip for display inside a dorm card.
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

  /// Builds the horizontal scrollable row of filter chips (Gender and Price).
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
                  });
                },
                selectedColor: Colors.deepPurple,
                backgroundColor: DormCategories.getGenderColor(category),
                checkmarkColor: Colors.white,
              ),
            );
          }),

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
                  });
                },
                selectedColor: Colors.amber.shade700,
                backgroundColor: DormCategories.getPriceColor(category),
                checkmarkColor: Colors.white,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds an individual stylized dorm card for the list view.
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
                          color: Colors.amber.withValues(alpha: 0.2),
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

                  // Category Badges Row
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

  // -------------------------------------------------------------------
  // ## MAIN BUILD METHOD
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Determine if the 'Clear Filters' button should be shown
    final bool filtersActive =
        _selectedGenderFilter != null || _selectedPriceFilter != null;

    final dormVM = context.watch<DormViewModel>();
    List<Dorms> foundDorms = dormVM.allDorms;

    // Apply filters dynamically
    if (_searchController.text.isNotEmpty) {
      final keywordLower = _searchController.text.toLowerCase();
      foundDorms = foundDorms
          .where((dorm) =>
              dorm.dormName.toLowerCase().contains(keywordLower) ||
              dorm.dormLocation.toLowerCase().contains(keywordLower))
          .toList();
    }

    if (_selectedGenderFilter != null) {
      foundDorms = foundDorms
          .where((dorm) => dorm.genderCategory == _selectedGenderFilter)
          .toList();
    }

    if (_selectedPriceFilter != null) {
      foundDorms = foundDorms
          .where((dorm) => dorm.priceCategory == _selectedPriceFilter)
          .toList();
    }

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
            CustomTextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              hintText: 'Search by Name or Location',
              icon: Ionicons.search,
              iconColor: Colors.deepPurple,
              fillColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 15),

            // Filter Chips Row
            _buildFilterChips(),

            // Clear Filters Button (if any filter is active)
            if (filtersActive)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    icon: Icons.clear,
                    text: 'Clear Filters',
                    fontSize: 14,
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: Colors.transparent,
                    textColor: Colors.red.shade600,
                    elevation: 0,
                    border: BorderSide.none,
                    onPressed: _clearFilters,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // List View
            Expanded(
              child: dormVM.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber))
                  : foundDorms.isEmpty
                      ? Center(
                          child: Text(
                            (_searchController.text.isEmpty && !filtersActive)
                                ? 'No dormitories available.'
                                : 'No dormitories match your criteria.',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: foundDorms.length,
                          itemBuilder: (context, index) {
                            final dorm = foundDorms[index];
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
