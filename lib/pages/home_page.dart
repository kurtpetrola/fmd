//home_page.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/models/dorms.dart'; // Dorms Model
import 'package:findmydorm/services/sqlite.dart'; // DatabaseHelper
import 'package:findmydorm/features/dorms/pages/dorm_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 1. Storage for fetched dorm data
  List<Dorms> _allDorms = [];
  List<Dorms> _femaleDorms = [];
  List<Dorms> _maleDorms = [];

  // Helper getter for the Autocomplete search feature (list of names only)
  List<String> get _dormNames => _allDorms.map((d) => d.dormName).toList();

  // --- Initialization and Data Loading ---
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDorms();
  }

  // Fetches data from SQLite and populates the lists
  void _loadDorms() async {
    final fetchedDorms = await _dbHelper.getDorms();

    // Placeholder Logic: For real use, you should filter based on a
    // 'gender' or 'category' field in your Dorms model.
    // Here, we split based on the index/ID just to demonstrate the flow.
    final femaleDorms =
        fetchedDorms.where((d) => (d.dormId ?? 0).isEven).toList();
    final maleDorms = fetchedDorms.where((d) => (d.dormId ?? 1).isOdd).toList();

    setState(() {
      _allDorms = fetchedDorms;
      _femaleDorms = femaleDorms;
      _maleDorms = maleDorms;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Helper Methods to improve build() readability ---

  Widget _buildHeaderSection() {
    return Expanded(
      flex: 4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.brown.shade100,
          ),
          // Background Image (semi-transparent)
          Opacity(
            opacity: 0.5,
            child: Image.asset("assets/images/dorm.jpeg", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // === AUTOSUGGEST SEARCH BAR (Updated) ===
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    // Filter logic uses the dynamically loaded dorm names
                    return _dormNames.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },

                  // Style the Text Field (No changes needed)
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white24,
                      ),
                      child: TextField(
                        controller: textController,
                        focusNode: focusNode,
                        onSubmitted: (value) => onFieldSubmitted(),
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Lato'),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                          hintText: "Search for a dorm...",
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Lato',
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },

                  // Style the Floating Suggestions Pop-up (No changes needed)
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

                  // 2. FIX: Action when a dorm is selected from the list
                  onSelected: (String selection) {
                    // Find the full Dorms object from the list
                    final Dorms? selectedDorm = _allDorms.firstWhere(
                      (dorm) => dorm.dormName == selection,
                      orElse: () => _allDorms
                          .first, // Fallback, though ideally null check is better
                    );

                    // Navigate using the full Dorms object
                    if (selectedDorm != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DormDetailPage(selectedDorm),
                      ));
                    }
                  },
                ),
                // === END OF AUTOSUGGEST SEARCH BAR ===

                const SizedBox(height: 24),

                // Title Section (No changes needed)
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Discover Dorms Near You",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Divider and TabBar (No changes needed)
                const Divider(color: Colors.white, thickness: 2),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                  indicator: CircleTabIndicator(
                    color: Colors.amber,
                    radius: 5,
                  ),
                  tabs: const [
                    Tab(text: "Female Dorms"),
                    Tab(text: "Male Dorms"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDormContent() {
    // 3. FIX: Pass the actual Dorms lists to the DormListView
    return Container(
      padding: const EdgeInsets.only(left: 20),
      height: 320,
      width: double.maxFinite,
      child: TabBarView(
        controller: _tabController,
        children: [
          // Pass the filtered list of Dorms objects
          DormListView(dorms: _femaleDorms),
          DormListView(dorms: _maleDorms),
        ],
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Show a loading screen if the data hasn't been fetched yet
    if (_allDorms.isEmpty && mounted) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeaderSection(),
            _buildDormContent(),
          ],
        ),
      ),
    );
  }
}

// 4. FIX: Reusable Dorm List View (Updated to use Dorms objects)
class DormListView extends StatelessWidget {
  final List<Dorms> dorms; // Changed type to List<Dorms>

  const DormListView({required this.dorms, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handles case where a list (e.g., male dorms) is empty
    if (dorms.isEmpty) {
      return const Center(child: Text("No dorms available in this category."));
    }

    return ListView.builder(
      itemCount: dorms.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final Dorms dorm = dorms[index]; // Get the full Dorms object

        // Use real data fields for the card display
        String itemText = dorm.dormName;
        String subtitle = dorm.dormLocation;

        return GestureDetector(
          onTap: () {
            // FIX: Pass the full 'dorm' object to the detail page
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
      margin: const EdgeInsets.only(
        right: 15,
        top: 30,
        bottom: 30,
      ),
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        image: const DecorationImage(
          image: AssetImage("assets/images/dorm.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(),
              Icon(Icons.info_outline, color: Colors.white, size: 30),
            ],
          ),
          const Spacer(),
          Text(
            itemText,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: Colors.white),
          ),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 15, fontFamily: 'Lato', color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// CircleTabIndicator (Remains the same)
class CircleTabIndicator extends Decoration {
  final Color color;
  final double radius;

  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final Color color;
  final double radius;

  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    final Offset circleOffset = offset +
        Offset(configuration.size!.width / 2,
            configuration.size!.height - radius - 4);

    canvas.drawCircle(circleOffset, radius, paint);
  }
}
