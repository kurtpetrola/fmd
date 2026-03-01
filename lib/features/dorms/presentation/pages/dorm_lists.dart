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
import 'package:findmydorm/core/theme/app_colors.dart';

// ## DORM LIST WIDGET

/// Provides a comprehensive list view of all dormitories with categorizations.
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
  // ## FIELDS & STATE

  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _selectedGenderFilter;
  String? _selectedPriceFilter;

  // ## LIFECYCLE METHODS
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

  // ## DATA & FILTER LOGIC (Business Logic)

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

  // ## WIDGET BUILDERS

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
              color: AppColors.textPrimary,
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
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textPrimary,
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
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: DormCategories.getGenderColor(category),
                checkmarkColor: AppColors.textWhite,
              ),
            );
          }),

          const SizedBox(width: 8),
          Container(width: 1, height: 30, color: AppColors.grey300),
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
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textPrimary,
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
                selectedColor: AppColors.primaryAmber,
                backgroundColor: DormCategories.getPriceColor(category),
                checkmarkColor: AppColors.textWhite,
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
                    color: AppColors.grey300,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Ionicons.image_outline,
                            size: 40, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text('Image not found',
                            style: TextStyle(color: AppColors.textSecondary)),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#${dorm.dormNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
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
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          dorm.dormLocation,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
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
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
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

  // ## MAIN BUILD METHOD

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: AppColors.textWhite,
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
              iconColor: Theme.of(context).colorScheme.primary,
              fillColor: AppColors.grey200,
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
                    textColor: AppColors.error,
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
                      child: CircularProgressIndicator(
                          color: AppColors.primaryAmber))
                  : foundDorms.isEmpty
                      ? Center(
                          child: Text(
                            (_searchController.text.isEmpty && !filtersActive)
                                ? 'No dormitories available.'
                                : 'No dormitories match your criteria.',
                            style: const TextStyle(
                                fontSize: 20, color: AppColors.textSecondary),
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
