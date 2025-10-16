import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CampusRoute {
  final String id;
  final String name;
  final String description;
  final String startLocation;
  final String endLocation;
  final Color color;
  final int estimatedWalkingTime;
  final bool isAccessible;
  final List<LatLng> polylinePoints;
  final List<String> pointsOfInterest;

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

  String get walkingTimeText {
    if (estimatedWalkingTime < 1) {
      return 'Less than 1 min';
    } else if (estimatedWalkingTime == 1) {
      return '1 min';
    } else {
      return '$estimatedWalkingTime mins';
    }
  }

  IconData get accessibilityIcon {
    return isAccessible ? Icons.accessible : Icons.not_accessible;
  }
}