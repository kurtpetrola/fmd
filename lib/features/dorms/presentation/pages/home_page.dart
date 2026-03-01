// home_page.dart

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:findmydorm/features/dorms/domain/models/dorm_model.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/widgets/custom_text_field.dart';

/// The main dashboard displaying dorm categories and a search interface.
class HomePage extends StatefulWidget {
  final VoidCallback? onViewAllTap;

  const HomePage({super.key, this.onViewAllTap});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> with TickerProviderStateMixin {
  // STATE AND CONTROLLERS
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Storage for fetched dorm data
  List<Dorms> _allDorms = [];
  List<Dorms> _femaleDorms = [];
  List<Dorms> _maleDorms = [];
  List<Dorms> _mixedDorms = [];

  // LIFECYCLE METHODS
  @override
  void initState() {
    super.initState();
    // TabController length corresponds to DormCategories.genderCategories.length (3)
    _tabController = TabController(length: 3, vsync: this);
    _loadDorms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure data is fresh when the page becomes visible
    _loadDorms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // HELPER LOGIC (Getters/Functions)

  // HELPER GETTER: Combines unique dorm names and unique dorm locations
  List<String> get _searchOptions {
    final Set<String> options = {};

    // Add dorm names with a house emoji prefix (🏠)
    for (var dorm in _allDorms) {
      options.add('🏠 ${dorm.dormName}');
    }

    // Add unique dorm locations with a pin emoji prefix (📍)
    final uniqueLocations =
        _allDorms.map((d) => d.dormLocation).toSet().toList();
    for (var location in uniqueLocations) {
      options.add('📍 $location');
    }

    return options.toList();
  }

  // Data loading with error handling
  void _loadDorms() async {
    try {
      final fetchedDorms = await _dbHelper.getDorms();

      final femaleDorms = fetchedDorms
          .where((d) => d.genderCategory == DormCategories.genderCategories[0])
          .where((d) => d.isFeatured)
          .toList();

      final maleDorms = fetchedDorms
          .where((d) => d.genderCategory == DormCategories.genderCategories[1])
          .where((d) => d.isFeatured)
          .toList();

      final mixedDorms = fetchedDorms
          .where((d) => d.genderCategory == DormCategories.genderCategories[2])
          .where((d) => d.isFeatured)
          .toList();

      if (mounted) {
        setState(() {
          _allDorms = fetchedDorms;
          _femaleDorms = femaleDorms;
          _maleDorms = maleDorms;
          _mixedDorms = mixedDorms;
        });
      }
    } catch (e) {
      debugPrint('Error loading dorms: $e');
    }
  }

  // BUILD METHODS (UI Segments)

  Widget _buildHeaderSection() {
    return SizedBox(
      height: 370,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/images/dorm_default.png",
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacer to push content down from the very top
                const SizedBox(
                    height: 30), // Adjust this value to move title up/down

                // Title Section
                const Text(
                  "Discover Dorms Near You",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    fontFamily: 'Lato',
                  ),
                ),
                const SizedBox(height: 15),

                // === AUTOSUGGEST SEARCH BAR ===
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _searchOptions.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomTextField(
                        controller: textController,
                        focusNode: focusNode,
                        onFieldSubmitted: (value) => onFieldSubmitted(),
                        hintText: "Search for a dorm or location...",
                        icon: Icons.search,
                        iconColor: Colors.grey,
                        fillColor: Colors.white,
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 6.0,
                        borderRadius: BorderRadius.circular(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          height:
                              options.length > 5 ? 200 : options.length * 48.0,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(option,
                                    style: const TextStyle(fontFamily: 'Lato')),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (String selectionWithPrefix) {
                    final String selection = selectionWithPrefix.replaceAll(
                        RegExp(r'^(🏠 |📍 )'), '');
                    final bool isLocation =
                        selectionWithPrefix.startsWith('📍 ');

                    if (isLocation) {
                      context.push('/dorm-list', extra: selection);
                    } else {
                      final Dorms? selectedDorm = _allDorms
                          .firstWhereOrNull((d) => d.dormName == selection);

                      if (selectedDorm != null) {
                        context.push('/dorm-detail', extra: selectedDorm);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Dorm not found: "$selection"')),
                        );
                      }
                    }
                  },
                ),
                // === END OF AUTOSUGGEST SEARCH BAR ===

                const Spacer(), // Pushes tabs to the bottom

                // TabBar
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.amber.shade400,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 4.0, color: Colors.amber),
                    insets: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  tabs: DormCategories.genderCategories.map((category) {
                    return Tab(text: category);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Wraps TabBarView in Flexible to take up remaining screen space
  Widget _buildDormContent() {
    return Flexible(
      child: TabBarView(
        controller: _tabController,
        children: [
          DormListView(dorms: _femaleDorms, maxItems: 3),
          DormListView(dorms: _maleDorms, maxItems: 3),
          DormListView(dorms: _mixedDorms, maxItems: 3),
        ],
      ),
    );
  }

  // MAIN BUILD METHOD

  @override
  Widget build(BuildContext context) {
    if (_allDorms.isEmpty && mounted) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          _buildHeaderSection(),

          // Section Title for the List
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Featured Dorms Title with Refresh Badge (Admin Only)
                Row(
                  children: [
                    const Text(
                      "Featured Dorms",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                        color: Colors.black87,
                      ),
                    ),
                    // Subtle refresh badge for Admin
                    if (context.watch<AuthViewModel>().currentUser?.usrRole ==
                        'Admin') ...[
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          _loadDorms();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Refreshed!'),
                                ],
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: 150,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.amber.shade300, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh,
                                  size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Refresh',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // View All Button
                CustomButton(
                  text: 'View All',
                  fontSize: 14,
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: Colors.amber.shade50,
                  textColor: Colors.amber.shade700,
                  elevation: 0,
                  border: BorderSide(
                    color: Colors.amber.shade700,
                    width: 1.5,
                  ),
                  onPressed: () {
                    widget.onViewAllTap?.call();
                  },
                )
              ],
            ),
          ),

          _buildDormContent(),
        ],
      ),
    );
  }
}

// REUSABLE LIST WIDGETS

/// A reusable list view for displaying a collection of dormitories.
class DormListView extends StatelessWidget {
  final List<Dorms> dorms;
  final int maxItems; // Limit the number of items

  const DormListView({required this.dorms, this.maxItems = -1, super.key});

  @override
  Widget build(BuildContext context) {
    if (dorms.isEmpty) {
      return const Center(child: Text("No dorms available in this category."));
    }

    // Calculate the actual count to display
    final int displayCount =
        maxItems > 0 && dorms.length > maxItems ? maxItems : dorms.length;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      itemCount: displayCount, // LIMITED COUNT
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final Dorms dorm = dorms[index];

        String itemText = dorm.dormName;
        String subtitle = dorm.dormLocation;

        return GestureDetector(
          onTap: () {
            context.push('/dorm-detail', extra: dorm);
          },
          child: _DormCard(
            itemText: itemText,
            subtitle: subtitle,
            imageAsset: dorm.dormImageAsset,
          ),
        );
      },
    );
  }
}

/// A stylized card widget representing an individual dormitory.
class _DormCard extends StatelessWidget {
  final String itemText;
  final String subtitle;
  final String imageAsset; // image asset parameter

  const _DormCard(
      {required this.itemText,
      required this.subtitle,
      required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15, bottom: 20),
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imageAsset, // USE THE ACTUAL DORM IMAGE
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          ),
          const Positioned(
            top: 10,
            right: 10,
            child: Icon(Icons.info_outline, color: Colors.white, size: 30),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    itemText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Lato',
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
