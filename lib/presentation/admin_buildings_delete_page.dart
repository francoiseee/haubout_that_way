import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';

class AdminBuildingsDeletePage extends StatefulWidget {
  final List<Map<String, dynamic>> buildings;

  const AdminBuildingsDeletePage({super.key, required this.buildings});

  @override
  State<AdminBuildingsDeletePage> createState() => _AdminBuildingsDeletePageState();
}

class _AdminBuildingsDeletePageState extends State<AdminBuildingsDeletePage> {
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
    final filtered = _query.isEmpty
        ? List<Map<String, dynamic>>.from(widget.buildings)
        : widget.buildings
            .where((b) => (b['name'] as String).toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Delete Buildings'), backgroundColor: AppTheme.primaryRed),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Search building to delete... ',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search_off, size: 64, color: Colors.grey[400]), const SizedBox(height: 12), Text('No buildings found', style: TextStyle(color: Colors.grey[600], fontSize: 16))]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final building = filtered[index];
                      final name = building['name'] as String;
                      return Card(
                        child: ListTile(
                          title: Text(name),
                          subtitle: (building['offices'] as List).isNotEmpty
                              ? Text('${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}')
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(context: context, builder: (context) {
                                return AlertDialog(
                                  title: const Text('Confirm delete'),
                                  content: Text('Delete building "$name"? This action cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                    ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('DELETE')),
                                  ],
                                );
                              });

                              if (confirm == true) {
                                // Return the deleted building name to caller
                                Navigator.pop(context, name);
                              }
                            },
                          ),
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
