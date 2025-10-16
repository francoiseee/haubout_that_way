import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/building_detail_page.dart';

class AdminBuildingsUpdatePage extends StatefulWidget {
  final List<Map<String, dynamic>> buildings;
  final bool isAdmin;

  const AdminBuildingsUpdatePage({super.key, required this.buildings, this.isAdmin = false});

  @override
  State<AdminBuildingsUpdatePage> createState() => _AdminBuildingsUpdatePageState();
}

class _AdminBuildingsUpdatePageState extends State<AdminBuildingsUpdatePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_query != _searchController.text) {
        setState(() {
          _query = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Canonical building order matching MapPage's buildingLocations
    final List<String> canonicalOrder = [
      'Entrance',
      'Plaza De Corazon Building (Red Bldg.)',
      'St. Martha Hall Building',
      'San Francisco De Javier Building (SFJ)',
      'St. Therese of Liseux Building (STL)',
      'Warehouse & Carpentry',
      'Yellow Food Court',
      'St. Gabriel Hall Building (SGH)',
      'St. Raphael Hall Building (SRH)',
      'St. Michael Hall Building (SMH)',
      'Geromin G. Nepomuceno Building (GGN)',
      'Peter G. Nepomuceno Building (PGN)',
      'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)',
      'Archbishop Pedro Santos Building (APS)',
      'Mamerto G. Nepomuceno Building (MGN)',
      'Chapel of the Holy Guardian Angel',
      'Sister Josefina Nepomuceno Formation Center',
      'St. Joseph Hall Building (SJH)',
      'Sacred Heart Building (SH)',
      'Covered Court',
      'Immaculate Heart Gymnasium',
      'Immaculate Heart Gymnasium Annex',
    ];

    // Filter first, then sort by canonicalOrder if possible
    final filtered = _query.isEmpty
        ? List<Map<String, dynamic>>.from(widget.buildings)
        : widget.buildings
            .where((b) => (b['name'] as String).toLowerCase().contains(_query.toLowerCase()))
            .toList();

    filtered.sort((a, b) {
      final ai = canonicalOrder.indexOf(a['name'] as String);
      final bi = canonicalOrder.indexOf(b['name'] as String);
      if (ai == -1 && bi == -1) return (a['name'] as String).compareTo(b['name'] as String);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buildings'),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Search building...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No buildings found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final building = filtered[index];
                      final name = building['name'] as String;
                      final canonicalIndex = canonicalOrder.indexOf(name);
                      final displayNumber = canonicalIndex != -1 ? canonicalIndex + 1 : index + 1;

                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '$displayNumber',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: (building['offices'] as List).isNotEmpty
                              ? Text('${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}')
                              : null,
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BuildingDetailPage(
                                  buildingName: name,
                                  buildingOffices: List<String>.from(building['offices'] as List),
                                  isAdmin: widget.isAdmin,
                                ),
                              ),
                            );

                            if (result is String && result.isNotEmpty) {
                              Navigator.pop(context, result);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
