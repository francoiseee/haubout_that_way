// presentation/map_page.dart (UPDATED WITH DRAGGABLE LIST, CAMPUS ROUTES, AND USER LOCATION)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/building_detail_page.dart';
import 'package:hau_navigation_app/widgets/custom_app_bar.dart';
import 'package:hau_navigation_app/viewmodels/campus_route_viewmodel.dart';
import 'package:hau_navigation_app/models/campus_route.dart';
import 'package:hau_navigation_app/supabase_services/waypoint_service.dart';
import 'package:hau_navigation_app/supabase_services/edge_service.dart';
import 'package:hau_navigation_app/data/waypoints.dart' as wpdata;

class MapPage extends StatefulWidget {
  final bool isAdmin;

  const MapPage({super.key, this.isAdmin = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  CampusRoute? _previousSelectedRoute;

  // Location and compass tracking
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassStreamSubscription;
  double _currentHeading = 0.0;
  bool _isLocationEnabled = false;
  bool _isFollowingUser = false;

  // Search functionality
  final TextEditingController _routeSearchController = TextEditingController();
  String _routeSearchQuery = '';

  // Graph data for dummy pathways and shortest-path computation
  final Map<String, LatLng> _graphNodes = {}; // name -> LatLng
  final Map<String, Map<String, double>> _graphEdges =
      {}; // name -> (neighbor -> distance)

  // Computed shortest path polyline (displayed on map)
  List<LatLng> _computedPath = [];
  // Whether the user has started a navigation session from BuildingDetailPage
  bool _isNavigating = false;
  // Track the current navigation target for dynamic path adjustment
  String? _currentNavigationTarget;
  // Guards for realtime path recomputation when the user moves
  bool _isComputingPath = false;
  DateTime? _lastPathComputeTime;
  LatLng? _lastPathComputePosition;
  // Minimum time between recomputes and minimum movement distance to trigger recompute
  final Duration _minRecomputeInterval = const Duration(milliseconds: 800);
  final double _minRecomputeDistanceMeters = 1.0;
  // Track whether the routes bottom sheet is currently open so marker taps can safely close it
  bool _isRoutesSheetOpen = false;

  // Whether waypoint markers are visible (toggleable)
  bool _showWaypoints = true;
  // Whether building markers are visible (toggleable to better inspect waypoints)
  bool _showBuildings = true;

  final List<Map<String, dynamic>> _buildings = [
    {
      'name': 'Entrance',
      'offices': ['Security Office', 'Information Desk'],
    },
    {
      'name': 'Plaza De Corazon Building (Red Bldg.)',
      'offices': ['Human Resource Development Office', 'Dormitory'],
    },
    {
      'name': 'St. Martha Hall Building',
      'offices': ['Admissions Office & Testing Center', 'Dormitory'],
    },
    {
      'name': 'San Francisco De Javier Building (SFJ)',
      'offices': [
        'President\'s Office',
        'University Library',
        'University Theater'
      ],
    },
    {
      'name': 'St. Therese of Liseux Building (STL)',
      'offices': [
        'School of Hospitality and Tourism Management Dean\'s Office'
      ],
    },
    {
      'name': 'Warehouse & Carpentry',
      'offices': [],
    },
    {
      'name': 'Yellow Food Court',
      'offices': [],
    },
    {
      'name': 'St. Gabriel Hall Building (SGH)',
      'offices': [],
    },
    {
      'name': 'St. Raphael Hall Building (SRH)',
      'offices': [],
    },
    {
      'name': 'St. Michael Hall Building (SMH)',
      'offices': [],
    },
    {
      'name': 'Geromin G. Nepomuceno Building (GGN)',
      'offices': ['Principal\'s Office / Faculty Room', 'High School Library'],
    },
    {
      'name': 'Peter G. Nepomuceno Building (PGN)',
      'offices': [
        'OSSA - Scholarship & Grants Office',
        'School of Business and Accountancy Dean\'s Office',
        'PGN Auditorium'
      ],
    },
    {
      'name': 'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)',
      'offices': ['Registrar\'s Office', 'Finance Office', 'CCS Office'],
    },
    {
      'name': 'Archbishop Pedro Santos Building (APS)',
      'offices': [],
    },
    {
      'name': 'Mamerto G. Nepomuceno Building (MGN)',
      'offices': [
        'School of Nursing & Applied Medical Sciences Dean\'s Office',
        'College of Criminal Justice Education & Forensics Dean\'s Office'
      ],
    },
    {
      'name': 'Chapel of the Holy Guardian Angel',
      'offices': [],
    },
    {
      'name': 'Sister Josefina Nepomuceno Formation Center',
      'offices': [],
    },
    {
      'name': 'St. Joseph Hall Building (SJH)',
      'offices': [
        'School of Education Dean\'s Office',
        'School of Arts and Sciences Dean\'s Office',
        'School of Computing Dean\'s Office',
        'Academic Hall'
      ],
    },
    {
      'name': 'Sacred Heart Building (SH)',
      'offices': ['School of Engineering & Architecture Dean\'s Office'],
    },
    {
      'name': 'Covered Court',
      'offices': ['Immaculate Heart Gymnasium'],
    },
    {
      'name': 'Immaculate Heart Gymnasium',
      'offices': [],
    },
    {
      'name': 'Immaculate Heart Gymnasium Annex',
      'offices': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _initializeLocationTracking();
    _initializeCompassTracking();
    _initializeGraphData();
    // Update search query as the user types so filtering is immediate
    _routeSearchController.addListener(() {
      if (_routeSearchQuery != _routeSearchController.text) {
        setState(() {
          _routeSearchQuery = _routeSearchController.text;
        });
      }
    });

    // Initialize graph nodes and edges after a short delay to ensure markers list exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGraphData();
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _compassStreamSubscription?.cancel();
    _routeSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for changes to the selected route
    final selectedRoute = context.watch<CampusRouteViewModel>().selectedRoute;

    // Only animate if a new route has been selected
    if (selectedRoute != null && selectedRoute != _previousSelectedRoute) {
      _fitRouteOnMap(selectedRoute.polylinePoints);
      _previousSelectedRoute = selectedRoute;
    } else if (selectedRoute == null && _previousSelectedRoute != null) {
      // If a route has been deselected, return to default view
      _mapController.move(const LatLng(15.1341371, 120.5910619), 17.0);
      _previousSelectedRoute = null;
    }
  }

  /// Animates the map's camera to fit the given list of geographical points.
  void _fitRouteOnMap(List<LatLng> points) {
    if (points.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  /// Request location permission from the user
  Future<void> _requestLocationPermission() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      setState(() {
        _isLocationEnabled = true;
      });
    }
  }

  /// Initialize GPS location tracking
  Future<void> _initializeLocationTracking() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get initial position
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint(
          'Got initial position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      setState(() {
        _isLocationEnabled = true;
      });
    } catch (e) {
      debugPrint('Error getting current position: $e');
    }

    // Start listening to position changes
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update every 1 meter
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      debugPrint(
          'Position update: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentPosition = position;
        _isLocationEnabled = true;
      });

