// admin_location_picker.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class AdminLocationPicker extends StatefulWidget {
  const AdminLocationPicker({super.key});

  @override
  State<AdminLocationPicker> createState() => _AdminLocationPickerState();
}

class _AdminLocationPickerState extends State<AdminLocationPicker> {
  final MapController mapController = MapController();
  final LatLng _initialCenter = const LatLng(14.5995, 120.9842);
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();

  // Define colors for consistent theming
  final Color primaryAmber = Colors.amber.shade700;
  final Color foregroundColor = Colors.white;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    // ... (logic remains the same) ...
    try {
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

  void navigateToPlace(String placeName) async {
    // ... (logic remains the same) ...
    final LatLng? coordinates = await getCoordinatesFromAddress(placeName);
    if (coordinates != null) {
      setState(() {
        _selectedLocation = coordinates;
      });
      mapController.move(
        coordinates,
        16.0,
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

  void _handleTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Dorm Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: primaryAmber,
        foregroundColor: foregroundColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: foregroundColor),
            onPressed: () {
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
        children: [
          // 1. The Map Widget
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12.0,
              onTap: _handleTap,
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
                      width: 50.0,
                      height: 50.0,
                      // 🟢 FIX: Removed the problematic 'anchor' property entirely.
                      // The map will use default centering, which is usually fine
                      // for an icon of this shape.
                      child: Icon(
                        Icons.location_on,
                        color: primaryAmber,
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. The Search Bar UI (Improved Styling)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search place, city, or address...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: primaryAmber),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: primaryAmber),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          navigateToPlace(_searchController.text);
                        }
                      },
                    ),
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

          // 3. Floating Location Display (Permanent Feedback)
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: primaryAmber.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  'LAT: ${(_selectedLocation!.latitude).toStringAsFixed(6)} | LNG: ${(_selectedLocation!.longitude).toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
