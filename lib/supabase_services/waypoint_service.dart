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
}