      // Follow user location if enabled
      if (_isFollowingUser && _currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _mapController.camera.zoom,
        );
      }

      // Dynamic path adjustment during navigation
      if (_isNavigating && _currentNavigationTarget != null) {
        // Adjust the existing computed path and also consider recomputing
        // a fresh shortest-path from the user's current location to the
        // navigation target (rate-limited) so updates appear in real-time.
        if (_computedPath.isNotEmpty) {
          _adjustPathDynamically();
        }

        // Attempt a full recompute when appropriate
        _maybeRecomputePathOnMove();
      }
    });
  }

  /// Initialize compass/heading tracking
  void _initializeCompassTracking() {
    _compassStreamSubscription =
        FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        setState(() {
          _currentHeading = event.heading!;
        });

        // Rotate map to follow user heading if following is enabled
        if (_isFollowingUser) {
          _mapController.rotate(-_currentHeading);
        }
      }
    });
  }

  /// Toggle user location following
  void _toggleLocationFollowing() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
    });

    if (_isFollowingUser) {
      // If no location yet, set a demo location within HAU campus
      if (_currentPosition == null) {
        setState(() {
          _currentPosition = Position(
            latitude: 15.1341371,
            longitude: 120.5910619,
            timestamp: DateTime.now(),
            accuracy: 3.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            floor: null,
            isMocked: false,
          );
        });
      }

      // Move to user location
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        18.0,
      );
      // Rotate to user heading
      _mapController.rotate(-_currentHeading);
    } else {
      // Reset rotation when not following
      _mapController.rotate(0.0);
    }
  }

  /// Build user location marker
  Marker? _buildUserLocationMarker() {
    if (_currentPosition == null) return null;

    return Marker(
      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 60.0,
      height: 60.0,
      // rotate with the map so the marker stays aligned to map rotation
      rotate: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          // Middle circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.4),
            ),
          ),
          // Inner circle with icon - do not rotate the icon manually; the Marker
          // will rotate with the map when rotate:true is set above.
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.navigation,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed from primaryRed to white

      // Custom App Bar with curved bottom corners (Extended Height)
      appBar: const CustomAppBar(),

      body: Stack(
        children: [
          // Map view (full screen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // MAIN MAP
                Consumer<CampusRouteViewModel>(
                  builder: (context, routeViewModel, child) {
                    final selectedRoute = routeViewModel.selectedRoute;
                    final polylines = <Polyline>[];

                    // Debug: log route state and navigation mode
                    debugPrint(
                        'Map Consumer rebuild - selectedRoute: ${selectedRoute?.id ?? 'null'}, _isNavigating: $_isNavigating');

                    // If a route is selected and we're NOT currently navigating, display its polyline
                    if (selectedRoute != null && !_isNavigating) {
                      polylines.add(
                        Polyline(
                          points: selectedRoute.polylinePoints,
                          color: selectedRoute.color,
                          strokeWidth: 4.0,
                        ),
                      );
                    }

                    // Build waypoint graph polylines (black) from _graphEdges/_graphNodes
                    final graphPolylines = <Polyline>[];
                    try {
                      for (final from in _graphEdges.keys) {
                        final neighbors = _graphEdges[from];
                        if (neighbors == null) continue;
                        for (final to in neighbors.keys) {
                          // avoid duplicate edges by enforcing an ordering
                          if (from.compareTo(to) >= 0) continue;
                          final a = _graphNodes[from];
                          final b = _graphNodes[to];
                          if (a == null || b == null) continue;
                          graphPolylines.add(
                            Polyline(
                              points: [a, b],
                              color: Colors.black, //PATHWAY COLOR
                              strokeWidth: 2.0,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Error building graph polylines: $e');
                    }

                    return FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter:
                            LatLng(15.132896, 120.590068), // HAU coordinates
                        initialZoom: 17.0,
                        minZoom: 15.0,
                        maxZoom: 19.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.hau.navigation_app',
                          additionalOptions: const {
                            'attribution':
                                '© OpenStreetMap contributors © CARTO',
                          },
                        ),
                        // Route polylines layer (selected campus route)
                        PolylineLayer(polylines: polylines),

                        // Waypoint / graph edges (always visible, black)
                        if (graphPolylines.isNotEmpty)
                          PolylineLayer(
                            polylines: graphPolylines,
                          ),

                        // Computed shortest path (if any) - draw in red on top of graph
                        if (_computedPath.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _computedPath,
                                color: Colors.red,
                                strokeWidth: 5.0,
                              ),
                            ],
                          ),
                        // Building markers layer + waypoint node markers
                        MarkerLayer(
                          markers: [
                            // Building markers (can be toggled off to inspect waypoints)
                            if (_showBuildings) ..._buildMapMarkers(),

                            // Waypoint nodes (from external data file) - small blue circles
                            if (widget.isAdmin && _showWaypoints)
                              for (final entry in _graphNodes.entries)
                                Marker(
                                  point: entry.value,
                                  width: 18,
                                  height: 18,
                                  // rotate with the map so waypoints follow map rotation
                                  rotate: true,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                          border: Border.all(
                                              color: Colors.white, width: 1.5),
                                        ),
                                      ),
                                      // Numeric label based on ordered keys (1-based)
                                      Builder(builder: (ctx) {
                                        try {
                                          final idx = _graphNodes.keys
                                              .toList()
                                              .indexOf(entry.key);
                                          final label =
                                              idx >= 0 ? '${idx + 1}' : '';
                                          return Text(
                                            label,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        } catch (_) {
                                          return const SizedBox.shrink();
                                        }
                                      }),
                                    ],
                                  ),
                                ),

                            // User location marker if available
                            if (_buildUserLocationMarker() != null)
                              _buildUserLocationMarker()!,
                          ],
                        ),
                      ],
                    );
                  },
                ),

                /* COMMENT START
                // Search bar (positioned at top of map)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 60,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search building...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                */ //COMMENT START

                // Location control button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed:
                          _isLocationEnabled ? _toggleLocationFollowing : null,
                      icon: Icon(
                        _isFollowingUser
                            ? Icons.gps_fixed
                            : Icons.gps_not_fixed,
                        color: _isFollowingUser ? Colors.blue : Colors.grey,
                      ),
                      tooltip: _isFollowingUser
                          ? 'Stop following location'
                          : 'Follow my location',
                    ),
                  ),
                ),

                // Building markers visibility toggle (appears below location button)
                Positioned(
                  top: 72,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: _showBuildings
                          ? 'Hide building markers'
                          : 'Show building markers',
                      onPressed: () =>
                          setState(() => _showBuildings = !_showBuildings),
                      icon: Icon(
                        _showBuildings
                            ? Icons.location_city
                            : Icons.location_off,
                        color:
                            _showBuildings ? AppTheme.primaryRed : Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Waypoint markers visibility toggle (appears below building toggle)
                if (widget.isAdmin)
                  Positioned(
                    top: 128,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        tooltip: _showWaypoints
                            ? 'Hide waypoint markers'
                            : 'Show waypoint markers',
                        onPressed: () =>
                            setState(() => _showWaypoints = !_showWaypoints),
                        icon: Icon(
                          _showWaypoints
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _showWaypoints ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                // Compass indicator (when following location)
                if (_isFollowingUser && _isLocationEnabled)
                  Positioned(
                    top: 16,
                    right: 72,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: _currentHeading * math.pi / 180,
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.red,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /* COMMENT START
          // Draggable buildings list
          DraggableScrollableSheet(
            initialChildSize: 0.15, // Initial height (15% of screen)
            minChildSize: 0.15,     // Minimum height (15% of screen)
            maxChildSize: 0.7,      // Maximum height (70% of screen)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 60,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    // List header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'HAU Buildings (${_buildings.length} buildings)',
                        style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Divider
                    const Divider(height: 1, thickness: 1),
                    
                    // Buildings list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _buildings.length,
                        itemBuilder: (context, index) {
                          final building = _buildings[index];
                          final hasOffices = (building['offices'] as List).isNotEmpty;
                          
                          return ListTile(
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              building['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: hasOffices 
                                ? Text(
                                    '${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuildingDetailPage(
                                    buildingName: building['name'] as String,
                                    buildingOffices: List<String>.from(building['offices'] as List),
                                    isAdmin: widget.isAdmin,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          */ //COMMENT END
        ],
      ),
      // Floating action button to show routes bottom sheet
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Admin controls FAB (only visible to admins)
          if (widget.isAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton(
                backgroundColor: AppTheme.primaryRed,
                onPressed: () => _showAdminControlsBottomSheet(context),
                child: const Icon(Icons.build, color: Colors.white),
                heroTag: 'adminControls',
              ),
            ),

          // Primary routes FAB
          FloatingActionButton(
            backgroundColor: AppTheme.primaryRed,
            onPressed: () => _showRoutesBottomSheet(context),
            child: const Icon(Icons.directions_walk, color: Colors.white),
            heroTag: 'routesFab',
          ),
        ],
      ),
      // Show a small stop-navigation button while in navigation mode
      persistentFooterButtons: _isNavigating
          ? [
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isNavigating = false;
                        _computedPath = [];
                        _currentNavigationTarget = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('STOP NAVIGATION',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  /// Shows the campus routes selection bottom sheet
  void _showRoutesBottomSheet(BuildContext context) {
    setState(() {
      _isRoutesSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRoutesBottomSheet(),
    ).whenComplete(() {
      // Bottom sheet closed
      if (mounted) {
        setState(() {
          _isRoutesSheetOpen = false;
        });
      }
    });
  }

  /// Builds the routes selection bottom sheet
  Widget _buildRoutesBottomSheet() {
    return Consumer<CampusRouteViewModel>(
      builder: (context, routeViewModel, child) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Center(
                      child: Text(
                        'Campus Walking Routes',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),

                  // Search field
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _routeSearchController,
                      style: const TextStyle(
                          color: Colors
                              .black), // Explicitly set text color to black
                      decoration: InputDecoration(
                        hintText: 'Search building...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _routeSearchQuery.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _routeSearchController.clear();
                                  setModalState(() => _routeSearchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (query) {
                        setModalState(() => _routeSearchQuery = query);
                      },
                    ),
                  ),

                  // Buildings list (replaces routes list) - same content/function as the draggable buildings list
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final filteredBuildings = _routeSearchQuery.isEmpty
                            ? _buildings
                            : _buildings.where((b) {
                                final name =
                                    (b['name'] as String).toLowerCase();
                                return name
                                    .contains(_routeSearchQuery.toLowerCase());
                              }).toList();

                        if (filteredBuildings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No buildings found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search term',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredBuildings.length,
                          itemBuilder: (context, index) {
                            final building = filteredBuildings[index];
                            final originalIndex = _buildings.indexWhere(
                                (b) => b['name'] == building['name']);

                            return Card(
                              elevation: 1,
                              color: Colors.white,
                              child: ListTile(
                                leading: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${originalIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  building['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle:
                                    (building['offices'] as List).isNotEmpty
                                        ? Text(
                                            '${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          )
                                        : null,
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () async {
                                  // First close the bottom sheet so the user returns to the full map
                                  Navigator.pop(modalContext);
                                  // Small delay to allow the sheet to dismiss cleanly before pushing a new route
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));
                                  // Then push the building detail page from the main MapPage context
                                  _pushBuildingDetailAndHandleNavigation(
                                    building['name'] as String,
                                    List<String>.from(
                                        building['offices'] as List),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Shows the admin controls bottom sheet (create/update/delete placeholders)
  void _showAdminControlsBottomSheet(BuildContext context) {
    // show admin bottom sheet (no local open-state tracked)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdminControlsBottomSheet(),
    );
  }

  /// Admin bottom sheet UI with placeholder buttons for managing entities
  Widget _buildAdminControlsBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Center(
              child: Text(
                'Admin Map Controls',
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buildings card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Buildings',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRed)),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Create building: not implemented'))),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Create',
                                            style: TextStyle(fontSize: 19)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Update building: not implemented'))),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Update',
                                            style: TextStyle(fontSize: 19)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent),
                                    onPressed: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Delete building: not implemented'))),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete',
                                        style: TextStyle(fontSize: 19)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Waypoints card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Waypoints',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRed)),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Create waypoint: not implemented'))),
                                        icon: const Icon(Icons.add_location),
                                        label: const Text('Create',
                                            style: TextStyle(fontSize: 19)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Update waypoint: not implemented'))),
                                        icon: const Icon(Icons.edit_location),
                                        label: const Text('Update',
                                            style: TextStyle(fontSize: 19)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent),
                                    onPressed: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Delete waypoint: not implemented'))),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete',
                                        style: TextStyle(fontSize: 19)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Connections card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connections (waypoint edges)',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRed)),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Create connection: not implemented'))),
                                        icon: const Icon(Icons.link),
                                        label: const Text('Create',
                                            style: TextStyle(fontSize: 19)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Update connection: not implemented'))),
                                        icon: const Icon(Icons.swap_horiz),
                                        label: const Text('Update',
                                            style: TextStyle(fontSize: 19)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent),
                                    onPressed: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Delete connection: not implemented'))),
                                    icon: const Icon(Icons.link_off),
                                    label: const Text('Delete',
                                        style: TextStyle(fontSize: 19)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to create markers for FlutterMap
  List<Marker> _buildMapMarkers() {
    // Building locations - coordinates will be updated from waypoints if mapped
    final List<Map<String, dynamic>> buildingLocations = [
      {
        'name': 'Entrance',
        'lat': 15.134110,
        'lng': 120.591074,
      },
      {
        'name': 'Plaza De Corazon Building (Red Bldg.)',
        'lat': 15.133481,
        'lng': 120.591565,
      },
      {
        'name': 'St. Martha Hall Building',
        'lat': 15.133413,
        'lng': 120.591356,
      },
      {
        'name': 'San Francisco De Javier Building (SFJ)',
        'lat': 15.133476,
        'lng': 120.590910,
      },
      {
        'name': 'St. Therese of Liseux Building (STL)',
        'lat': 15.132725,
        'lng': 120.590782,
      },
      {
        'name': 'Warehouse & Carpentry',
        'lat': 15.132813,
        'lng': 120.591278,
      },
      {
        'name': 'Yellow Food Court',
        'lat': 15.132709,
        'lng': 120.591195,
      },
      {
        'name': 'St. Gabriel Hall Building (SGH)',
        'lat': 15.132606,
        'lng': 120.591031,
      },
      {
        'name': 'St. Raphael Hall Building (SRH)',
        'lat': 15.132510,
        'lng': 120.590943,
      },
      {
        'name': 'St. Michael Hall Building (SMH)',
        'lat': 15.132375,
        'lng': 120.590819,
      },
      {
        'name': 'Geromin G. Nepomuceno Building (GGN)',
        'lat': 15.131868,
        'lng': 120.590666,
      },
      {
        'name': 'Peter G. Nepomuceno Building (PGN)',
        'lat': 15.132896,
        'lng': 120.590462,
      },
      {
        'name': 'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)',
        'lat': 15.133504,
        'lng': 120.590237,
      },
      {
        'name': 'Archbishop Pedro Santos Building (APS)',
        'lat': 15.131932,
        'lng': 120.589993,
      },
      {
        'name': 'Mamerto G. Nepomuceno Building (MGN)',
        'lat': 15.132849,
        'lng': 120.589848,
      },
      {
        'name': 'Chapel of the Holy Guardian Angel',
        'lat': 15.132406,
        'lng': 120.589615,
      },
      {
        'name': 'Sister Josefina Nepomuceno Formation Center',
        'lat': 15.132093,
        'lng': 120.589263,
      },
      {
        'name': 'St. Joseph Hall Building (SJH)',
        'lat': 15.132730,
        'lng': 120.589170,
      },
      {
        'name': 'Sacred Heart Building (SH)',
        'lat': 15.131427,
        'lng': 120.589545,
      },
      {
        'name': 'Covered Court',
        'lat': 15.131862,
        'lng': 120.589127,
      },
      {
        'name': 'Immaculate Heart Gymnasium',
        'lat': 15.131961,
        'lng': 120.588944,
      },
      {
        'name': 'Immaculate Heart Gymnasium Annex',
        'lat': 15.132334,
        'lng': 120.588711,
      },
    ];

    // Populate graph node positions for later shortest-path usage
    // If a building is mapped to a waypoint in wpdata.buildingToWaypoints,
    // place its marker at the waypoint coordinates but DO NOT add a separate
    // graph node for the building. Routing will target the waypoint key
    // instead (single source of truth), which avoids duplicate edges.
    for (var b in buildingLocations) {
      final name = b['name'] as String;
      try {
        final mapped = wpdata.buildingToWaypoints[name];
        if (mapped != null &&
            mapped.isNotEmpty &&
            _graphNodes.containsKey(mapped.first)) {
          final wp = _graphNodes[mapped.first]!;
          b['lat'] = wp.latitude;
          b['lng'] = wp.longitude;
          // Skip adding a separate graph node for this building; the waypoint
          // node will be used for routing instead.
          continue;
        }
      } catch (_) {}

      // Add building as graph node when no waypoint mapping exists
      _graphNodes[b['name'] as String] = LatLng(b['lat'], b['lng']);
    }

    // -----------------------------------------------------------------
    // CUSTOM PATHWAYS (optional)
    // If you have a hand-drawn or surveyed pedestrian path network (preferred
    // for accuracy), add your additional waypoint nodes here. These should be
    // named uniquely and assigned LatLng coordinates. Example:
    //
    // _graphNodes['walkway_node_1'] = LatLng(15.1330, 120.5905);
    // _graphNodes['walkway_node_2'] = LatLng(15.1332, 120.5907);
    //
    // After adding custom nodes, you can either rely on the auto-generation
    // in `_initializeGraphData()` (it will connect nearest neighbors), or
    // you can manually define exact edges in `_graphEdges` (recommended for
    // precise walkway shapes). See `_initializeGraphData()` comments below
    // for an example of how to manually define edges.
    // Example waypoint nodes (replace these with your surveyed walkway waypoints)
    // These are small examples placed near existing buildings and will be used
    // to create more realistic pedestrian routes when connected via edges.
    // You can add as many as you need; use descriptive names.
    // Merge waypoint nodes from external data file (edit lib/data/waypoints.dart)

    // -----------------------------------------------------------------

    return buildingLocations
        .where((building) => building['lat'] != null && building['lng'] != null)
        .map((building) {
      return Marker(
        point: LatLng(building['lat'], building['lng']),
        width: 80.0,
        height: 80.0,
        // rotate with the map so building markers follow map rotation
        rotate: true,
        child: GestureDetector(
          onTap: () async {
            // Close the routes bottom sheet if it's open so the user returns to the full map
            if (_isRoutesSheetOpen) {
              try {
                Navigator.of(context).pop();
                // allow the modal dismissal animation to complete
                await Future.delayed(const Duration(milliseconds: 150));
              } catch (_) {}
            }

            // Do not compute path here. Path computation should occur only when
            // the user explicitly confirms navigation (START NAVIGATION) in the
            // BuildingDetailPage. This avoids starting routing prematurely.
            // Then navigate to the building detail page
            final buildingData = _buildings.firstWhere(
              (b) => b['name'] == building['name'],
              orElse: () => {'name': building['name'], 'offices': []},
            );

            _pushBuildingDetailAndHandleNavigation(
              building['name'],
              List<String>.from(buildingData['offices'] as List),
            );
          },
          //LOCATION POINTS
          child: Transform.rotate(
            angle: _isFollowingUser ? _currentHeading * math.pi / 180 : 0,
            child: Column(
              children: [
                _buildBuildingMarkerIcon(
                    building['name'] as String), // <-- ICON DISPLAYED HERE
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getAbbreviatedName(building['name']),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Initializes dummy graph edges connecting nearby buildings.
  // This creates a fully connected-ish local graph by linking each node to a few nearest neighbors.
  Future<void> _initializeGraphData() async {
    // Clear any existing
    _graphNodes.clear();
    _graphEdges.clear();

    // Fetch waypoints and edges from Supabase
    final waypoints = await WaypointService().fetchWaypoints();
    final edges = await EdgeService().fetchEdges();

    // Convert waypoints to Map<String, LatLng>
    setState(() {
      for (var wp in waypoints) {
        _graphNodes[wp.waypointKey] = LatLng(wp.latitude, wp.longitude);
      }

      // Convert edges to Map<String, Map<String, double>>
      for (var edge in edges) {
        _graphEdges.putIfAbsent(edge.fromWaypoint, () => {});
        _graphEdges[edge.fromWaypoint]![edge.toWaypoint] = edge.distanceMeters;
      }
    });

    // -----------------------------------------------------------------
    // MANUAL EDGE DEFINITION (optional, recommended for accurate paths)
    //
    // If you have a precise pedestrian graph (waypoints and explicit edges),
    // you can override or augment the auto-generated edges here. Example:
    //
    // _graphEdges['walkway_node_1'] = {
    //   'walkway_node_2': Distance().as(LengthUnit.Meter, _graphNodes['walkway_node_1']!, _graphNodes['walkway_node_2']!),
    //   'walkway_node_3': Distance().as(LengthUnit.Meter, _graphNodes['walkway_node_1']!, _graphNodes['walkway_node_3']!),
    // };
    // _graphEdges['walkway_node_2'] = {
    //   'walkway_node_1': ...,
    //   'walkway_node_4': ...,
    // };
    //
    // Important: ensure both directions are present when you want bidirectional
    // travel, or add reverse edges explicitly as shown above.
    // -----------------------------------------------------------------

    // Note: building->waypoint connections are intentionally NOT added here.
    // Buildings that are mapped to waypoints are represented by the waypoint
    // node (see _buildMapMarkers). Routing will target the waypoint key
    // instead of creating separate building nodes/edges. This avoids
    // duplicated edges and keeps the waypoint the single source of truth.
  }

  // Dijkstra's algorithm to find shortest path between two node names
  List<String> _dijkstra(String startNode, String targetNode) {
    final distances = <String, double>{};
    final previous = <String, String?>{};
    final nodes = <String>{}..addAll(_graphNodes.keys);

    for (var n in nodes) {
      distances[n] = double.infinity;
      previous[n] = null;
    }
    distances[startNode] = 0.0;

    while (nodes.isNotEmpty) {
      // get node with smallest tentative distance
      String u = nodes.reduce((a, b) =>
          (distances[a] ?? double.infinity) < (distances[b] ?? double.infinity)
              ? a
              : b);
      nodes.remove(u);

      if (u == targetNode) break;

      final neighbors = _graphEdges[u];
      if (neighbors == null) continue;

      for (final entry in neighbors.entries) {
        final v = entry.key;
        if (!distances.containsKey(v)) continue;
        final alt = (distances[u] ?? double.infinity) + entry.value;
        if (alt < (distances[v] ?? double.infinity)) {
          distances[v] = alt;
          previous[v] = u;
        }
      }
    }

    // Reconstruct path
    final path = <String>[];
    String? u = targetNode;
    if (previous[u] != null || u == startNode) {
      while (u != null) {
        path.insert(0, u);
        u = previous[u];
      }
    }
    return path;
  }

  /// Dynamically adjust the path based on user's current position
  void _adjustPathDynamically() {
    if (_currentPosition == null || _computedPath.isEmpty) return;

    final currentPos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    const double proximityThreshold = 15.0; // 15 meters
    const double deviationThreshold = 50.0; // 50 meters

    // Check if user is close to any point in the computed path
    bool foundClosePoint = false;
    int closestPointIndex = -1;
    double closestDistance = double.infinity;

    for (int i = 0; i < _computedPath.length; i++) {
      final pathPoint = _computedPath[i];
      final distance = Distance().as(LengthUnit.Meter, currentPos, pathPoint);

      if (distance < proximityThreshold && distance < closestDistance) {
        closestDistance = distance;
        closestPointIndex = i;
        foundClosePoint = true;
      }
    }

    if (foundClosePoint && closestPointIndex > 0) {
      // User is close to a point in the path, remove previous points
      debugPrint('User reached point $closestPointIndex, reducing path');
      setState(() {
        _computedPath = [
          currentPos,
          ..._computedPath.sublist(closestPointIndex + 1)
        ];
      });
    } else {
      // Check if user has deviated significantly from the path
      double minDistanceToPath = double.infinity;
      for (final pathPoint in _computedPath) {
        final distance = Distance().as(LengthUnit.Meter, currentPos, pathPoint);
        if (distance < minDistanceToPath) {
          minDistanceToPath = distance;
        }
      }

      if (minDistanceToPath > deviationThreshold) {
        // User has deviated from path, recalculate
        debugPrint(
            'User deviated from path (${minDistanceToPath.toStringAsFixed(1)}m), recalculating');
        _computePathFromCurrentTo(_currentNavigationTarget!);
      }
    }
  }

  // Compute shortest path from current location to a building name and set _computedPath
  void _computePathFromCurrentTo(String buildingName) {
    if (_currentPosition == null) {
      // No user location; cannot compute path
      return;
    }

    // Find the target waypoint key for this building (if mapped)
    String targetNode = 'wp_Entrance'; // Default to Entrance if not found
    try {
      String normalizedName = buildingName.trim();
      final mapped = wpdata.buildingToWaypoints[normalizedName];
      if (mapped != null && mapped.isNotEmpty) {
        targetNode = mapped.first; // Use the mapped waypoint key
      }
    } catch (_) {}

    debugPrint('All graph node keys: ${_graphNodes.keys.toList()}');
    debugPrint('Target node for $buildingName: $targetNode');

    // Ensure target node exists in graph
    if (!_graphNodes.containsKey(targetNode)) {
      debugPrint('Target node $targetNode not found in graph');
      return;
    }

    // Find nearest graph node to current position (only from waypoints, not buildings)
    final currentPos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    String? nearestNodeToUser;
    double nearestDist = double.infinity;

    // Only consider waypoint nodes (exclude building nodes that aren't mapped to waypoints)
    for (final entry in _graphNodes.entries) {
      final pos = entry.value;
      final d = Distance().as(LengthUnit.Meter, currentPos, pos);
      if (d < nearestDist) {
        nearestDist = d;
        nearestNodeToUser = entry.key;
      }
    }

    if (nearestNodeToUser == null) {
      debugPrint('No nearest waypoint found');
      return;
    }

    debugPrint('Computing nearest path from $nearestNodeToUser to $targetNode');
    final nodePath = _dijkstra(nearestNodeToUser, targetNode);

    if (nodePath.isEmpty) {
      debugPrint('No path found between $nearestNodeToUser and $targetNode');
      return;
    }

    // Convert nodePath to LatLng list
    final nodePositions = <LatLng>[];
    // Start with the user's exact current location
    nodePositions.add(currentPos);

    // Add each waypoint in the path
    for (final node in nodePath) {
      final pos = _graphNodes[node];
      if (pos != null) {
        nodePositions.add(pos);
      }
    }

    // Use the path as-is without densification to preserve exact waypoint routing
    setState(() {
      _computedPath = nodePositions;
      _currentNavigationTarget = buildingName;
    });

    debugPrint('Path computed with ${nodePositions.length} points');
  }

  // Push the BuildingDetailPage and await a navigation request result.
  // If the detail page returns a building name (when user taps START NAVIGATION),
  // compute and display the shortest path to that building.
  Future<void> _pushBuildingDetailAndHandleNavigation(
      String buildingName, List<String> offices) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingDetailPage(
          buildingName: buildingName,
          buildingOffices: offices,
          isAdmin: widget.isAdmin,
        ),
      ),
    );

    if (result is String && result.isNotEmpty) {
      // result is the building name requested for navigation
      // Enter navigation mode and clear any selected campus route so the computed path is visible immediately
      setState(() {
        _isNavigating = true;
        // Clear selection in the viewmodel (notify listeners)
        try {
          context.read<CampusRouteViewModel>().clearSelection();
        } catch (_) {}
      });

      // Compute path from current location to requested building
      // The _computePathFromCurrentTo method will handle waypoint mapping internally
      _computePathFromCurrentTo(result);
    }
  }

  // Resolve the asset path for a building's logo in assets/building_logo
  String? _buildingLogoAsset(String fullName) {
    // Use contains to match names that include abbreviations in parentheses
    if (fullName.contains('Plaza De Corazon'))
      return 'assets/building_logo/Plaza De Corazon Building.png';
    if (fullName.contains('St. Martha Hall'))
      return 'assets/building_logo/St. Martha Hall Building.png';
    if (fullName.contains('San Francisco De Javier'))
      return 'assets/building_logo/San Francisco De Javier Building.png';
    if (fullName.contains('St. Therese of Liseux'))
      return 'assets/building_logo/St. Therese of Liseux Building.png';
    if (fullName.contains('Warehouse'))
      return 'assets/building_logo/WareHouse and Carpentry.png';
    if (fullName.contains('St. Gabriel Hall'))
      return 'assets/building_logo/St. Gabriel Hall Building.png';
    if (fullName.contains('St. Raphael Hall'))
      return 'assets/building_logo/St. Raphael Hall Building.png';
    if (fullName.contains('St. Michael Hall'))
      return 'assets/building_logo/St. Michael Hall Building.png';
    if (fullName.contains('Geromin G. Nepomuceno'))
      return 'assets/building_logo/Geromin G. Nepomuceno Building.png';
    if (fullName.contains('Peter G. Nepomuceno'))
      return 'assets/building_logo/Peter G. Nepomuceno Building.png';
    if (fullName.contains('Don Juan D. Nepomuceno'))
      return 'assets/building_logo/Don Juan D. Nepomuceno Building.png';
    if (fullName.contains('Archbishop Pedro Santos'))
      return 'assets/building_logo/Archbishop Pedro Santos Building.png';
    if (fullName.contains('Mamerto G. Nepomuceno'))
      return 'assets/building_logo/Mamerto G. Nepomuceno Building.png';
    if (fullName.contains('Chapel of the Holy Guardian Angel') ||
        fullName.contains('Chapel Of The Holy Guardian Angel')) {
      return 'assets/building_logo/Chapel Of The Holy Guardian Angel.png';
    }
    if (fullName.contains('Sister Josefina Nepomuceno Formation Center')) {
      return 'assets/building_logo/Sister Josefina Nepomuceno Formation Center.png';
    }
    if (fullName.contains('St. Joseph Hall'))
      return 'assets/building_logo/St. Joseph Hall Building.png';
    if (fullName.contains('Sacred Heart'))
      return 'assets/building_logo/Sacred Heart Building.png';
    if (fullName.contains('Covered Court'))
      return 'assets/building_logo/Covered Court.png';
    if (fullName.contains('Immaculate Heart Gymnasium Annex'))
      return 'assets/building_logo/Immaculate Heart Gymnasium Annex.png';
    if (fullName.contains('Immaculate Heart Gymnasium'))
      return 'assets/building_logo/Immaculate Heart Gymnasium.png';
    if (fullName.contains('Yellow Food Court'))
      return 'assets/building_logo/Yellow Food Court.png';
    return null;
  }

  // Build a marker widget using the building logo with a circular style and white border
  Widget _buildBuildingMarkerIcon(String buildingName) {
    final asset = _buildingLogoAsset(buildingName);
    if (asset == null) {
      // Fallback to current yellow dot style
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.primaryYellow,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to yellow dot if asset not found
          return Container(
            color: AppTheme.primaryYellow,
            child: const Icon(Icons.location_on, color: Colors.white),
          );
        },
      ),
    );
  }

  String _getAbbreviatedName(String fullName) {
    // Return abbreviated names for map markers (arranged in same order as _buildings list)
    if (fullName.contains('Plaza De Corazon')) return 'Red Bldg.';
    if (fullName.contains('St. Martha Hall')) return 'SMH Hall';
    if (fullName.contains('San Francisco De Javier')) return 'SFJ';
    if (fullName.contains('St. Therese of Liseux')) return 'STL';
    if (fullName.contains('Warehouse & Carpentry')) return 'Warehouse';
    if (fullName.contains('St. Gabriel Hall')) return 'SGH';
    if (fullName.contains('St. Raphael Hall')) return 'SRH';
    if (fullName.contains('St. Michael Hall')) return 'SMH';
    if (fullName.contains('Geromin G. Nepomuceno')) return 'GGN';
    if (fullName.contains('Peter G. Nepomuceno')) return 'PGN';
    if (fullName.contains('Don Juan D. Nepomuceno')) return 'Main Bldg.';
    if (fullName.contains('Archbishop Pedro Santos')) return 'APS';
    if (fullName.contains('Mamerto G. Nepomuceno')) return 'MGN';
    if (fullName.contains('Chapel of the Holy Guardian Angel')) return 'Chapel';
    if (fullName.contains('Sister Josefina Nepomuceno Formation Center'))
      return 'Formation';
    if (fullName.contains('St. Joseph Hall')) return 'SJH';
    if (fullName.contains('Sacred Heart')) return 'SH';
    if (fullName.contains('Covered Court')) return 'Court';
    if (fullName.contains('Immaculate Heart Gymnasium Annex'))
      return 'Gym Annex';
    if (fullName.contains('Immaculate Heart Gymnasium')) return 'Gymnasium';
    if (fullName.contains('Yellow Food Court')) return 'Food Court';

    // Fallback: return first 2 words for any unmatched buildings
    final words = fullName.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}' : fullName;
  }

  /// Attempt to recompute the shortest path when the user moves.
  /// Uses simple guards to avoid spamming computation on every small position update.
  void _maybeRecomputePathOnMove() {
    if (!_isNavigating ||
        _currentNavigationTarget == null ||
        _currentPosition == null) return;

    final now = DateTime.now();

    // Prevent concurrent recomputes
    if (_isComputingPath) return;

    // Throttle by time
    if (_lastPathComputeTime != null) {
      final since = now.difference(_lastPathComputeTime!);
      if (since < _minRecomputeInterval) return;
    }

    final currentPos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    // Throttle by movement distance
    if (_lastPathComputePosition != null) {
      final dist = Distance()
          .as(LengthUnit.Meter, _lastPathComputePosition!, currentPos);
      if (dist < _minRecomputeDistanceMeters) return;
    }

    // Passed guards: recompute path
    _isComputingPath = true;
    _lastPathComputeTime = now;
    _lastPathComputePosition = currentPos;

    // Run recompute asynchronously and clear the computing flag when done
    Future.microtask(() {
      try {
        _computePathFromCurrentTo(_currentNavigationTarget!);
      } catch (e) {
        debugPrint('Error recomputing path: $e');
      } finally {
        _isComputingPath = false;
      }
    });
  }
}
