// import 'package:findmydorm_mobile/pages/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:findmydorm/maps_directory/maps_detail_page.dart';
import 'package:ionicons/ionicons.dart';

class DormDetailPage extends StatelessWidget {
  final String dormName;

  DormDetailPage(this.dormName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find My Dorm'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage('assets/images/dorm.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ('$dormName'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              onPressed: () {
                // Navigate to the first page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapsDetailPage(),
                  ),
                );
              },
              child: Icon(
                Ionicons.map,
                size: 40,
                color: Colors.amber,
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                minimumSize: WidgetStateProperty.all<Size>(Size(280, 60)),
              )),
        ],
      ),
    );
  }
}
