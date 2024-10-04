import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapsDetailPage5 extends StatefulWidget {
  const MapsDetailPage5({super.key});

  @override
  State<MapsDetailPage5> createState() => _MapsDetailState5();
}

class _MapsDetailState5 extends State<MapsDetailPage5> {
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
