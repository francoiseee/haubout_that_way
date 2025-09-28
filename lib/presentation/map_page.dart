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
import 'package:hau_navigation_app/widgets/hau_logo.dart';
import 'package:hau_navigation_app/viewmodels/campus_route_viewmodel.dart';
import 'package:hau_navigation_app/models/campus_route.dart';



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
  final Map<String, Map<String, double>> _graphEdges = {}; // name -> (neighbor -> distance)

  // Computed shortest path polyline (displayed on map)
  List<LatLng> _computedPath = [];
  // Whether the user has started a navigation session from BuildingDetailPage
  bool _isNavigating = false;
  // Track whether the routes bottom sheet is currently open so marker taps can safely close it
  bool _isRoutesSheetOpen = false;

  final List<Map<String, dynamic>> _buildings = [
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
      'offices': ['President\'s Office', 'University Library', 'University Theater'],
    },
    {
      'name': 'St. Therese of Liseux Building (STL)',
      'offices': ['School of Hospitality and Tourism Management Dean\'s Office'],
    },
    {
      'name': 'Warehouse & Carpentry',
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
    {
      'name': 'Yellow Food Court',
      'offices': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _initializeLocationTracking();
    _initializeCompassTracking();
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
      debugPrint('Got initial position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
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
      debugPrint('Position update: ${position.latitude}, ${position.longitude}');
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
    });
  }

  /// Initialize compass/heading tracking
  void _initializeCompassTracking() {
    _compassStreamSubscription = FlutterCompass.events?.listen((CompassEvent event) {
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
          // Inner circle with icon
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: const Icon(
              Icons.person,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Increased to 100px for more noticeable height
        child: Container(
          height: 100.0, // Explicit height to ensure container uses full height
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Added vertical padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  
                  // Title with logo
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HauLogoWidget(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'HAUbout That Way',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Empty space to balance the back button
                  const SizedBox(width: 48), // Same width as IconButton
                ],
              ),
            ),
          ),
        ),
      ),
      
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
                    debugPrint('Map Consumer rebuild - selectedRoute: ${selectedRoute?.id ?? 'null'}, _isNavigating: $_isNavigating');

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

                    return FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(15.132896, 120.590068), // HAU coordinates
                        initialZoom: 17.0,
                        minZoom: 15.0,
                        maxZoom: 19.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.hau.navigation_app',
                          additionalOptions: const {
                            'attribution': '© OpenStreetMap contributors © CARTO',
                          },
                        ),
                        // Route polylines layer
                            PolylineLayer(polylines: polylines),
                            // Computed shortest path (if any)
                            if (_computedPath.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _computedPath,
                                    color: Colors.black,
                                    strokeWidth: 4.0,
                                  ),
                                ],
                              ),
                        // Building markers layer
                        MarkerLayer(
                          markers: [
                            ..._buildMapMarkers(),
                            if (_buildUserLocationMarker() != null) _buildUserLocationMarker()!,
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
                      onPressed: _isLocationEnabled ? _toggleLocationFollowing : null,
                      icon: Icon(
                        _isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
                        color: _isFollowingUser ? Colors.blue : Colors.grey,
                      ),
                      tooltip: _isFollowingUser ? 'Stop following location' : 'Follow my location',
                    ),
                  ),
                ),

                // Compass indicator (when following location)
                if (_isFollowingUser && _isLocationEnabled)
                  Positioned(
                    top: 70,
                    right: 16,
                    child: Container(
                      width: 40,
                      height: 40,
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
                          size: 20,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: () => _showRoutesBottomSheet(context),
        child: const Icon(
          Icons.directions_walk,
          color: Colors.white,
        ),
      ),
      // Show a small stop-navigation button while in navigation mode
      persistentFooterButtons: _isNavigating
          ? [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isNavigating = false;
                    _computedPath = [];
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('STOP NAVIGATION', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Campus Walking Routes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            routeViewModel.clearSelection();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Clear Route',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _routeSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search building...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _routeSearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                final name = (b['name'] as String).toLowerCase();
                                return name.contains(_routeSearchQuery.toLowerCase());
                              }).toList();

                        if (filteredBuildings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
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
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                            final originalIndex = _buildings.indexWhere((b) => b['name'] == building['name']);

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
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: (building['offices'] as List).isNotEmpty
                                    ? Text(
                                        '${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      )
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () async {
                                  // First close the bottom sheet so the user returns to the full map
                                  Navigator.pop(modalContext);
                                  // Small delay to allow the sheet to dismiss cleanly before pushing a new route
                                  await Future.delayed(const Duration(milliseconds: 150));
                                  // Then push the building detail page from the main MapPage context
                                  _pushBuildingDetailAndHandleNavigation(
                                    building['name'] as String,
                                    List<String>.from(building['offices'] as List),
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

  // Method to create markers for FlutterMap
  List<Marker> _buildMapMarkers() {
    final List<Map<String, dynamic>> buildingLocations = [
      {
        'name': 'Plaza De Corazon Building (Red Bldg.)',
        'lat': 15.1335221,
        'lng': 120.5915192,
      },
      {
        'name': 'St. Martha Hall Building',
        'lat': 15.1335027,
        'lng': 120.5913140,
      },
      {
        'name': 'San Francisco De Javier Building (SFJ)',
        'lat': 15.1332956,
        'lng': 120.5910619,
      },
      {
        'name': 'St. Therese of Liseux Building (STL)',
        'lat': 15.1329745,
        'lng': 120.5907199,
      },
      {
        'name': 'Warehouse & Carpentry',
        'lat': 15.1327751,
        'lng': 120.5913167,
      },
      {
        'name': 'Yellow Food Court',
        'lat': 15.1326625,
        'lng': 120.5912362,
      },
      {
        'name': 'St. Gabriel Hall Building (SGH)',
        'lat': 15.1325564,
        'lng': 120.5910914,
      },
      {
        'name': 'St. Raphael Hall Building (SRH)',
        'lat': 15.1324696,
        'lng': 120.5909626,
      },
      {
        'name': 'St. Michael Hall Building (SMH)',
        'lat': 15.1323415,
        'lng': 120.5908486,
      },
      {
        'name': 'Geromin G. Nepomuceno Building (GGN)',
        'lat': 15.1318210,
        'lng': 120.5906072,
      },
      {
        'name': 'Peter G. Nepomuceno Building (PGN)',
        'lat': 15.1327337,
        'lng': 120.5902787,
      },
      {
        'name': 'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)',
        'lat': 15.1333318,
        'lng': 120.5900279,
      },
      {
        'name': 'Archbishop Pedro Santos Building (APS)',
        'lat': 15.1319259,
        'lng': 120.5900547,
      },
      {
        'name': 'Mamerto G. Nepomuceno Building (MGN)',
        'lat': 15.1330276,
        'lng': 120.5896483,
      },
      {
        'name': 'Chapel of the Holy Guardian Angel',
        'lat': 15.1323363,
        'lng': 120.5895504,
      },
      {
        'name': 'Sister Josefina Nepomuceno Formation Center',
        'lat': 15.1321188,
        'lng': 120.5892929,
      },
      {
        'name': 'St. Joseph Hall Building (SJH)',
        'lat': 15.1327596,
        'lng': 120.5891039,
      },
      {
        'name': 'Sacred Heart Building (SH)',
        'lat': 15.131490,
        'lng': 120.589398,
      },
      {
        'name': 'Covered Court',
        'lat': 15.131676,
        'lng': 120.589124,
      },
      {
        'name': 'Immaculate Heart Gymnasium',
        'lat': 15.132033,
        'lng': 120.588652,
      },
      {
        'name': 'Immaculate Heart Gymnasium Annex',
        'lat': 15.132331,
        'lng': 120.588671,
      },

    ];

    // Populate graph node positions for later shortest-path usage
    for (var b in buildingLocations) {
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
  _graphNodes['wp_north_path_1'] = const LatLng(15.13345, 120.59142);
  _graphNodes['wp_north_path_2'] = const LatLng(15.13330, 120.59110);
  _graphNodes['wp_central_1'] = const LatLng(15.13290, 120.59050);
  _graphNodes['wp_south_1'] = const LatLng(15.13220, 120.58990);

  // -----------------------------------------------------------------

    return buildingLocations
        .where((building) => building['lat'] != null && building['lng'] != null)
        .map((building) {
      return Marker(
        point: LatLng(building['lat'], building['lng']),
        width: 80.0,
        height: 80.0,
        rotate: true, // This makes the marker rotate with the map
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
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
  void _initializeGraphData() {
    // Clear any existing
    _graphEdges.clear();

    // Compute neighbor distances and connect each node to its 3 nearest neighbors
    final names = _graphNodes.keys.toList();
    for (final name in names) {
      final pos = _graphNodes[name]!;
      // compute distances to other nodes
      final distances = <String, double>{};
      for (final other in names) {
        if (other == name) continue;
        final otherPos = _graphNodes[other]!;
        final d = Distance().as(LengthUnit.Meter, pos, otherPos);
        distances[other] = d;
      }
      // sort by distance and take up to 4 nearest neighbors
      final nearest = distances.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      _graphEdges[name] = {};
      for (var i = 0; i < math.min(4, nearest.length); i++) {
        final neighbor = nearest[i];
        _graphEdges[name]![neighbor.key] = neighbor.value;
        // Also ensure reverse edge exists
        _graphEdges.putIfAbsent(neighbor.key, () => {});
        _graphEdges[neighbor.key]![name] = neighbor.value;
      }
    }

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

    // Example manual edges connecting example waypoints and nearby buildings
    // (These augment the auto-generated nearest-neighbor graph above.)
    try {
      // ensure maps exist
      _graphEdges.putIfAbsent('wp_north_path_1', () => {});
      _graphEdges.putIfAbsent('wp_north_path_2', () => {});
      _graphEdges.putIfAbsent('wp_central_1', () => {});
      _graphEdges.putIfAbsent('wp_south_1', () => {});

      // Connect north path nodes
      _graphEdges['wp_north_path_1']!['wp_north_path_2'] = Distance().as(
        LengthUnit.Meter,
        _graphNodes['wp_north_path_1']!,
        _graphNodes['wp_north_path_2']!,
      );
      _graphEdges['wp_north_path_2']!['wp_north_path_1'] = _graphEdges['wp_north_path_1']!['wp_north_path_2']!;

      // Connect north path to central
      _graphEdges['wp_north_path_2']!['wp_central_1'] = Distance().as(
        LengthUnit.Meter,
        _graphNodes['wp_north_path_2']!,
        _graphNodes['wp_central_1']!,
      );
      _graphEdges['wp_central_1']!['wp_north_path_2'] = _graphEdges['wp_north_path_2']!['wp_central_1']!;

      // Connect central to south
      _graphEdges['wp_central_1']!['wp_south_1'] = Distance().as(
        LengthUnit.Meter,
        _graphNodes['wp_central_1']!,
        _graphNodes['wp_south_1']!,
      );
      _graphEdges['wp_south_1']!['wp_central_1'] = _graphEdges['wp_central_1']!['wp_south_1']!;

      // Connect central waypoint to a nearby building (example: PGN)
      if (_graphNodes.containsKey('Peter G. Nepomuceno Building (PGN)')) {
        _graphEdges['wp_central_1']!['Peter G. Nepomuceno Building (PGN)'] = Distance().as(
          LengthUnit.Meter,
          _graphNodes['wp_central_1']!,
          _graphNodes['Peter G. Nepomuceno Building (PGN)']!,
        );
        _graphEdges.putIfAbsent('Peter G. Nepomuceno Building (PGN)', () => {});
        _graphEdges['Peter G. Nepomuceno Building (PGN)']!['wp_central_1'] = _graphEdges['wp_central_1']!['Peter G. Nepomuceno Building (PGN)']!;
      }
    } catch (e) {
      debugPrint('Error creating manual graph edges: $e');
    }
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
      String u = nodes.reduce((a, b) => (distances[a] ?? double.infinity) < (distances[b] ?? double.infinity) ? a : b);
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

  // Compute shortest path from current location to a building name and set _computedPath
  void _computePathFromCurrentTo(String buildingName) {
    if (_currentPosition == null) {
      // No user location; cannot compute path
      return;
    }

    // Find nearest graph node to current position
    final currentPos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    String? nearestNodeToUser;
    double nearestDist = double.infinity;
    _graphNodes.forEach((name, pos) {
      final d = Distance().as(LengthUnit.Meter, currentPos, pos);
      if (d < nearestDist) {
        nearestDist = d;
        nearestNodeToUser = name;
      }
    });

    if (nearestNodeToUser == null) return;

    // If the target building isn't a node, abort
    if (!_graphNodes.containsKey(buildingName)) return;

    final nodePath = _dijkstra(nearestNodeToUser!, buildingName);
    // Convert nodePath to LatLng list
    final nodePositions = <LatLng>[];
    // start with the user's exact current location
    nodePositions.add(currentPos);
    for (final node in nodePath) {
      final pos = _graphNodes[node];
      if (pos != null) nodePositions.add(pos);
    }

    // Densify path and insert small 'turn' offsets to mimic pedestrian walkways
    final densified = _densifyPathWithTurns(nodePositions);

    setState(() {
      _computedPath = densified;
    });
  }

  // Insert intermediate points between nodes to create turns and make the
  // resulting polyline follow more natural pedestrian-like routes.
  // Strategy: for each segment A->B, add a midpoint and a small perpendicular
  // offset from the straight line (alternating sides) so the line bends around
  // obstacles. The offset distance is proportional to the segment length but
  // clamped to a small value (e.g., 4-12 meters).
  List<LatLng> _densifyPathWithTurns(List<LatLng> nodes) {
    if (nodes.length < 2) return nodes;
    final densified = <LatLng>[];
    final Distance dist = Distance();
    bool alternate = false;

    for (var i = 0; i < nodes.length - 1; i++) {
      final a = nodes[i];
      final b = nodes[i + 1];
      densified.add(a);

      // compute straight distance in meters
      final segLen = dist.as(LengthUnit.Meter, a, b);
      // proportionally sized offset, clamped
      final offsetMeters = (segLen * 0.12).clamp(4.0, 12.0);

      // compute midpoint
      final midLat = (a.latitude + b.latitude) / 2.0;
      final midLng = (a.longitude + b.longitude) / 2.0;

      // vector from a->b in degrees
      final dx = b.longitude - a.longitude;
      final dy = b.latitude - a.latitude;

      // perpendicular vector (normalize, then scale by offsetMeters converted approx to degrees)
      final lengthDeg = math.sqrt(dx * dx + dy * dy);
      double nx = 0.0, ny = 0.0;
      if (lengthDeg != 0) {
        nx = -dy / lengthDeg;
        ny = dx / lengthDeg;
      }

      // convert offset meters to degrees roughly (1 deg lat ~ 111_000 m)
      final metersPerDegLat = 111000.0;
      final metersPerDegLng = (111000.0 * math.cos(midLat * math.pi / 180));
      final offsetDegLat = (ny * offsetMeters) / metersPerDegLat;
      final offsetDegLng = (nx * offsetMeters) / (metersPerDegLng == 0 ? metersPerDegLat : metersPerDegLng);

      // alternate sides so path zig-zags a bit and looks less straight
      final side = alternate ? 1.0 : -1.0;
      alternate = !alternate;

      final turnPoint = LatLng(midLat + side * offsetDegLat, midLng + side * offsetDegLng);

      // Insert a small corner before and after the turn to make the bend visible
      final preTurn = LatLng((a.latitude + turnPoint.latitude) / 2.0, (a.longitude + turnPoint.longitude) / 2.0);
      final postTurn = LatLng((turnPoint.latitude + b.latitude) / 2.0, (turnPoint.longitude + b.longitude) / 2.0);

      densified.add(preTurn);
      densified.add(turnPoint);
      densified.add(postTurn);
    }

    // ensure the final node is included
    densified.add(nodes.last);
    return densified;
  }

  // Push the BuildingDetailPage and await a navigation request result.
  // If the detail page returns a building name (when user taps START NAVIGATION),
  // compute and display the shortest path to that building.
  Future<void> _pushBuildingDetailAndHandleNavigation(String buildingName, List<String> offices) async {
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
      _computePathFromCurrentTo(result);
    }
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
    if (fullName.contains('Sister Josefina Nepomuceno Formation Center')) return 'Formation';
    if (fullName.contains('St. Joseph Hall')) return 'SJH';
    if (fullName.contains('Sacred Heart')) return 'SH';
    if (fullName.contains('Covered Court')) return 'Court';
    if (fullName.contains('Immaculate Heart Gymnasium Annex')) return 'Gym Annex';
    if (fullName.contains('Immaculate Heart Gymnasium')) return 'Gymnasium';
    if (fullName.contains('Yellow Food Court')) return 'Food Court';
    
    // Fallback: return first 2 words for any unmatched buildings
    final words = fullName.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}' : fullName;
  }
}