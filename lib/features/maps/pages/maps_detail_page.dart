// maps_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapsDetailPage extends StatefulWidget {
  final double latitude; // Accept the required latitude
  final double longitude; // Accept the required longitude
  final String dormName; // Optional: for the AppBar title

  const MapsDetailPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.dormName,
  });

  @override
  State<MapsDetailPage> createState() => _MapsDetailState();
}

class _MapsDetailState extends State<MapsDetailPage> {
  // We'll calculate the center in build or initState now
  // final LatLng _center = LatLng(51, -0.09); <--- REMOVE THIS HARDCODED VALUE

  @override
  Widget build(BuildContext context) {
    // Dynamically create the LatLng object from the widget's properties
    final LatLng location = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.dormName} Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ), // Use the dynamic name
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: location, // Set the map's initial center
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
                point: location, // Place the marker at the dynamic location
                child: const Icon(
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
