// dorm_lists.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/server/sqlite.dart';
import 'package:findmydorm/dorms_directory/dorm_detail_page.dart';

class DormList extends StatefulWidget {
  const DormList({Key? key}) : super(key: key);

  @override
  _DormListState createState() => _DormListState();
}

class _DormListState extends State<DormList> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Dormitories List'),
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
                labelText: 'Search by Dorm Name or Location',
                suffixIcon: Icon(Ionicons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber))
                  : _foundDorms.isEmpty
                      ? const Center(
                          child: Text(
                            'No dormitories found.',
                            style: TextStyle(fontSize: 25, fontFamily: 'Lato'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _foundDorms.length,
                          itemBuilder: (context, index) {
                            final dorm = _foundDorms[index];
                            return GestureDetector(
                              onTap: () => _navigateToDormPage(dorm),
                              child: Card(
                                key: ValueKey(dorm.dormId),
                                color: Colors.amber,
                                elevation: 4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  // REMOVED: Gender-specific icon logic
                                  leading: const Icon(
                                    Ionicons.bed_outline, // Generic dorm icon
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    dorm.dormName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // REMOVED: Gender info from subtitle
                                  subtitle: Text(
                                    'Location: ${dorm.dormLocation}',
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Text(
                                    '#${dorm.dormNumber}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
