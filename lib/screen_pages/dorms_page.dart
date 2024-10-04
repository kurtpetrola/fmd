import 'package:flutter/material.dart';

class Dorm {
  final String name;
  final String address;

  Dorm({required this.name, required this.address});
}

class DormsPage extends StatelessWidget {
  DormsPage({super.key});

  final List<Dorm> favoriteDorms = [
    Dorm(name: "Dorm 1", address: "Address 1"),
    Dorm(name: "Dorm 2", address: "Address 2"),
    Dorm(name: "Dorm 3", address: "Address 3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDormList(),
    );
  }

  Widget _buildDormList() {
    return ListView.builder(
      itemCount: favoriteDorms.length,
      itemBuilder: (context, index) {
        final dorm = favoriteDorms[index];
        return _buildDormCard(dorm);
      },
    );
  }

  Widget _buildDormCard(Dorm dorm) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: ListTile(
        title: Text(dorm.name),
        subtitle: Text(dorm.address),
      ),
    );
  }
}
