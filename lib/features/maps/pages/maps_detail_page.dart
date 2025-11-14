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
  final String? directionsUrl;

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

  // State to hold the calculated distance and duration
  String? _routeDistance;
  String? _routeDuration;

  // Tracks if the distance calculation was skipped due to missing user address
  bool _distanceCalculationSkipped = false;

  // Define GlobalKeys for Tooltips
  final GlobalKey<TooltipState> _timeTooltipKey = GlobalKey<TooltipState>();
  // 1. New GlobalKey for the Dorm Marker Tooltip
  final GlobalKey<TooltipState> _dormTooltipKey = GlobalKey<TooltipState>();
  // 2. New GlobalKey for the User Marker Tooltip
  final GlobalKey<TooltipState> _userTooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();

    final bool userLocationProvided =
        widget.userLatitude != null && widget.userLongitude != null;

    if (userLocationProvided) {
      // Only attempt to fetch the route if user coordinates are available
      _fetchRoute();
    } else {
      // If no user location, just show markers and set the skipped flag
      setState(() {
        _isLoadingRoute = false;
        _distanceCalculationSkipped = true; // Set flag here
      });
    }
  }

  // Helper to convert seconds to a readable minute format
  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '${hours} hr ${remainingMinutes} min';
    }
  }

  // Calls the OpenRouteService API
  Future<void> _fetchRoute() async {
    final startLat = widget.userLatitude;
    final startLng = widget.userLongitude;

    final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';

    if (startLat == null || startLng == null || orsApiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _routeError = "Configuration or location error.";
        });
      }
      return;
    }

    // DYNAMIC URL CONSTRUCTION: Use string interpolation
    final url =
        Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car'
            '?api_key=$orsApiKey'
            // NOTE: ORS expects Longitude, Latitude order
            '&start=$startLng,$startLat' // User location
            '&end=${widget.longitude},${widget.latitude}' // Dorm location
            );

    try {
      final response = await http.get(url, headers: {
        'Authorization': orsApiKey,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract the coordinates
        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];

        // Extract distance and duration from the summary
        final Map<String, dynamic> summary =
            data['features'][0]['properties']['summary'];

        final double distanceMeters = summary['distance'];
        final double durationSeconds = summary['duration'];

        final String formattedDistance =
            (distanceMeters / 1000.0).toStringAsFixed(1) + ' km';
        final String formattedDuration = _formatDuration(durationSeconds);

        final List<LatLng> newPoints = coordinates.map((coord) {
          // NOTE: Coordinates from ORS are in [lng, lat] order
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();

        setState(() {
          _routePoints = newPoints;
          _routeDistance = formattedDistance; // Store distance
          _routeDuration = formattedDuration; // Store duration
          _isLoadingRoute = false;
        });
      } else {
        // Show the API error response to debug failures
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool showInfoIcon = false,
  }) {
    // Use the correct key for the 'Driving Time' info item
    final GlobalKey<TooltipState>? tooltipKey =
        showInfoIcon ? _timeTooltipKey : null;

    // The actual message for the tooltip
    const String tooltipMessage =
        'This is an approximation and does not account for real-time traffic or unforeseen delays.';

    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            if (showInfoIcon)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: GestureDetector(
                  // Detects the tap gesture
                  onTap: () {
                    // Use the key to access the state
                    tooltipKey?.currentState?.ensureTooltipVisible();
                  },
                  child: Tooltip(
                    key: tooltipKey, // Assign the typed GlobalKey here
                    message: tooltipMessage,
                    child: Icon(
                      Ionicons.information_circle_outline,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Helper method for the floating card UI
  Widget _buildFloatingInfoCard() {
    // Case 1: Route calculation was skipped (no user address)
    if (_distanceCalculationSkipped) {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Card(
          color: Colors.amber.shade100,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Ionicons.alert_circle_outline,
                    color: Colors.orange, size: 24),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Set your address in Profile Settings to see the route distance.',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Case 2: Data hasn't loaded yet OR data is null (should only happen during loading)
    if (_routeDistance == null || _routeDuration == null) {
      return const SizedBox.shrink(); // Hide if data isn't ready
    }

    // Case 3: Data successfully loaded (route fetched)
    return Positioned(
      bottom: 20, // Spacing from the bottom
      left: 20,
      right: 20,
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                icon: Ionicons.navigate_circle_outline,
                label: 'Driving Distance',
                value: _routeDistance!,
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildInfoItem(
                icon: Ionicons.time_outline,
                label: 'Driving Time',
                value: _routeDuration!,
                showInfoIcon: true,
              ),
            ],
          ),
        ),
      ),
    );
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

    if (_isLoadingRoute && widget.userLatitude != null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_routeError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Route Error")),
        body: Center(child: Text('Error: $_routeError')),
      );
    }

    // Use a Stack to layer the map and the info card
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
      body: Stack(
        children: <Widget>[
          // 1. FlutterMap: This covers the whole screen
          FlutterMap(
            options: MapOptions(
              // Adjust initialCenter to zoom in on the route
              initialCenter: mapCenter,
              initialZoom: 12.0,
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),

              // PolylineLayer to draw the actual route
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints, // Use the fetched route points
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
                    width: 50.0, // Give space for the pop-up
                    height: 50.0, // Give space for the pop-up
                    // 3. Implement the Pop-up for the Dorm Marker
                    child: GestureDetector(
                      onTap: () {
                        // Show the tooltip on tap
                        _dormTooltipKey.currentState?.ensureTooltipVisible();
                      },
                      child: Tooltip(
                        key: _dormTooltipKey, // Assign the key
                        message: 'Dorm Address', // The pop-up text
                        verticalOffset: -30, // Position pop-up above icon
                        waitDuration:
                            const Duration(seconds: 0), // Show immediately
                        showDuration: const Duration(
                            seconds: 3), // Fade out after 3 seconds
                        child: const Icon(
                          Ionicons.home,
                          size: 35.0,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  // User Marker (Green) - Only show if not at the dorm
                  if (widget.userLatitude != null && !userIsAtDorm)
                    Marker(
                      point: userLocation,
                      width: 50.0, // Give space for the pop-up
                      height: 50.0, // Give space for the pop-up
                      // 4. Implement the Pop-up for the User Marker
                      child: GestureDetector(
                        onTap: () {
                          // Show the tooltip on tap
                          _userTooltipKey.currentState?.ensureTooltipVisible();
                        },
                        child: Tooltip(
                          key: _userTooltipKey, // Assign the key
                          message: 'Your Address', // The pop-up text
                          verticalOffset: -30, // Position pop-up above icon
                          waitDuration:
                              const Duration(seconds: 0), // Show immediately
                          showDuration: const Duration(
                              seconds: 3), // Fade out after 3 seconds
                          child: const Icon(
                            Icons.person_pin_circle,
                            size: 48.0,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Floating Info Card (Positioned Widget)
          _buildFloatingInfoCard(),
        ],
      ),
    );
  }
}
