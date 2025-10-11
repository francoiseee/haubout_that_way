import 'package:hau_navigation_app/models/building.dart';
import 'package:hau_navigation_app/supabase_services/supabase_service.dart';

class BuildingService {
  // Fetch all buildings
  Future<List<Building>> fetchBuildings() async {
    final data = await SupabaseService.client
        .from('buildings')
        .select()
        .then((value) => value as List<dynamic>);

    return data.map((item) => Building.fromMap(item as Map<String, dynamic>)).toList();
  }

  // Fetch building by code
  Future<Building?> fetchBuildingByName(String name) async {
    final data = await SupabaseService.client
        .from('buildings')
        .select()
        .eq('name', name)
        .single();

    if (data == null) return null;
    return Building.fromMap(data as Map<String, dynamic>);
  }
}