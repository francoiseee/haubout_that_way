import 'package:flutter/material.dart';
import '../models/campus_route.dart';
import '../data/initial_campus_routes.dart';

/// A [ChangeNotifier] that manages the currently selected campus walking route.
///
/// This view model is responsible for holding the state of the user's
/// selected route and notifying listeners (like the map page) when it changes.
/// This allows for a clean separation of concerns between UI and state logic.
class CampusRouteViewModel extends ChangeNotifier {
  /// The private backing field for the currently selected route.
  CampusRoute? _selectedRoute;

  /// Returns the currently selected campus route.
  ///
  /// This getter provides read-only access to the route state.
  CampusRoute? get selectedRoute => _selectedRoute;

  /// Returns all available campus routes.
  List<CampusRoute> get allRoutes => initialCampusRoutes;

  /// Returns routes filtered by accessibility requirements.
  List<CampusRoute> get accessibleRoutes => 
      initialCampusRoutes.where((route) => route.isAccessible).toList();

  /// Returns routes categorized by estimated walking time.
  List<CampusRoute> getRoutesByDuration(int maxMinutes) =>
      initialCampusRoutes
          .where((route) => route.estimatedWalkingTime <= maxMinutes)
          .toList();

  /// Returns routes that start from a specific location.
  List<CampusRoute> getRoutesFromLocation(String location) =>
      initialCampusRoutes
          .where((route) => 
              route.startLocation.toLowerCase().contains(location.toLowerCase()) ||
              route.endLocation.toLowerCase().contains(location.toLowerCase()))
          .toList();

  /// Sets the selected route based on its unique ID and notifies listeners.
  ///
  /// This is the public-facing method used by UI components (like a list of
  /// routes) to trigger a route selection without needing the full object.
  void setSelectedRoute(String? routeId) {
    if (routeId == null) {
      clearSelection();
    } else {
      try {
        // Find the full route object from the imported list using the ID.
        final route = initialCampusRoutes.firstWhere(
          (route) => route.id == routeId,
          orElse: () => throw Exception('Route with ID $routeId not found'),
        );
        // Once we have the object, we can call the selectRoute method.
        selectRoute(route);
      } catch (e) {
        // Handle the case where the route is not found
        debugPrint('Route selection failed: $e');
        clearSelection();
      }
    }
  }

  /// Sets the selected route object directly and notifies all listeners.
  ///
  /// This is an internal method to update the state once a route has been
  /// successfully found or provided.
  void selectRoute(CampusRoute route) {
    _selectedRoute = route;
    notifyListeners();
  }

  /// Clears the current route selection.
  ///
  /// Sets the selected route to `null` and notifies all listening widgets
  /// to update their state, for example, by removing a route's polyline from the map.
  void clearSelection() {
    _selectedRoute = null;
    notifyListeners();
  }

  /// Searches for routes based on a query string.
  ///
  /// Searches through route names, descriptions, start/end locations,
  /// and points of interest.
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

  /// Toggles route selection - if the route is already selected, deselect it.
  /// Otherwise, select it.
  void toggleRoute(CampusRoute route) {
    if (_selectedRoute?.id == route.id) {
      clearSelection();
    } else {
      selectRoute(route);
    }
  }

  /// Returns route statistics for dashboard/info purposes.
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