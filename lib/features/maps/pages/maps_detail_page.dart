// maps_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class MapsDetailPage extends StatefulWidget {
  final double latitude; // Dorm Latitude
  final double longitude; // Dorm Longitude
  final String dormName;
  final double? userLatitude;
  final double? userLongitude;
  final String? directionsUrl; // We won't use this, but keeping it for context

  const MapsDetailPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.dormName,
    this.userLatitude,
    this.userLongitude,
    this.directionsUrl,
  });

  @override
  State<MapsDetailPage> createState() => _MapsDetailState();
}

class _MapsDetailState extends State<MapsDetailPage> {
  List<LatLng> _routePoints = []; // List to hold the route polyline points
  bool _isLoadingRoute = true;
  String? _routeError;

  @override
  void initState() {
    super.initState();
    // Only attempt to fetch the route if user coordinates are available
    if (widget.userLatitude != null && widget.userLongitude != null) {
      _fetchRoute();
    } else {
      // If no user location, just show markers
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  // Calls the OpenRouteService API
  Future<void> _fetchRoute() async {
    final startLat = widget.userLatitude;
    final startLng = widget.userLongitude;

    final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';

    if (startLat == null || startLng == null || orsApiKey.isEmpty) {
      // This check is good, but if orsApiKey is empty, it will fail silently.
      if (mounted) {
        // You can add a print here to confirm the key is loaded
        print('ORS Key Loaded: ${orsApiKey.isNotEmpty}');
        setState(() => _isLoadingRoute = false);
      }
      return;
    }

    // 1. DYNAMIC URL CONSTRUCTION: Use string interpolation
    final url =
        Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car'
            '?api_key=$orsApiKey' // Use the dynamic variable
            // NOTE: ORS expects Longitude, Latitude order
            '&start=$startLng,$startLat' // Use user variables
            '&end=${widget.longitude},${widget.latitude}' // Use dorm variables
            );

    try {
      final response = await http.get(url, headers: {
        // Optional: Some APIs prefer the key in a header
        'Authorization': orsApiKey,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract the coordinates from the route geometry
        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];

        final List<LatLng> newPoints = coordinates.map((coord) {
          // NOTE: Coordinates from ORS are in [lng, lat] order
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();

        setState(() {
          _routePoints = newPoints;
          _isLoadingRoute = false;
        });
      } else {
        // 2. BETTER ERROR REPORTING: Show the API error response to debug failures
        print('Route API Error (${response.statusCode}): ${response.body}');
        setState(() {
          _routeError =
              'Failed to load route: ${response.statusCode}. Check console for details.';
          _isLoadingRoute = false;
        });
      }
    } catch (e) {
      print('HTTP Error: $e');
      setState(() {
        _routeError = 'Error fetching route: $e';
        _isLoadingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dorm Location
    final LatLng dormLocation = LatLng(widget.latitude, widget.longitude);

    // Safely retrieve User Location (using dorm location as fallback if null)
    final LatLng userLocation = LatLng(widget.userLatitude ?? widget.latitude,
        widget.userLongitude ?? widget.longitude);

    // Calculate Map Center
    final double centerLat =
        (dormLocation.latitude + userLocation.latitude) / 2;
    final double centerLng =
        (dormLocation.longitude + userLocation.longitude) / 2;
    final LatLng initialCenter = LatLng(centerLat, centerLng);

    // Center the map on the user location if the route is still loading
    final LatLng mapCenter = _isLoadingRoute && widget.userLatitude != null
        ? userLocation
        : initialCenter;

    // Check if user and dorm are at the exact same point
    final bool userIsAtDorm = dormLocation == userLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.dormName} Route',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoadingRoute && widget.userLatitude != null
          ? const Center(child: CircularProgressIndicator())
          : _routeError != null
              ? Center(child: Text('Error: $_routeError'))
              : FlutterMap(
                  options: MapOptions(
                    // Adjust initialCenter to zoom in on the route
                    initialCenter: mapCenter,
                    initialZoom: 12.0,
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),

                    // PolylineLayer to draw the actual route
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points:
                                _routePoints, // Use the fetched route points
                            strokeWidth: 5.0,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),

                    // MARKERS
                    MarkerLayer(
                      markers: [
                        // Dorm Marker (Red)
                        Marker(
                          point: dormLocation,
                          child: const Icon(
                            Ionicons.home,
                            size: 35.0,
                            color: Colors.red,
                          ),
                        ),
                        // User Marker (Green) - Only show if not at the dorm
                        if (widget.userLatitude != null && !userIsAtDorm)
                          Marker(
                            point: userLocation,
                            child: const Icon(
                              Icons.person_pin_circle,
                              size: 48.0,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
