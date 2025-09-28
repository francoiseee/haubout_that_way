import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// A data model representing a walking route within the HAU campus.
///
/// This class holds all the essential information for a campus route,
/// including its unique identifier, name, description, and a list of 
/// geographical coordinates that define its exact walking path.
class CampusRoute {
  /// A unique identifier for the route, useful for database operations
  /// or for passing route data between screens.
  final String id;

  /// The human-readable name of the route (e.g., "Main Building to Library").
  final String name;

  /// A brief description of what this route covers or its purpose.
  final String description;

  /// The starting building or location of the route.
  final String startLocation;

  /// The ending building or location of the route.
  final String endLocation;

  /// The color used to render the route's polyline on a map.
  final Color color;

  /// Estimated walking time in minutes for this route.
  final int estimatedWalkingTime;

  /// Whether this route is accessible for wheelchairs and people with disabilities.
  final bool isAccessible;

  /// A list of [LatLng] objects that represent the geographical points
  /// of the route's walking path. This is used to draw the route on a map.
  final List<LatLng> polylinePoints;

  /// List of points of interest along this route (optional buildings, landmarks).
  final List<String> pointsOfInterest;

  /// Creates a new [CampusRoute] instance.
  CampusRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.startLocation,
    required this.endLocation,
    required this.color,
    required this.estimatedWalkingTime,
    required this.isAccessible,
    required this.polylinePoints,
    this.pointsOfInterest = const [],
  });

  /// A factory constructor to create a [CampusRoute] from a JSON map.
  factory CampusRoute.fromJson(Map<String, dynamic> json) {
    var pointsList = json['polylinePoints'] as List;
    List<LatLng> polylinePoints = pointsList.map((pointJson) {
      return LatLng(
        pointJson['latitude'] as double,
        pointJson['longitude'] as double,
      );
    }).toList();

    return CampusRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      startLocation: json['startLocation'] as String,
      endLocation: json['endLocation'] as String,
      color: Color(json['color'] as int),
      estimatedWalkingTime: json['estimatedWalkingTime'] as int,
      isAccessible: json['isAccessible'] as bool,
      polylinePoints: polylinePoints,
      pointsOfInterest: List<String>.from(json['pointsOfInterest'] ?? []),
    );
  }

  /// Converts this [CampusRoute] object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'color': color.value,
      'estimatedWalkingTime': estimatedWalkingTime,
      'isAccessible': isAccessible,
      'polylinePoints': polylinePoints.map((point) {
        return {'latitude': point.latitude, 'longitude': point.longitude};
      }).toList(),
      'pointsOfInterest': pointsOfInterest,
    };
  }

  /// Returns a formatted string of the estimated walking time.
  String get walkingTimeText {
    if (estimatedWalkingTime < 1) {
      return 'Less than 1 min';
    } else if (estimatedWalkingTime == 1) {
      return '1 min';
    } else {
      return '$estimatedWalkingTime mins';
    }
  }

  /// Returns an accessibility icon based on the isAccessible property.
  IconData get accessibilityIcon {
    return isAccessible ? Icons.accessible : Icons.not_accessible;
  }
}