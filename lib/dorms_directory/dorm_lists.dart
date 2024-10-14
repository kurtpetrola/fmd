import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/maps_directory/maps_detail_page.dart';
import 'package:findmydorm/maps_directory/maps_detail_page1.dart';
import 'package:findmydorm/maps_directory/maps_detail_page2.dart';
import 'package:findmydorm/maps_directory/maps_detail_page3.dart';
import 'package:findmydorm/maps_directory/maps_detail_page4.dart';
import 'package:findmydorm/maps_directory/maps_detail_page5.dart';
import 'package:findmydorm/maps_directory/maps_detail_page6.dart';
import 'package:findmydorm/maps_directory/maps_detail_page7.dart';
import 'package:findmydorm/maps_directory/maps_detail_page8.dart';
import 'package:findmydorm/maps_directory/maps_detail_page9.dart';

class DormList extends StatefulWidget {
  const DormList({Key? key}) : super(key: key);

  @override
  _DormListState createState() => _DormListState();
}

class _DormListState extends State<DormList> {
  final List<Map<String, dynamic>> _allUsers = [
    {"id": 1, "name": "Dagupan City"},
    {"id": 2, "name": "Urdaneta"},
    {"id": 3, "name": "San Jacinto"},
    {"id": 4, "name": "Mangaldan"},
    {"id": 5, "name": "Mapandan"},
    {"id": 6, "name": "San Fabian"},
    {"id": 7, "name": "Alaminos"},
    {"id": 8, "name": "Binalonan"},
    {"id": 9, "name": "Tayug"},
    {"id": 10, "name": "Sison"},
  ];

  final Map<int, Widget Function()> _dormPageRoutes = {
    1: () => MapsDetailPage(),
    2: () => MapsDetailPage1(),
    3: () => MapsDetailPage2(),
    4: () => MapsDetailPage3(),
    5: () => MapsDetailPage4(),
    6: () => MapsDetailPage5(),
    7: () => MapsDetailPage6(),
    8: () => MapsDetailPage7(),
    9: () => MapsDetailPage8(),
    10: () => MapsDetailPage9(),
  };

  List<Map<String, dynamic>> _foundUsers = [];

  @override
  void initState() {
    _foundUsers = _allUsers;
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results;
    if (enteredKeyword.isEmpty) {
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundUsers = results;
    });
  }

  void _navigateToDormPage(int dormId) {
    final pageBuilder = _dormPageRoutes[dormId];
    if (pageBuilder != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => pageBuilder()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Page for Dorm ID $dormId not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Dorms List'),
        backgroundColor: Colors.amber,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              onChanged: _runFilter,
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Ionicons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () =>
                            _navigateToDormPage(_foundUsers[index]["id"]),
                        child: Card(
                          key: ValueKey(_foundUsers[index]["id"]),
                          color: Colors.amber,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Text(
                              _foundUsers[index]["id"].toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontFamily: 'Lato',
                              ),
                            ),
                            title: Text(
                              _foundUsers[index]['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Lato',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
