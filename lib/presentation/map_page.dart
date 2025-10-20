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
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:hau_navigation_app/presentation/building_detail_page.dart';
import 'package:hau_navigation_app/presentation/admin_buildings_update_page.dart';
import 'package:hau_navigation_app/presentation/admin_buildings_read_page.dart';
import 'package:hau_navigation_app/presentation/admin_buildings_delete_page.dart';
import 'package:hau_navigation_app/widgets/custom_app_bar.dart';
import 'package:hau_navigation_app/viewmodels/campus_route_viewmodel.dart';
import 'package:hau_navigation_app/models/campus_route.dart';
import 'package:hau_navigation_app/supabase_services/waypoint_service.dart';
import 'package:hau_navigation_app/supabase_services/edge_service.dart';
import 'package:hau_navigation_app/presentation/admin_connections_update_page.dart';
import 'package:hau_navigation_app/presentation/admin_connections_read_page.dart';
import 'package:hau_navigation_app/presentation/admin_connections_delete_page.dart';
import 'package:hau_navigation_app/presentation/admin_waypoints_update_page.dart';
import 'package:hau_navigation_app/presentation/admin_waypoints_read_page.dart';
import 'package:hau_navigation_app/presentation/admin_waypoints_delete_page.dart';
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

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassStreamSubscription;
  double _currentHeading = 0.0;
  bool _isLocationEnabled = false;
  bool _locationStreamStarted = false;
  bool _locationInitInProgress = false;
  bool _isFollowingUser = false;

  final TextEditingController _routeSearchController = TextEditingController();
  String _routeSearchQuery = '';

  final Map<String, LatLng> _graphNodes = {};
  final Map<String, Map<String, double>> _graphEdges = {};

  List<LatLng> _computedPath = [];
  bool _isNavigating = false;
  String? _currentNavigationTarget;
  bool _isComputingPath = false;
  DateTime? _lastPathComputeTime;
  LatLng? _lastPathComputePosition;
  final Duration _minRecomputeInterval = const Duration(milliseconds: 800);
  final double _minRecomputeDistanceMeters = 1.0;
  bool _isRoutesSheetOpen = false;
  bool _showWaypoints = true;
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

  // Ensures button labels don't overflow in narrow screens
  Widget _responsiveLabel(String text) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      );

  @override
  void initState() {
    super.initState();
    // Initialize location after the first frame so permission prompts don't race.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLocationInitialized();
    });
    _initializeCompassTracking();
    _initializeGraphData();
    _routeSearchController.addListener(() {
      if (_routeSearchQuery != _routeSearchController.text) {
        setState(() {
          _routeSearchQuery = _routeSearchController.text;
        });
      }
    });

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
    final selectedRoute = context.watch<CampusRouteViewModel>().selectedRoute;

    if (selectedRoute != null && selectedRoute != _previousSelectedRoute) {
      _fitRouteOnMap(selectedRoute.polylinePoints);
      _previousSelectedRoute = selectedRoute;
    } else if (selectedRoute == null && _previousSelectedRoute != null) {
      _mapController.move(const LatLng(15.1341371, 120.5910619), 17.0);
      _previousSelectedRoute = null;
    }
  }

  void _fitRouteOnMap(List<LatLng> points) {
    if (points.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  Future<void> _initializeLocationTracking() async {
    if (_locationStreamStarted) return;

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

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
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

      if (_isFollowingUser && _currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _mapController.camera.zoom,
        );
      }

      if (_isNavigating && _currentNavigationTarget != null) {
        if (_computedPath.isNotEmpty) {
          _adjustPathDynamically();
        }

        _maybeRecomputePathOnMove();
      }
    });
    _locationStreamStarted = true;
  }

  Future<void> _ensureLocationInitialized() async {
    if (_locationInitInProgress) return;
    _locationInitInProgress = true;
    final bool isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

    try {
      // 1) Services
      if (!await Geolocator.isLocationServiceEnabled()) {
        debugPrint('Location services are disabled.');
        if (mounted) {
          final msg = isWindows
              ? 'Windows location is off. Enable Settings > Privacy & security > Location, and turn on "Let desktop apps access your location".'
              : 'Location services are disabled on this device.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  Geolocator.openLocationSettings();
                },
              ),
            ),
          );
        }
        setState(() => _isLocationEnabled = false);
        return;
      }

      // 2) Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission permanently denied.'),
              action: SnackBarAction(
                label: 'App Settings',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
        setState(() => _isLocationEnabled = false);
        return;
      }
      if (permission == LocationPermission.denied) {
        setState(() => _isLocationEnabled = false);
        return;
      }

      // 3) Start tracking
      await _initializeLocationTracking();
      // Get an initial fix so the button works immediately
      try {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = pos;
            _isLocationEnabled = true;
          });
        }
      } catch (_) {}
    } finally {
      _locationInitInProgress = false;
    }
  }

  void _initializeCompassTracking() {
    // Compass may be unsupported on some platforms (e.g., Windows). Guard usage.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _compassStreamSubscription =
          FlutterCompass.events?.listen((CompassEvent event) {
        if (event.heading != null) {
          setState(() {
            _currentHeading = event.heading!;
          });

          if (_isFollowingUser) {
            _mapController.rotate(-_currentHeading);
          }
        }
      });
    } else {
      debugPrint('Compass not initialized on this platform.');
    }
  }

  void _toggleLocationFollowing() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
    });

    if (_isFollowingUser) {
      final bool isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
      if (_currentPosition == null) {
        if (isWindows) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location unavailable. On Windows, enable Settings > Privacy & security > Location, and allow desktop apps access your location.',
                ),
              ),
            );
          }
          return;
        } else {
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
      }

      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        18.0,
      );
      _mapController.rotate(-_currentHeading);
    } else {
      _mapController.rotate(0.0);
    }
  }

  Marker? _buildUserLocationMarker() {
    if (_currentPosition == null) return null;

    return Marker(
      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 60.0,
      height: 60.0,
      rotate: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.4),
            ),
          ),
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
      backgroundColor: Colors.white,

      appBar: const CustomAppBar(),

      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Consumer<CampusRouteViewModel>(
                  builder: (context, routeViewModel, child) {
                    final selectedRoute = routeViewModel.selectedRoute;
                    final polylines = <Polyline>[];

                    debugPrint(
                        'Map Consumer rebuild - selectedRoute: ${selectedRoute?.id ?? 'null'}, _isNavigating: $_isNavigating');

                    if (selectedRoute != null && !_isNavigating) {
                      polylines.add(
                        Polyline(
                          points: selectedRoute.polylinePoints,
                          color: selectedRoute.color,
                          strokeWidth: 4.0,
                        ),
                      );
                    }

                    final graphPolylines = <Polyline>[];
                    try {
                      for (final from in _graphEdges.keys) {
                        final neighbors = _graphEdges[from];
                        if (neighbors == null) continue;
                        for (final to in neighbors.keys) {
                          if (from.compareTo(to) >= 0) continue;
                          final a = _graphNodes[from];
                          final b = _graphNodes[to];
                          if (a == null || b == null) continue;
                          graphPolylines.add(
                            Polyline(
                              points: [a, b],
                              color: Colors.black,
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
                            LatLng(15.132896, 120.590068),
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
                        PolylineLayer(polylines: polylines),

                        if (graphPolylines.isNotEmpty)
                          PolylineLayer(
                            polylines: graphPolylines,
                          ),

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
                        MarkerLayer(
                          markers: [
                            if (_showBuildings) ..._buildMapMarkers(),

                            if (widget.isAdmin && _showWaypoints)
                              for (final entry in _graphNodes.entries)
                                Marker(
                                  point: entry.value,
                                  width: 18,
                                  height: 18,
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

                            if (_buildUserLocationMarker() != null)
                              _buildUserLocationMarker()!,
                          ],
                        ),
                      ],
                    );
                  },
                ),

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
                      onPressed: () async {
                        if (!_isLocationEnabled) {
                          await _ensureLocationInitialized();
                        }
                        if (_isLocationEnabled) {
                          _toggleLocationFollowing();
                        }
                      },
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
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

          FloatingActionButton(
            backgroundColor: AppTheme.primaryRed,
            onPressed: () => _showRoutesBottomSheet(context),
            child: const Icon(Icons.directions_walk, color: Colors.white),
            heroTag: 'routesFab',
          ),
        ],
      ),
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
      if (mounted) {
        setState(() {
          _isRoutesSheetOpen = false;
        });
      }
    });
  }

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
                  Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

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

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _routeSearchController,
                      style: const TextStyle(
                          color: Colors
                              .black),
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
                                  Navigator.pop(modalContext);
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));
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

  void _showAdminControlsBottomSheet(BuildContext context) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdminControlsBottomSheet(),
    );
  }

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
                                        onPressed: () async {
                                          final nameController = TextEditingController();
                                          final infoController = TextEditingController();
                                          final photoController = TextEditingController();

                                          final created = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => StatefulBuilder(builder: (context, setState) {
                                              final List<String> offices = [];
                                              final List<String> classrooms = [];
                                              final TextEditingController officeInput = TextEditingController();
                                              final TextEditingController classInput = TextEditingController();

                                              Widget buildChips(List<String> items) {
                                                return Wrap(
                                                  spacing: 6,
                                                  runSpacing: 6,
                                                  children: items
                                                      .map((it) => Chip(
                                                            label: Text(it, style: const TextStyle(color: Colors.black)),
                                                            onDeleted: () {
                                                              setState(() => items.remove(it));
                                                            },
                                                          ))
                                                      .toList(),
                                                );
                                              }

                                              return AlertDialog(
                                                title: const Text('Create building'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        controller: nameController,
                                                        style: const TextStyle(color: Colors.black),
                                                        decoration: const InputDecoration(labelText: 'Building name'),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      TextField(
                                                        controller: infoController,
                                                        style: const TextStyle(color: Colors.black),
                                                        decoration: const InputDecoration(labelText: 'Building information'),
                                                        maxLines: 3,
                                                      ),
                                                      const SizedBox(height: 12),
                                                      TextField(
                                                        controller: photoController,
                                                        style: const TextStyle(color: Colors.black),
                                                        decoration: const InputDecoration(labelText: 'Photo URL or asset path'),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      TextField(
                                                        controller: officeInput,
                                                        style: const TextStyle(color: Colors.black),
                                                        decoration: const InputDecoration(labelText: 'Add office / room'),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                minimumSize: const Size.fromHeight(40),
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: Colors.black, width: 1)),
                                                                backgroundColor: AppTheme.primaryYellow,
                                                                foregroundColor: AppTheme.textBlack,
                                                                elevation: 0,
                                                              ),
                                                              onPressed: () {
                                                                final val = officeInput.text.trim();
                                                                if (val.isNotEmpty) {
                                                                  setState(() {
                                                                    offices.add(val);
                                                                    officeInput.clear();
                                                                  });
                                                                }
                                                              },
                                                              child: const Text('ADD OFFICE', 
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                                fontSize: 10,
                                                              )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      if (offices.isNotEmpty) buildChips(offices),
                                                      const SizedBox(height: 12),
                                                      TextField(
                                                        controller: classInput,
                                                        style: const TextStyle(color: Colors.black),
                                                        decoration: const InputDecoration(labelText: 'Add classroom'),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                minimumSize: const Size.fromHeight(40),
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: Colors.black, width: 1)),
                                                                backgroundColor: AppTheme.primaryYellow,
                                                                foregroundColor: AppTheme.textBlack,
                                                                elevation: 0,
                                                              ),
                                                              onPressed: () {
                                                                final val = classInput.text.trim();
                                                                if (val.isNotEmpty) {
                                                                  setState(() {
                                                                    classrooms.add(val);
                                                                    classInput.clear();
                                                                  });
                                                                }
                                                              },
                                                              child: const Text('ADD CLASSROOM',
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 10,
                                                                )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      if (classrooms.isNotEmpty) buildChips(classrooms),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                                      const SizedBox(width: 8),
                                                      ElevatedButton(onPressed: () {
                                                        final name = nameController.text.trim();
                                                        final info = infoController.text.trim();
                                                        final photo = photoController.text.trim();
                                                        if (name.isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Building name is required')));
                                                          return;
                                                        }

                                                        setState(() {
                                                          _buildings.add({
                                                            'name': name,
                                                            'offices': [...offices, ...classrooms],
                                                            'info': info,
                                                            'photo': photo,
                                                          });
                                                        });

                                                        Navigator.pop(context, true);
                                                      }, child: const Text('CREATE',
                                                      style: TextStyle(fontSize: 20),)),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }),
                                          );

                                          if (created == true) {
                                            setState(() {});
                                            try { Navigator.pop(context); } catch (_) {}
                                          }
                                        },
                                        icon: const Icon(Icons.add),
                                        label: _responsiveLabel('Create'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final result = await Navigator.push<String?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminBuildingsReadPage(
                                                buildings: _buildings,
                                                isAdmin: widget.isAdmin,
                                              ),
                                            ),
                                          );

                                          if (result is String && result.isNotEmpty) {
                                            setState(() {
                                              _isNavigating = true;
                                              try {
                                                context.read<CampusRouteViewModel>().clearSelection();
                                              } catch (_) {}
                                            });
                                            _computePathFromCurrentTo(result);
                                          }
                                        },
                                        icon: const Icon(Icons.visibility),
                                        label: _responsiveLabel('Read'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final result = await Navigator.push<String?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminBuildingsUpdatePage(
                                                buildings: _buildings,
                                                isAdmin: widget.isAdmin,
                                              ),
                                            ),
                                          );

                                          if (result is String && result.isNotEmpty) {
                                            setState(() {
                                              _isNavigating = true;
                                              try {
                                                context.read<CampusRouteViewModel>().clearSelection();
                                              } catch (_) {}
                                            });
                                            _computePathFromCurrentTo(result);
                                          }
                                        },
                                        icon: const Icon(Icons.edit),
                                        label: _responsiveLabel('Update'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final result = await Navigator.push<String?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminBuildingsDeletePage(buildings: _buildings),
                                            ),
                                          );

                                          if (result is String && result.isNotEmpty) {
                                            setState(() {
                                              _isNavigating = true;
                                              try {
                                                context.read<CampusRouteViewModel>().clearSelection();
                                              } catch (_) {}
                                            });
                                            _computePathFromCurrentTo(result);
                                          }
                                        },
                                        icon: const Icon(Icons.delete),
                                        label: _responsiveLabel('Delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                        onPressed: () async {
                                          final controllerKey = TextEditingController();
                                          final controllerLat = TextEditingController();
                                          final controllerLng = TextEditingController();

                                          final created = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Create waypoint'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: controllerKey,
                                                    style: const TextStyle(color: Colors.black),
                                                    decoration: const InputDecoration(labelText: 'Waypoint key'),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  TextField(
                                                    controller: controllerLat,
                                                    style: const TextStyle(color: Colors.black),
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: const InputDecoration(labelText: 'Latitude'),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  TextField(
                                                    controller: controllerLng,
                                                    style: const TextStyle(color: Colors.black),
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    decoration: const InputDecoration(labelText: 'Longitude'),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(onPressed: () async {
                                                      final key = controllerKey.text.trim();
                                                      final lat = double.tryParse(controllerLat.text.trim());
                                                      final lng = double.tryParse(controllerLng.text.trim());
                                                      if (key.isEmpty || lat == null || lng == null) {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid input')));
                                                        return;
                                                      }

                                                      final ok = await WaypointService().createWaypoint(waypointKey: key, latitude: lat, longitude: lng);
                                                      if (ok) Navigator.pop(context, true);
                                                      else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create waypoint')));
                                                    }, child: const Text('CREATE',
                                                      style: TextStyle(fontSize: 20),)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );

                                          if (created == true) {
                                            _initializeGraphData();
                                            try { Navigator.pop(context); } catch (_) {}
                                          }
                                        },
                                        icon: const Icon(Icons.add_location),
                                        label: _responsiveLabel('Create'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final changed = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminWaypointsReadPage(
                                                waypoints: _graphNodes,
                                              ),
                                            ),
                                          );

                                          if (changed == true) {
                                            _initializeGraphData();
                                          }
                                        },
                                        icon: const Icon(Icons.visibility),
                                        label: _responsiveLabel('Read'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final changed = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminWaypointsUpdatePage(
                                                waypoints: _graphNodes,
                                              ),
                                            ),
                                          );

                                          if (changed == true) {
                                            _initializeGraphData();
                                          }
                                        },
                                        icon: const Icon(Icons.edit_location),
                                        label: _responsiveLabel('Update'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final changed = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminWaypointsDeletePage(waypoints: _graphNodes),
                                            ),
                                          );

                                          if (changed == true) {
                                            _initializeGraphData();
                                          }
                                        },
                                        icon: const Icon(Icons.delete),
                                        label: _responsiveLabel('Delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                        onPressed: () async {
                                          String fromSel = '';
                                          String toSel = '';

                                          Future<String?> _chooser(BuildContext ctx, String initial) async {
                                            final TextEditingController _search = TextEditingController();
                                            final wps = await WaypointService().fetchWaypoints();
                                            final List<String> options = wps.map((w) => w.waypointKey).toList()..sort();
                                            List<String> filtered = List.from(options);

                                            return showDialog<String>(
                                              context: ctx,
                                              builder: (context) {
                                                return StatefulBuilder(builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: const Text('Select waypoint'),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          controller: _search,
                                                          style: const TextStyle(color: Colors.black),
                                                          cursorColor: Colors.black,
                                                          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search...'),
                                                          onChanged: (v) {
                                                            final q = v.toLowerCase();
                                                            setState(() {
                                                              filtered = options.where((o) => o.toLowerCase().contains(q)).toList();
                                                            });
                                                          },
                                                        ),
                                                        const SizedBox(height: 8),
                                                        SizedBox(
                                                          width: double.maxFinite,
                                                          height: 240,
                                                          child: ListView.builder(
                                                            itemCount: filtered.length,
                                                            itemBuilder: (context, i) => Container(
                                                              margin: const EdgeInsets.symmetric(vertical: 4),
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: Colors.grey.shade300),
                                                                borderRadius: BorderRadius.circular(6),
                                                                color: Colors.white,
                                                              ),
                                                              child: ListTile(
                                                                title: Text(filtered[i]),
                                                                onTap: () => Navigator.pop(context, filtered[i]),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('CANCEL'))],
                                                  );
                                                });
                                              },
                                            );
                                          }

                                          final created = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => StatefulBuilder(builder: (context, setState) {
                                              Widget buildPickerRow({required String label, required String value, required VoidCallback onTap, required IconData icon}) {
                                                return InkWell(
                                                  onTap: onTap,
                                                  child: Container(
                                                    height: 56,
                                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey.shade300),
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: Colors.white,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(icon, color: Colors.grey[700]),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                                              const SizedBox(height: 2),
                                                              Text(value.isEmpty ? '(select)' : value, style: const TextStyle(color: Colors.black, fontSize: 14), overflow: TextOverflow.ellipsis),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

                                              return AlertDialog(
                                                title: const Text('Create connection'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    buildPickerRow(
                                                      label: 'From',
                                                      value: fromSel,
                                                      icon: Icons.travel_explore,
                                                      onTap: () async {
                                                        final pick = await _chooser(context, fromSel);
                                                        if (pick != null) setState(() => fromSel = pick);
                                                      },
                                                    ),
                                                    const SizedBox(height: 12),
                                                    buildPickerRow(
                                                      label: 'To',
                                                      value: toSel,
                                                      icon: Icons.place,
                                                      onTap: () async {
                                                        final pick = await _chooser(context, toSel);
                                                        if (pick != null) setState(() => toSel = pick);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                                      const SizedBox(width: 8),
                                                      ElevatedButton(onPressed: () async {
                                                        if (fromSel.isEmpty || toSel.isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both From and To waypoints')));
                                                          return;
                                                        }
                                                        if (fromSel == toSel) {
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('From and To cannot be the same waypoint')));
                                                          return;
                                                        }

                                                        final ok = await EdgeService().createEdge(from: fromSel, to: toSel);
                                                        if (ok) Navigator.pop(context, true);
                                                        else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create connection')));
                                                      }, child: const Text('CREATE',
                                                        style: TextStyle(fontSize: 20),)),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }),
                                          );

                                          if (created == true) {
                                            _initializeGraphData();
                                            try { Navigator.pop(context); } catch (_) {}
                                          }
                                        },
                                        icon: const Icon(Icons.link),
                                        label: _responsiveLabel('Create'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final edges = await EdgeService().fetchEdges();
                                          final changed = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminConnectionsReadPage(connections: edges),
                                            ),
                                          );

                                          if (changed == true) {
                                            _initializeGraphData();
                                          }
                                        },
                                        icon: const Icon(Icons.visibility),
                                        label: _responsiveLabel('Read'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final edges = await EdgeService().fetchEdges();
                                          final changed = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminConnectionsUpdatePage(connections: edges),
                                            ),
                                          );

                                          if (changed == true) {
                                            _initializeGraphData();
                                          }
                                        },
                                        icon: const Icon(Icons.swap_horiz),
                                        label: _responsiveLabel('Update'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () async {
                                          try {
                                            Navigator.pop(context);
                                          } catch (_) {}
                                          await Future.delayed(const Duration(milliseconds: 150));

                                          final edges = await EdgeService().fetchEdges();
                                          final changed = await Navigator.push<bool?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminConnectionsDeletePage(connections: edges),
                                            ),
                                          );

                                          if (changed == true) {
                                            _initializeGraphData();
                                          }
                                        },
                                        icon: const Icon(Icons.link_off),
                                        label: _responsiveLabel('Delete'),
                                      ),
                                    ),
                                  ],
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

  List<Marker> _buildMapMarkers() {
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
          continue;
        }
      } catch (_) {}

      _graphNodes[b['name'] as String] = LatLng(b['lat'], b['lng']);
    }

    return buildingLocations
        .where((building) => building['lat'] != null && building['lng'] != null)
        .map((building) {
      return Marker(
        point: LatLng(building['lat'], building['lng']),
        width: 80.0,
        height: 80.0,
        rotate: true,
        child: GestureDetector(
          onTap: () async {
            if (_isRoutesSheetOpen) {
              try {
                Navigator.of(context).pop();
                await Future.delayed(const Duration(milliseconds: 150));
              } catch (_) {}
            }

            final buildingData = _buildings.firstWhere(
              (b) => b['name'] == building['name'],
              orElse: () => {'name': building['name'], 'offices': []},
            );

            _pushBuildingDetailAndHandleNavigation(
              building['name'],
              List<String>.from(buildingData['offices'] as List),
            );
          },
          child: Transform.rotate(
            angle: _isFollowingUser ? _currentHeading * math.pi / 180 : 0,
            child: Column(
              children: [
                _buildBuildingMarkerIcon(
                    building['name'] as String),
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

  Future<void> _initializeGraphData() async {
    _graphNodes.clear();
    _graphEdges.clear();

    final waypoints = await WaypointService().fetchWaypoints();
    final edges = await EdgeService().fetchEdges();

      setState(() {
        for (var wp in waypoints) {
          _graphNodes[wp.waypointKey] = LatLng(wp.latitude, wp.longitude);
        }

        final dist = const Distance();
        for (var edge in edges) {
          final from = edge.fromWaypoint;
          final to = edge.toWaypoint;
          double d = edge.distanceMeters;
          // If distance from backend is zero or suspicious, compute from coordinates
          if (d <= 0 && _graphNodes.containsKey(from) && _graphNodes.containsKey(to)) {
            d = dist.as(LengthUnit.Meter, _graphNodes[from]!, _graphNodes[to]!);
          }

          _graphEdges.putIfAbsent(from, () => {});
          _graphEdges[from]![to] = d;

          // Ensure the graph is undirected for routing
          _graphEdges.putIfAbsent(to, () => {});
          _graphEdges[to]![from] = d;
        }
      });
  }

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

  void _adjustPathDynamically() {
    if (_currentPosition == null || _computedPath.isEmpty) return;

    final currentPos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    const double proximityThreshold = 15.0;
    const double deviationThreshold = 50.0;

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
      debugPrint('User reached point $closestPointIndex, reducing path');
      setState(() {
        _computedPath = [
          currentPos,
          ..._computedPath.sublist(closestPointIndex + 1)
        ];
      });
    } else {
      double minDistanceToPath = double.infinity;
      for (final pathPoint in _computedPath) {
        final distance = Distance().as(LengthUnit.Meter, currentPos, pathPoint);
        if (distance < minDistanceToPath) {
          minDistanceToPath = distance;
        }
      }

      if (minDistanceToPath > deviationThreshold) {
        debugPrint(
            'User deviated from path (${minDistanceToPath.toStringAsFixed(1)}m), recalculating');
        _computePathFromCurrentTo(_currentNavigationTarget!);
      }
    }
  }

  void _computePathFromCurrentTo(String buildingName) {
    String targetNode = 'wp_Entrance';
    try {
      String normalizedName = buildingName.trim();
      final mapped = wpdata.buildingToWaypoints[normalizedName];
      if (mapped != null && mapped.isNotEmpty) {
        targetNode = mapped.first;
      }
    } catch (_) {}

    debugPrint('All graph node keys: ${_graphNodes.keys.toList()}');
    debugPrint('Target node for $buildingName: $targetNode');

    if (!_graphNodes.containsKey(targetNode)) {
      debugPrint('Target node $targetNode not found in graph');
      return;
    }

    // Decide a reliable starting position
    const LatLng campusCenter = LatLng(15.132896, 120.590068);
    final LatLng campusEntrance = _graphNodes['wp_Entrance'] ?? campusCenter;
  // Distance util no longer required now that we always respect device position.
  final bool isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  final bool isWeb = kIsWeb;

    LatLng currentPos;
    if (_currentPosition != null) {
      // Always respect device-reported location on all platforms.
      final devicePos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      currentPos = devicePos;
    } else {
      if (isWindows || isWeb) {
        if (mounted) {
          final msg = isWindows
              ? 'Location unavailable. On Windows, enable Settings > Privacy & security > Location, and allow desktop apps access your location.'
              : 'Location unavailable in browser. Please allow location in site permissions and reload.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
        return;
      } else {
        currentPos = campusEntrance;
      }
    }
    String? nearestNodeToUser;
    double nearestDist = double.infinity;

    for (final entry in _graphNodes.entries) {
      // Only consider graph waypoints, skip building label nodes
      if (!entry.key.startsWith('wp_')) continue;
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
  var nodePath = _dijkstra(nearestNodeToUser, targetNode);

    if (nodePath.isEmpty) {
      // Try again from campus entrance explicitly
      if (_graphNodes.containsKey('wp_Entrance')) {
        debugPrint('No path from $nearestNodeToUser, retrying from Entrance');
        nodePath = _dijkstra('wp_Entrance', targetNode);
        currentPos = campusEntrance;
      }
      if (nodePath.isEmpty) {
        debugPrint('No path found between $nearestNodeToUser and $targetNode');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No route available. Please try another destination.')),
          );
        }
        return;
      }
    }

    final nodePositions = <LatLng>[];
    nodePositions.add(currentPos);

    for (final node in nodePath) {
      final pos = _graphNodes[node];
      if (pos != null) {
        nodePositions.add(pos);
      }
    }

    setState(() {
      _computedPath = nodePositions;
      _currentNavigationTarget = buildingName;
    });

    // Ensure the whole path from user to destination is visible
    try {
      _fitRouteOnMap(nodePositions);
    } catch (_) {}

    debugPrint('Path computed with ${nodePositions.length} points');
  }

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
      setState(() {
        _isNavigating = true;
        try {
          context.read<CampusRouteViewModel>().clearSelection();
        } catch (_) {}
      });
      _computePathFromCurrentTo(result);
    }
  }

  String? _buildingLogoAsset(String fullName) {
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

  Widget _buildBuildingMarkerIcon(String buildingName) {
    final asset = _buildingLogoAsset(buildingName);
    if (asset == null) {
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
          return Container(
            color: AppTheme.primaryYellow,
            child: const Icon(Icons.location_on, color: Colors.white),
          );
        },
      ),
    );
  }

  String _getAbbreviatedName(String fullName) {
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

    final words = fullName.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}' : fullName;
  }

  void _maybeRecomputePathOnMove() {
    if (!_isNavigating ||
        _currentNavigationTarget == null ||
        _currentPosition == null) return;

    final now = DateTime.now();

    if (_isComputingPath) return;

    if (_lastPathComputeTime != null) {
      final since = now.difference(_lastPathComputeTime!);
      if (since < _minRecomputeInterval) return;
    }

    final currentPos =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    if (_lastPathComputePosition != null) {
      final dist = Distance()
          .as(LengthUnit.Meter, _lastPathComputePosition!, currentPos);
      if (dist < _minRecomputeDistanceMeters) return;
    }

    _isComputingPath = true;
    _lastPathComputeTime = now;
    _lastPathComputePosition = currentPos;

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
