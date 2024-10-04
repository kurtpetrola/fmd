import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapsDetailPage2 extends StatefulWidget {
  const MapsDetailPage2({super.key});

  @override
  State<MapsDetailPage2> createState() => _MapsDetailState2();
}

class _MapsDetailState2 extends State<MapsDetailPage2> {
  final LatLng _center = LatLng(51, -0.09); // Define the center position

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center, // Set the map's initial center
          initialZoom: 15.0,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _center, // Place the marker at the center
                child: Icon(
                  Icons.place,
                  size: 48.0,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
