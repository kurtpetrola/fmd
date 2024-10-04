import 'package:flutter/material.dart';
import '../dorms_directory/dorm_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.brown.shade100,
                      ),
                      Opacity(
                        opacity: 0.5,
                        child: Image.asset("assets/images/dorm.jpeg",
                            fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20, // 40
                              // child: TextFormField(
                              //   decoration: InputDecoration(
                              //     contentPadding: EdgeInsets.all(0),
                              //     hintText: "Search",
                              //     hintStyle: TextStyle(
                              //       color: Colors.white,
                              //       fontSize: 16,
                              //       fontFamily: 'Lato',
                              //     ),
                              //     border: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(10.0),
                              //       borderSide: BorderSide.none,
                              //     ),
                              //     prefixIcon: Icon(
                              //       Icons.search,
                              //       color: Colors.white,
                              //     ),
                              //     filled: true,
                              //     fillColor: Colors.white24,
                              //   ),
                              // ),
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Discover Dorms Near You",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50,
                                      fontFamily: 'Lato',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Divider(color: Colors.white, thickness: 2),
                            Container(
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white60,
                                labelStyle: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Lato',
                                ),
                                indicator: CircleTabIndicator(
                                  // Use your custom indicator here
                                  color: Colors.amber,
                                  radius: 5,
                                ),
                                tabs: [
                                  Tab(text: "Female Dorms"),
                                  Tab(text: "Male Dorms"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  height: 320,
                  width: double.maxFinite,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      DormListViewF(),
                      DormListViewM(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DormListViewF extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        String itemText = 'Dorm ${index + 1}';
        String subtitle = index % 3 == 0
            ? 'Dagupan City'
            : index % 2 == 0
                ? 'San Jacinto'
                : 'Mangaldan';

        return GestureDetector(
          onTap: () {
            // Navigate to DormDetailPage with the dorm name
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DormDetailPage(itemText),
            ));
          },
          child: Container(
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
              image: DecorationImage(
                image: AssetImage("assets/images/dorm.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    Icon(Icons.info_outline, color: Colors.white, size: 30),
                  ],
                ),
                Spacer(),
                Text(
                  itemText,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                      color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 15, fontFamily: 'Lato', color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DormListViewM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        String itemText = 'Dorm ${index + 1}';
        String subtitle = index % 3 == 0
            ? 'San Fabian'
            : index % 2 == 0
                ? 'Dagupan City'
                : 'Manaoag';

        return GestureDetector(
          onTap: () {
            // Navigate to DormDetailPage with the dorm name
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DormDetailPage(itemText),
            ));
          },
          child: Container(
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
              image: DecorationImage(
                image: AssetImage("assets/images/dorm.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    Icon(Icons.info_outline, color: Colors.white, size: 30),
                  ],
                ),
                Spacer(),
                Text(
                  itemText,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                      color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 15, fontFamily: 'Lato', color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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

    // Adjust the vertical positioning to avoid overlapping with the line
    final Offset circleOffset = offset +
        Offset(configuration.size!.width / 2,
            configuration.size!.height - radius - 4); // Shift up by 4 pixels

    canvas.drawCircle(circleOffset, radius, paint);
  }
}
