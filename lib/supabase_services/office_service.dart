import 'package:hau_navigation_app/models/office.dart';
import 'package:hau_navigation_app/supabase_services/supabase_service.dart';

class OfficeService {
  // Fetch all offices
  Future<List<Office>> fetchOffices() async {
    final data = await SupabaseService.client
        .from('offices')
        .select()
        .then((value) => value as List<dynamic>);

    return data.map((item) => Office.fromMap(item as Map<String, dynamic>)).toList();
  }

  // Fetch offices by building code
  Future<List<Office>> fetchOfficesByBuildingCode(String buildingCode) async {
  final response = await SupabaseService.client
      .from('offices')
      .select()
      .eq('building_code', buildingCode);

  if (response == null || (response is List && response.isEmpty)) return [];

  final data = (response as List).cast<Map<String, dynamic>>();

  return data.map((item) => Office.fromMap(item)).toList();
  }

  // Update office name
  Future<void> updateOfficeName(String officeId, String newName) async {
  await SupabaseService.client
      .from('offices')
      .update({'name': newName})
      .eq('id', officeId);
}

// Add new office
Future<void> addOffice(String name, String buildingCode) async {
  await SupabaseService.client
      .from('offices')
      .insert({'name': name, 'building_code': buildingCode});
}

// Delete office
Future<void> deleteOffice(String officeId) async {
  await SupabaseService.client
      .from('offices')
      .delete()
      .eq('id', officeId);
}
}