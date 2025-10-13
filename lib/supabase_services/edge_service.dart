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
}