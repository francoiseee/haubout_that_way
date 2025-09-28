import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/campus_route.dart';

/// This file contains predefined walking routes within HAU campus.
///
/// Each route represents a walking path between two main locations
/// on campus, designed to help students, faculty, and visitors
/// navigate efficiently between buildings and facilities.
final initialCampusRoutes = <CampusRoute>[
  /// Main Entrance to Main Building (DJDN)
  /// Popular route for new students and visitors
  CampusRoute(
    id: 'main-entrance-to-djdn',
    name: 'Main Entrance to Main Building',
    description: 'Direct route from the main university entrance to the Don Juan D. Nepomuceno Building where most administrative offices are located.',
    startLocation: 'Main Entrance',
    endLocation: 'Don Juan D. Nepomuceno Building',
    color: const Color(0xFF2E8B57), // Sea Green
    estimatedWalkingTime: 3,
    isAccessible: true,
    polylinePoints: const [
      // Main Entrance Gate
      LatLng(15.1385, 120.5900),
      LatLng(15.1387, 120.5902),
      LatLng(15.1389, 120.5903),
      LatLng(15.1391, 120.5904),
      LatLng(15.1392, 120.5905),
      // Main pathway to DJDN
      LatLng(15.1393, 120.5905),
      LatLng(15.1394, 120.5906), // DJDN Building
    ],
    pointsOfInterest: [
      'HAU Guard House',
      'Campus Park Area',
      'Student Parking',
    ],
  ),

  /// Main Building to Library (SFJ)
  /// Common route for students going to study
  CampusRoute(
    id: 'djdn-to-library',
    name: 'Main Building to Library',
    description: 'Quick route from the main administrative building to the University Library in San Francisco De Javier Building.',
    startLocation: 'Don Juan D. Nepomuceno Building',
    endLocation: 'University Library (SFJ)',
    color: const Color(0xFF4169E1), // Royal Blue
    estimatedWalkingTime: 2,
    isAccessible: true,
    polylinePoints: const [
      // DJDN Building
      LatLng(15.1394, 120.5906),
      LatLng(15.1393, 120.5905),
      LatLng(15.1392, 120.5904),
      // Direct path to SFJ
      LatLng(15.1392, 120.5904), // SFJ Building with Library
    ],
    pointsOfInterest: [
      'Registrar Office',
      'Finance Office',
      'Central Courtyard',
    ],
  ),

  /// Dormitory to Academic Buildings Circuit
  /// Essential for resident students
  CampusRoute(
    id: 'dormitory-to-academics',
    name: 'Dormitory to Academic Area',
    description: 'Convenient route from student dormitories (Red Building area) to the main academic buildings including SJH and SFJ.',
    startLocation: 'Plaza De Corazon Building (Dormitory)',
    endLocation: 'St. Joseph Hall Building',
    color: const Color(0xFFDC143C), // Crimson
    estimatedWalkingTime: 4,
    isAccessible: true,
    polylinePoints: const [
      // Red Building / Dormitory area
      LatLng(15.1390, 120.5910),
      LatLng(15.1391, 120.5909),
      LatLng(15.1392, 120.5908),
      LatLng(15.1393, 120.5907),
      LatLng(15.1394, 120.5907),
      LatLng(15.1395, 120.5907),
      // SJH Building
      LatLng(15.1396, 120.5908),
    ],
    pointsOfInterest: [
      'Dormitory Entrance',
      'Campus Cafeteria Area',
      'Academic Departments',
    ],
  ),

  /// Engineering Building to Gymnasium
  /// Popular for students with PE classes
  CampusRoute(
    id: 'engineering-to-gym',
    name: 'Engineering Building to Gymnasium',
    description: 'Route from Sacred Heart Building (Engineering) to the Immaculate Heart Gymnasium, commonly used by engineering students with PE classes.',
    startLocation: 'Sacred Heart Building (Engineering)',
    endLocation: 'Immaculate Heart Gymnasium',
    color: const Color(0xFFFF8C00), // Dark Orange
    estimatedWalkingTime: 5,
    isAccessible: false, // Assumes some steps or uneven terrain
    polylinePoints: const [
      // Sacred Heart Building
      LatLng(15.1398, 120.5912),
      LatLng(15.1397, 120.5913),
      LatLng(15.1395, 120.5914),
      LatLng(15.1393, 120.5915),
      LatLng(15.1391, 120.5916),
      LatLng(15.1390, 120.5915),
      // Covered Court area
      LatLng(15.1388, 120.5914),
      LatLng(15.1387, 120.5915),
      // Gymnasium
      LatLng(15.1385, 120.5916),
    ],
    pointsOfInterest: [
      'Engineering Departments',
      'Covered Court',
      'Sports Facilities',
    ],
  ),

  /// Chapel Circuit Route
  /// Spiritual and peaceful walking route
  CampusRoute(
    id: 'chapel-circuit',
    name: 'Campus Chapel Circuit',
    description: 'Peaceful walking route that passes by the Chapel of the Holy Guardian Angel and nearby formation buildings.',
    startLocation: 'Chapel of the Holy Guardian Angel',
    endLocation: 'Sister Josefina Nepomuceno Formation Center',
    color: const Color(0xFF9370DB), // Medium Purple
    estimatedWalkingTime: 6,
    isAccessible: true,
    polylinePoints: const [
      // Chapel area
      LatLng(15.1385, 120.5905),
      LatLng(15.1384, 120.5906),
      LatLng(15.1383, 120.5907),
      LatLng(15.1382, 120.5908),
      LatLng(15.1381, 120.5909),
      LatLng(15.1380, 120.5910),
      LatLng(15.1379, 120.5911),
      // Formation Center
      LatLng(15.1378, 120.5912),
    ],
    pointsOfInterest: [
      'Holy Guardian Angel Chapel',
      'Meditation Garden',
      'Formation Programs Area',
    ],
  ),

  /// Business School to Nursing School
  /// Inter-college route
  CampusRoute(
    id: 'business-to-nursing',
    name: 'Business School to Nursing School',
    description: 'Inter-college route connecting the School of Business and Accountancy (PGN) to the School of Nursing (MGN).',
    startLocation: 'Peter G. Nepomuceno Building (Business)',
    endLocation: 'Mamerto G. Nepomuceno Building (Nursing)',
    color: const Color(0xFF20B2AA), // Light Sea Green
    estimatedWalkingTime: 4,
    isAccessible: true,
    polylinePoints: const [
      // PGN Business Building
      LatLng(15.1390, 120.5906),
      LatLng(15.1389, 120.5907),
      LatLng(15.1388, 120.5908),
      LatLng(15.1387, 120.5909),
      LatLng(15.1386, 120.5910),
      LatLng(15.1385, 120.5911),
      // MGN Nursing Building
      LatLng(15.1384, 120.5912),
    ],
    pointsOfInterest: [
      'Business Dean Office',
      'PGN Auditorium',
      'Nursing Laboratories',
    ],
  ),

  /// Complete Campus Tour Route
  /// Comprehensive walking tour for visitors
  CampusRoute(
    id: 'campus-grand-tour',
    name: 'HAU Grand Campus Tour',
    description: 'Comprehensive walking tour covering all major buildings and facilities. Perfect for new students, parents, and campus visitors.',
    startLocation: 'Main Entrance',
    endLocation: 'Main Entrance',
    color: const Color(0xFFB8860B), // Dark Goldenrod
    estimatedWalkingTime: 25,
    isAccessible: true,
    polylinePoints: const [
      // Start at Main Entrance
      LatLng(15.1385, 120.5900),
      // Visit Main Building
      LatLng(15.1394, 120.5906),
      // Go to SJH Academic
      LatLng(15.1396, 120.5908),
      // Visit Library (SFJ)
      LatLng(15.1392, 120.5904),
      // Check Engineering (SH)
      LatLng(15.1398, 120.5912),
      // Visit Gymnasium
      LatLng(15.1385, 120.5916),
      // See Dormitories (Red Bldg)
      LatLng(15.1390, 120.5910),
      // Chapel area
      LatLng(15.1385, 120.5905),
      // Business School (PGN)
      LatLng(15.1390, 120.5906),
      // Nursing School (MGN)
      LatLng(15.1384, 120.5912),
      // Return to entrance
      LatLng(15.1385, 120.5900),
    ],
    pointsOfInterest: [
      'All Major Academic Buildings',
      'Administrative Offices',
      'Student Facilities',
      'Dormitories',
      'Sports Complex',
      'Chapel',
      'Library',
    ],
  ),

  /// Emergency Evacuation Route
  /// Safety route to main exits
  CampusRoute(
    id: 'emergency-evacuation',
    name: 'Emergency Evacuation Route',
    description: 'Primary emergency evacuation route from the central campus area to the main exit points. Know this route for safety.',
    startLocation: 'Central Campus Area',
    endLocation: 'Main Exit Gates',
    color: const Color(0xFFFF0000), // Red
    estimatedWalkingTime: 3,
    isAccessible: true,
    polylinePoints: const [
      // Central campus
      LatLng(15.1392, 120.5908),
      LatLng(15.1391, 120.5907),
      LatLng(15.1390, 120.5906),
      LatLng(15.1389, 120.5904),
      LatLng(15.1388, 120.5902),
      LatLng(15.1387, 120.5901),
      // Main exit
      LatLng(15.1385, 120.5900),
    ],
    pointsOfInterest: [
      'Emergency Assembly Points',
      'Fire Exits',
      'Security Posts',
    ],
  ),
];