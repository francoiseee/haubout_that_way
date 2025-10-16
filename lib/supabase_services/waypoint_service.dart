import 'package:hau_navigation_app/models/waypoint.dart';
import 'package:hau_navigation_app/supabase_services/supabase_service.dart';

class WaypointService {
  Future<List<Waypoint>> fetchWaypoints() async {
    final response = await SupabaseService.client
        .from('waypoints')
        .select();

    final data = response as List<dynamic>?;

    if (data == null) return [];

    return data.map((item) => Waypoint.fromMap(item as Map<String, dynamic>)).toList();
  }

  /// Update a waypoint identified by [originalKey]. If [newKey] is provided it will
  /// update the waypoint_key column as well. Returns true on success.
  Future<bool> updateWaypoint({
    required String originalKey,
    required double latitude,
    required double longitude,
    String? newKey,
  }) async {
    try {
      final updates = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      };
      if (newKey != null && newKey.isNotEmpty) {
        updates['waypoint_key'] = newKey;
      }

      await SupabaseService.client
          .from('waypoints')
          .update(updates)
          .eq('waypoint_key', originalKey);

      return true;
    } catch (e) {
      print('Error updating waypoint: $e');
      return false;
    }
  }

  /// Delete a waypoint by its key. Returns true on success.
  Future<bool> deleteWaypoint(String waypointKey) async {
    try {
      await SupabaseService.client
          .from('waypoints')
          .delete()
          .eq('waypoint_key', waypointKey);
      return true;
    } catch (e) {
      print('Error deleting waypoint: $e');
      return false;
    }
  }

  /// Create a new waypoint. Returns true on success.
  Future<bool> createWaypoint({required String waypointKey, required double latitude, required double longitude}) async {
    try {
      await SupabaseService.client
          .from('waypoints')
          .insert({
        'waypoint_key': waypointKey,
        'latitude': latitude,
        'longitude': longitude,
      });
      return true;
    } catch (e) {
      print('Error creating waypoint: $e');
      return false;
    }
  }
}