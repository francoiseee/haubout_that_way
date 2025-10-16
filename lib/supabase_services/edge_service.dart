import 'package:hau_navigation_app/models/edge.dart';
import 'package:hau_navigation_app/supabase_services/supabase_service.dart';

class EdgeService {
  Future<List<Edge>> fetchEdges() async {
    final response = await SupabaseService.client
        .from('edges')
        .select();

    final data = response as List<dynamic>?;

    if (data == null) return [];

    return data.map((item) => Edge.fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<bool> updateEdge({required String from, required String to, required double distanceMeters}) async {
    try {
      await SupabaseService.client
          .from('edges')
          .update({'distance_meters': distanceMeters})
          .eq('from_waypoint', from)
          .eq('to_waypoint', to);
      return true;
    } catch (e) {
      print('Error updating edge: $e');
      return false;
    }
  }

  Future<bool> updateEdgeEndpoints({
    required String originalFrom,
    required String originalTo,
    required String newFrom,
    required String newTo,
  }) async {
    try {
      await SupabaseService.client
          .from('edges')
          .update({'from_waypoint': newFrom, 'to_waypoint': newTo})
          .eq('from_waypoint', originalFrom)
          .eq('to_waypoint', originalTo);
      return true;
    } catch (e) {
      print('Error updating edge endpoints: $e');
      return false;
    }
  }

  Future<bool> deleteEdge({required String from, required String to}) async {
    try {
      await SupabaseService.client
          .from('edges')
          .delete()
          .eq('from_waypoint', from)
          .eq('to_waypoint', to);
      return true;
    } catch (e) {
      print('Error deleting edge: $e');
      return false;
    }
  }

  Future<bool> createEdge({required String from, required String to, double? distanceMeters}) async {
    try {
      final Map<String, dynamic> row = {
        'from_waypoint': from,
        'to_waypoint': to,
      };
      if (distanceMeters != null) row['distance_meters'] = distanceMeters;

      await SupabaseService.client
          .from('edges')
          .insert(row);
      return true;
    } catch (e) {
      print('Error creating edge: $e');
      return false;
    }
  }
}