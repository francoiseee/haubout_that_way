import 'package:hau_navigation_app/models/office.dart';
import 'package:hau_navigation_app/supabase_services/supabase_service.dart';

class OfficeService {
  // Fetch all offices
  Future<List<Office>> fetchOffices() async {
    final data = await SupabaseService.client
        .from('office')
        .select()
        .then((value) => value as List<dynamic>);

    return data.map((item) => Office.fromMap(item as Map<String, dynamic>)).toList();
  }

  // Fetch offices by building code
  Future<List<Office>> fetchOfficesByBuildingCode(String buildingCode) async {
    final data = await SupabaseService.client
        .from('office')
        .select()
        .eq('building_code', buildingCode)
        .then((value) => value as List<dynamic>);

    return data.map((item) => Office.fromMap(item as Map<String, dynamic>)).toList();
  }
}