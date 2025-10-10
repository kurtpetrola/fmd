// admin_location_picker.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart'; // <<< NEW: For geocoding logic

class AdminLocationPicker extends StatefulWidget {
  const AdminLocationPicker({super.key});

  @override
  State<AdminLocationPicker> createState() => _AdminLocationPickerState();
}

class _AdminLocationPickerState extends State<AdminLocationPicker> {
  // NEW: MapController to programmatically move the map
  final MapController mapController = MapController();

  // Initial center set to a default (e.g., a central point in the Philippines)
  final LatLng _initialCenter = const LatLng(14.5995, 120.9842);
  LatLng? _selectedLocation;

  // NEW: TextEditingController for the search bar
  final TextEditingController _searchController = TextEditingController();

  // 1. Core Geocoding Logic (Converts text to LatLng)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // NOTE: This uses the platform's native geocoder (Google/Apple),
      // which is generally good but has rate limits.
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location firstResult = locations.first;
        return LatLng(firstResult.latitude, firstResult.longitude);
      }
      return null;
    } catch (e) {
      print("Geocoding Error: $e");
      return null;
    }
  }

  // 2. Navigation Logic (Moves the map and selects the location)
  void navigateToPlace(String placeName) async {
    final LatLng? coordinates = await getCoordinatesFromAddress(placeName);

    if (coordinates != null) {
      setState(() {
        _selectedLocation = coordinates;
      });

      // Animate the map camera to the new coordinates
      mapController.move(
        coordinates, // The LatLng destination
        16.0, // The desired zoom level
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found and selected: $placeName'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not find location for: "$placeName"'),
        ),
      );
    }
  }

  // Existing tap handler
  void _handleTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Selected: Lat ${latLng.latitude.toStringAsFixed(4)}, Lng ${latLng.longitude.toStringAsFixed(4)}'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Dorm Location'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // Return the selected location (lat/lng) back to the AdminPage
              if (_selectedLocation != null) {
                Navigator.pop(context, _selectedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please tap or search a location.')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        // Use Stack to layer the search bar over the map
        children: [
          // 1. The Map Widget
          FlutterMap(
            mapController: mapController, // Pass the controller
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12.0,
              onTap: _handleTap, // Capture taps to get coordinates
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      child: const Icon(Icons.location_on,
                          color: Colors.blue, size: 40),
                    ),
                  ],
                ),
            ],
          ),

          // 2. The Search Bar UI
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search place, city, or address...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    // Optional: Add a clear button
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      navigateToPlace(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
