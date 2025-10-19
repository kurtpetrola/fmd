// home_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/models/users.dart';
import 'package:findmydorm/services/sqlite.dart';
import 'package:findmydorm/features/dorms/pages/dorm_detail_page.dart';
import 'package:findmydorm/features/dorms/pages/dorm_lists.dart';
import 'package:collection/collection.dart';

class HomePage extends StatefulWidget {
  // 1. Required parameter for the currently logged-in user
  final Users currentUser;

  // 2. Required callback function to update the user state
  // (Used when settings or profile changes)
  final ValueChanged<Users> onUserUpdated;

  // 3. Keep the optional callback property
  final VoidCallback? onViewAllTap;

  const HomePage(
      {super.key,
      required this.currentUser,
      required this.onUserUpdated,
      this.onViewAllTap});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Storage for fetched dorm data
  List<Dorms> _allDorms = [];
  List<Dorms> _femaleDorms = [];
  List<Dorms> _maleDorms = [];
  List<Dorms> _otherDorms = [];

  // Helper getter for the Autocomplete search feature (list of names only)
  List<String> get _dormNames => _allDorms.map((d) => d.dormName).toList();

  @override
  void initState() {
    super.initState();
    // Length is now 3 for Female, Male, and Other
    _tabController = TabController(length: 3, vsync: this);
    _loadDorms();
  }

  void _loadDorms() async {
    final fetchedDorms = await _dbHelper.getDorms();

    // Filtering logic to split into 3 categories
    // This uses the modulo operator (%) to roughly distribute dorms across the three lists
    // based on their dormId (1, 2, 3, 4, 5, 6, ... -> Group 1, 2, 0, 1, 2, 0, ...)
    final femaleDorms =
        fetchedDorms.where((d) => (d.dormId ?? 0) % 3 == 1).toList();
    final maleDorms =
        fetchedDorms.where((d) => (d.dormId ?? 1) % 3 == 2).toList();
    final otherDorms =
        fetchedDorms.where((d) => (d.dormId ?? 2) % 3 == 0).toList();

    setState(() {
      _allDorms = fetchedDorms;
      _femaleDorms = femaleDorms;
      _maleDorms = maleDorms;
      _otherDorms = otherDorms;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHeaderSection() {
    return SizedBox(
      height: 370,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/images/dorm.jpeg",
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

                // Title Section (Moved up, now more centrally aligned vertically)
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
                    return _dormNames.where((String option) {
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: textController,
                        focusNode: focusNode,
                        onSubmitted: (value) => onFieldSubmitted(),
                        style: const TextStyle(
                            color: Colors.black, fontFamily: 'Lato'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal:
                                  8), // Vertical padding for center alignment
                          hintText: "Search for a dorm...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontFamily: 'Lato',
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                        ),
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
                  // onSelected logic
                  onSelected: (String selectionWithPrefix) {
                    // 1. Clean the selection string (remove prefix)
                    final String selection = selectionWithPrefix.replaceAll(
                        RegExp(r'^(🏠 |📍 )'), '');
                    final bool isLocation =
                        selectionWithPrefix.startsWith('📍 ');

                    // 2. Decide the action based on the prefix/type
                    if (isLocation) {
                      // Case A: LOCATION SEARCH (Navigate to DormList and pass the query)
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DormList(
                          initialSearchQuery: selection,
                        ),
                      ));
                    } else {
                      // Case B: DORM NAME SEARCH (Navigate to Detail Page)
                      // This uses your original simple logic.

                      // Find the exact dorm object corresponding to the name
                      final Dorms? selectedDorm = _allDorms
                          .firstWhereOrNull((d) => d.dormName == selection);

                      if (selectedDorm != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DormDetailPage(selectedDorm),
                        ));
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
                  labelColor: Colors.amber.shade400, // Bright Amber
                  unselectedLabelColor: Colors.white, // White for unselected
                  labelStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                  // *** REPLACED CircleTabIndicator with UnderlineTabIndicator ***
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 4.0, // Thickness of the rectangle/underline
                      color: Colors.amber, // Color of the indicator
                    ),
                    insets: EdgeInsets.symmetric(
                        horizontal: 16.0), // Padding on sides
                  ),
                  tabs: const [
                    Tab(text: "Female Dorms"),
                    Tab(text: "Male Dorms"),
                    Tab(text: "Other Dorms"), // 🟢 NEW Tab
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Now wrapped in Flexible to take up remaining screen space
  Widget _buildDormContent() {
    return Flexible(
      child: TabBarView(
        controller: _tabController,
        children: [
          // ADDED maxItems: 3
          DormListView(dorms: _femaleDorms, maxItems: 3),
          DormListView(dorms: _maleDorms, maxItems: 3),
          DormListView(dorms: _otherDorms, maxItems: 3), // TabView Content
        ],
      ),
    );
  }

  // --- Main Build Method ---
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
                const Text(
                  "Featured Dorms",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                    color: Colors.black87,
                  ),
                ),

                // *** UPDATED: TextButton with Subtle Shade/Background Color ***
                TextButton(
                  style: TextButton.styleFrom(
                    // Added a very light amber shade for the background
                    backgroundColor: Colors.amber.shade50, // Lightest amber

                    foregroundColor: Colors.amber.shade700,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    side: BorderSide(
                      color: Colors.amber.shade700,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () {
                    widget.onViewAllTap?.call();
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
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

// Reusable Dorm List View
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
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DormDetailPage(dorm),
            ));
          },
          child: _DormCard(itemText: itemText, subtitle: subtitle),
        );
      },
    );
  }
}

// Extracted Card Widget (Remains the same)
class _DormCard extends StatelessWidget {
  final String itemText;
  final String subtitle;

  const _DormCard({required this.itemText, required this.subtitle});

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
            color: Colors.grey.withOpacity(0.3),
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
                "assets/images/dorm.jpeg",
                fit: BoxFit.cover,
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
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
