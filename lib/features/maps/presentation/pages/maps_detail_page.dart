// maps_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

enum TravelMode { driving, walking }

/// Provides map visualization mapping the user's location to the dormitory location.
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
  // ## STATE MANAGEMENT
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = true;
  String? _routeError;

  TravelMode _selectedMode = TravelMode.driving;
  String? _drivingDistance;
  String? _drivingDuration;
  String? _walkingDistance;
  String? _walkingDuration;

  bool _distanceCalculationSkipped = false;

  // GlobalKeys for Tooltips (Labels and Info Icon)
  final GlobalKey<TooltipState> _timeTooltipKey = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> _dormTooltipKey = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> _userTooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();

    final bool userLocationProvided =
        widget.userLatitude != null && widget.userLongitude != null;

    if (userLocationProvided) {
      _fetchRouteForMode(TravelMode.driving);
    } else {
      setState(() {
        _isLoadingRoute = false;
        _distanceCalculationSkipped = true;
      });
    }
  }

  // ## API & LOGIC METHODS

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).ceil();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '$hours hr $remainingMinutes min';
    }
  }

  String _getOrsProfile(TravelMode mode) {
    switch (mode) {
      case TravelMode.driving:
        return 'driving-car';
      case TravelMode.walking:
        return 'foot-walking';
    }
  }

  Future<void> _fetchRouteForMode(TravelMode mode) async {
    if (mode == _selectedMode && mounted) {
      setState(() {
        _isLoadingRoute = true;
        _routeError = null;
      });
    }

    final startLat = widget.userLatitude;
    final startLng = widget.userLongitude;
    final String orsApiKey = dotenv.env['ORS_API_KEY'] ?? '';
    final String profile = _getOrsProfile(mode);

    if (startLat == null || startLng == null || orsApiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          if (mode == _selectedMode) {
            _routeError = "Configuration or location error.";
          }
        });
      }
      return;
    }

    final url =
        Uri.parse('https://api.openrouteservice.org/v2/directions/$profile'
            '?api_key=$orsApiKey'
            '&start=$startLng,$startLat'
            '&end=${widget.longitude},${widget.latitude}');

    try {
      final response = await http.get(url, headers: {
        'Authorization': orsApiKey,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<dynamic> coordinates =
            data['features'][0]['geometry']['coordinates'];
        final Map<String, dynamic> summary =
            data['features'][0]['properties']['summary'];

        final double distanceMeters = summary['distance'];
        final double durationSeconds = summary['duration'];

        final String formattedDistance =
            '${(distanceMeters / 1000.0).toStringAsFixed(1)} km';
        final String formattedDuration = _formatDuration(durationSeconds);

        final List<LatLng> newPoints = coordinates.map((coord) {
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();

        if (mounted) {
          setState(() {
            if (mode == TravelMode.driving) {
              _drivingDistance = formattedDistance;
              _drivingDuration = formattedDuration;
            } else if (mode == TravelMode.walking) {
              _walkingDistance = formattedDistance;
              _walkingDuration = formattedDuration;
            }

            if (mode == _selectedMode) {
              _routePoints = newPoints;
              _isLoadingRoute = false;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _routeError =
                'Failed to load ${mode.name} route: ${response.statusCode}.';
            if (mode == _selectedMode) {
              _isLoadingRoute = false;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _routeError = 'Error fetching ${mode.name} route: $e';
          if (mode == _selectedMode) {
            _isLoadingRoute = false;
          }
        });
      }
    }
  }

  // External Map Launcher Logic

  Future<void> _launchMapUrl(String url) async {
    final uri = Uri.parse(url); // Parse the URL into a Uri object

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Optionally show a snackbar or alert if the app can't open the URL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map application.')),
        );
      }
    }
  }

  void _launchGoogleMaps() {
    final userLat = widget.userLatitude;
    final userLng = widget.userLongitude;
    final dormLat = widget.latitude;
    final dormLng = widget.longitude;

    if (userLat == null || userLng == null) {
      // Should be handled by _buildDirectionsButton, but good practice to double check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Your address is missing. Cannot open directions.')),
        );
      }
      return;
    }

    final modeParam =
        _selectedMode == TravelMode.driving ? 'driving' : 'walking';

    // Standard, universal Google Maps directions URL
    final url = 'https://www.google.com/maps/dir/'
        '?api=1'
        '&origin=$userLat,$userLng' // Your current location
        '&destination=$dormLat,$dormLng' // The dorm location
        '&travelmode=$modeParam'; // driving or walking mode

    _launchMapUrl(url);
  }

  void _launchWaze() {
    final dormLat = widget.latitude;
    final dormLng = widget.longitude;

    // Most reliable Waze URL format: waze://?ll=lat,lng&navigate=yes
    // This tells Waze to navigate from the user's current location to the lat/lng.
    final url = 'waze://?ll=$dormLat,$dormLng&navigate=yes';

    _launchMapUrl(url);
  }

  // ## HELPER WIDGETS

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool showInfoIcon = false,
  }) {
    final GlobalKey<TooltipState>? tooltipKey =
        showInfoIcon ? _timeTooltipKey : null;
    const String tooltipMessage =
        'This is an approximation and does not account for real-time traffic or unforeseen delays.';

    return Column(
      children: [
        Icon(icon, color: AppColors.mapBlue, size: 28),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.mapBlueDark,
              ),
            ),
            if (showInfoIcon)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: GestureDetector(
                  onTap: () {
                    tooltipKey?.currentState?.ensureTooltipVisible();
                  },
                  child: Tooltip(
                    key: tooltipKey,
                    message: tooltipMessage,
                    child: const Icon(
                      Ionicons.information_circle_outline,
                      size: 16,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    if (_distanceCalculationSkipped) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.black87.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ToggleButtons(
            isSelected:
                TravelMode.values.map((mode) => mode == _selectedMode).toList(),
            onPressed: (int index) {
              final newMode = TravelMode.values[index];
              if (newMode != _selectedMode) {
                setState(() {
                  _selectedMode = newMode;
                  _routePoints = [];
                });
                _fetchRouteForMode(newMode);
              }
            },
            borderRadius: BorderRadius.circular(30),
            selectedColor: Colors.white,
            color: AppColors.mapBlue,
            fillColor: AppColors.mapBlue,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Ionicons.car_outline, size: 20),
                    SizedBox(width: 4),
                    Text('Drive',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Ionicons.walk_outline, size: 20),
                    SizedBox(width: 4),
                    Text('Walk', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Directions Button and Modal Options

  Widget _buildDirectionsButton() {
    if (_distanceCalculationSkipped || widget.userLatitude == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 75,
      right: 15,
      child: FloatingActionButton(
        heroTag: 'directionsFAB',
        mini: true,
        backgroundColor: AppColors.mapBlue,
        foregroundColor: Colors.white,
        onPressed: () {
          _showDirectionsOptions(context);
        },
        child: const Icon(Ionicons.share_outline),
      ),
    );
  }

  void _showDirectionsOptions(BuildContext context) {
    final String modeText =
        _selectedMode == TravelMode.driving ? 'Driving' : 'Walking';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Open $modeText Directions in:',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Ionicons.map_outline, color: AppColors.success),
                title: const Text('Google Maps'),
                subtitle: Text('Opens the $modeText route in Google Maps.'),
                onTap: () {
                  Navigator.pop(context);
                  _launchGoogleMaps();
                },
              ),
              // Note: Waze typically forces driving mode regardless of what we pass
              ListTile(
                leading:
                    const Icon(Ionicons.compass_outline, color: AppColors.wazeOrange),
                title: const Text('Waze'),
                subtitle: const Text(
                    'Opens the fastest route in Waze (Driving recommended).'),
                onTap: () {
                  Navigator.pop(context);
                  _launchWaze();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingInfoCard() {
    // Case 1: Route calculation was skipped
    if (_distanceCalculationSkipped) {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Card(
          color: AppColors.primaryAmberShade100,
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Ionicons.alert_circle_outline,
                    color: AppColors.wazeOrange, size: 24),
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

    // Determine data based on current mode
    String? currentDistance = (_selectedMode == TravelMode.driving)
        ? _drivingDistance
        : _walkingDistance;
    String? currentDuration = (_selectedMode == TravelMode.driving)
        ? _drivingDuration
        : _walkingDuration;
    String modeLabel =
        (_selectedMode == TravelMode.driving) ? 'Driving' : 'Walking';
    IconData timeIcon = (_selectedMode == TravelMode.driving)
        ? Ionicons.time_outline
        : Ionicons.walk_outline;
    IconData distanceIcon = (_selectedMode == TravelMode.driving)
        ? Ionicons.navigate_circle_outline
        : Ionicons.footsteps_outline;

    // Case 2: Data hasn't loaded yet
    if (currentDistance == null || currentDuration == null) {
      if (_isLoadingRoute && widget.userLatitude != null) {
        return Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Card(
            color: Colors.white,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text('Calculating $modeLabel Route...'),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Case 3: Data successfully loaded
    return Positioned(
      bottom: 20,
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
                icon: distanceIcon,
                label: '$modeLabel Distance',
                value: currentDistance,
              ),
              Container(width: 1, height: 40, color: AppColors.grey300),
              _buildInfoItem(
                icon: timeIcon,
                label: '$modeLabel Time',
                value: currentDuration,
                showInfoIcon: _selectedMode == TravelMode.driving,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Centralizes the MarkerLayer logic
  Widget _buildMapMarkers(
      LatLng dormLocation, LatLng userLocation, bool userIsAtDorm) {
    return MarkerLayer(
      markers: [
        // Dorm Marker (Red)
        Marker(
          point: dormLocation,
          width: 50.0,
          height: 50.0,
          child: GestureDetector(
            onTap: () {
              _dormTooltipKey.currentState?.ensureTooltipVisible();
            },
            child: Tooltip(
              key: _dormTooltipKey,
              message: 'Dorm Address',
              verticalOffset: -30,
              waitDuration: const Duration(seconds: 0),
              showDuration: const Duration(seconds: 3),
              child: const Icon(
                Ionicons.home,
                size: 35.0,
                color: AppColors.error,
              ),
            ),
          ),
        ),

        // User Marker (Green) - Only show if user location is available and not at dorm
        if (widget.userLatitude != null && !userIsAtDorm)
          Marker(
            point: userLocation,
            width: 50.0,
            height: 50.0,
            child: GestureDetector(
              onTap: () {
                _userTooltipKey.currentState?.ensureTooltipVisible();
              },
              child: Tooltip(
                key: _userTooltipKey,
                message: 'Your Address',
                verticalOffset: -30,
                waitDuration: const Duration(seconds: 0),
                showDuration: const Duration(seconds: 3),
                child: const Icon(
                  Icons.person_pin_circle,
                  size: 48.0,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ## MAIN BUILD METHOD

  @override
  Widget build(BuildContext context) {
    // Location calculations
    final LatLng dormLocation = LatLng(widget.latitude, widget.longitude);
    final LatLng userLocation = LatLng(widget.userLatitude ?? widget.latitude,
        widget.userLongitude ?? widget.longitude);
    final bool userIsAtDorm = dormLocation == userLocation;

    final double centerLat =
        (dormLocation.latitude + userLocation.latitude) / 2;
    final double centerLng =
        (dormLocation.longitude + userLocation.longitude) / 2;
    final LatLng initialCenter = LatLng(centerLat, centerLng);
    final LatLng mapCenter = _isLoadingRoute && widget.userLatitude != null
        ? userLocation
        : initialCenter;

    // Loading and Error Guards
    if (_isLoadingRoute &&
        widget.userLatitude != null &&
        _selectedMode == TravelMode.driving) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.dormName} Route',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: AppColors.primaryAmberShade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          // 1. FlutterMap
          FlutterMap(
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 12.0,
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),

              // PolylineLayer with enhanced styling
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth:
                          (_selectedMode == TravelMode.driving) ? 6.0 : 4.0,
                      color: (_selectedMode == TravelMode.driving)
                          ? AppColors.mapBlue
                          : AppColors.walkGreen,
                      borderStrokeWidth: 1.5,
                      borderColor: Colors.white,
                    ),
                  ],
                ),

              // MarkerLayer
              _buildMapMarkers(dormLocation, userLocation, userIsAtDorm),
            ],
          ),

          // 2. Mode Selector (Floating Widget)
          _buildModeSelector(),

          // 3. Directions Button (Floating Widget)
          _buildDirectionsButton(),

          // 4. Floating Info Card (Positioned Widget)
          _buildFloatingInfoCard(),
        ],
      ),
    );
  }
}
