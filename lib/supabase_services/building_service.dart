import 'package:hau_navigation_app/models/building.dart';
import 'package:hau_navigation_app/supabase_services/supabase_service.dart';

class BuildingService {
  Future<List<Building>> fetchBuildings() async {
    final data = await SupabaseService.client
        .from('buildings')
        .select()
        .then((value) => value as List<dynamic>);

    return data.map((item) => Building.fromMap(item as Map<String, dynamic>)).toList();
  }

  Future<Building?> fetchBuildingByName(String name) async {
    final data = await SupabaseService.client
        .from('buildings')
        .select()
        .eq('name', name)
        .single();

    return Building.fromMap(data);
  }

  Future<void> updateBuildingDescription(String buildingId, String newDescription) async {
  await SupabaseService.client
    .from('buildings')
    .update({'description': newDescription})
    .eq('building_id', buildingId);
  }
}