import 'package:flutter/material.dart';

class Dorm {
  final String name;
  final String address;

  Dorm({required this.name, required this.address});
}

class FavoriteScreen extends StatelessWidget {
  FavoriteScreen({Key? key}) : super(key: key);

  final List<Dorm> favoriteDorms = [
    Dorm(name: "Dorm 1", address: "Address 1"),
    Dorm(name: "Dorm 2", address: "Address 2"),
    Dorm(name: "Dorm 3", address: "Address 3"),
    Dorm(name: "Dorm 4", address: "Address 4"),
    Dorm(name: "Dorm 5", address: "Address 5"),
    Dorm(name: "Dorm 6", address: "Address 6"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Dorms'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: favoriteDorms.length,
        itemBuilder: (context, index) {
          final dorm = favoriteDorms[index];
          return _buildDormCard(dorm);
        },
      ),
    );
  }

  Widget _buildDormCard(Dorm dorm) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          dorm.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(dorm.address),
      ),
    );
  }
}
