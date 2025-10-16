import 'package:flutter/material.dart';
import '../models/campus_route.dart';
import '../data/initial_campus_routes.dart';

class CampusRouteViewModel extends ChangeNotifier {
  CampusRoute? _selectedRoute;
  CampusRoute? get selectedRoute => _selectedRoute;
  List<CampusRoute> get allRoutes => initialCampusRoutes;
  List<CampusRoute> get accessibleRoutes => 
      initialCampusRoutes.where((route) => route.isAccessible).toList();
  List<CampusRoute> getRoutesByDuration(int maxMinutes) =>
      initialCampusRoutes
          .where((route) => route.estimatedWalkingTime <= maxMinutes)
          .toList();

  List<CampusRoute> getRoutesFromLocation(String location) =>
      initialCampusRoutes
          .where((route) => 
              route.startLocation.toLowerCase().contains(location.toLowerCase()) ||
              route.endLocation.toLowerCase().contains(location.toLowerCase()))
          .toList();

  void setSelectedRoute(String? routeId) {
    if (routeId == null) {
      clearSelection();
    } else {
      try {
        final route = initialCampusRoutes.firstWhere(
          (route) => route.id == routeId,
          orElse: () => throw Exception('Route with ID $routeId not found'),
        );
        selectRoute(route);
      } catch (e) {
        debugPrint('Route selection failed: $e');
        clearSelection();
      }
    }
  }

  void selectRoute(CampusRoute route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRoute = null;
    notifyListeners();
  }

  List<CampusRoute> searchRoutes(String query) {
    if (query.isEmpty) return allRoutes;
    
    final lowercaseQuery = query.toLowerCase();
    
    return initialCampusRoutes.where((route) {
      return route.name.toLowerCase().contains(lowercaseQuery) ||
             route.description.toLowerCase().contains(lowercaseQuery) ||
             route.startLocation.toLowerCase().contains(lowercaseQuery) ||
             route.endLocation.toLowerCase().contains(lowercaseQuery) ||
             route.pointsOfInterest.any((poi) => 
                 poi.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  void toggleRoute(CampusRoute route) {
    if (_selectedRoute?.id == route.id) {
      clearSelection();
    } else {
      selectRoute(route);
    }
  }

  Map<String, dynamic> getRouteStatistics() {
    return {
      'totalRoutes': initialCampusRoutes.length,
      'accessibleRoutes': accessibleRoutes.length,
      'averageWalkingTime': initialCampusRoutes.isEmpty 
          ? 0 
          : initialCampusRoutes
              .map((route) => route.estimatedWalkingTime)
              .reduce((a, b) => a + b) / initialCampusRoutes.length,
      'shortestRoute': initialCampusRoutes.isEmpty
          ? null
          : initialCampusRoutes.reduce((a, b) => 
              a.estimatedWalkingTime < b.estimatedWalkingTime ? a : b),
      'longestRoute': initialCampusRoutes.isEmpty
          ? null
          : initialCampusRoutes.reduce((a, b) => 
              a.estimatedWalkingTime > b.estimatedWalkingTime ? a : b),
    };
  }
}