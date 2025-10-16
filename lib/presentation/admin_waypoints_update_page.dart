import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/supabase_services/waypoint_service.dart';

class AdminWaypointsUpdatePage extends StatefulWidget {
  final Map<String, LatLng> waypoints;

  const AdminWaypointsUpdatePage({super.key, required this.waypoints});

  @override
  State<AdminWaypointsUpdatePage> createState() => _AdminWaypointsUpdatePageState();
}

class _AdminWaypointsUpdatePageState extends State<AdminWaypointsUpdatePage> {
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
    // Only include waypoint keys that follow the 'wp_' naming convention
    final entries = widget.waypoints.entries
        .where((e) => e.key.startsWith('wp_'))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final filtered = _query.isEmpty
        ? entries
        : entries.where((e) => e.key.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waypoints'),
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
                hintText: 'Search waypoint... (by key)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
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
                        Text('No waypoints found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  )
        : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final e = filtered[index];
                      final key = e.key;
                      final latlng = e.value;
                      return Card(
                        child: ListTile(
                          title: Text(key),
                          subtitle: Text('Lat: ${latlng.latitude.toStringAsFixed(6)}, Lng: ${latlng.longitude.toStringAsFixed(6)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  // Show an edit dialog
                                  final controllerKey = TextEditingController(text: key);
                                  final controllerLat = TextEditingController(text: latlng.latitude.toString());
                                  final controllerLng = TextEditingController(text: latlng.longitude.toString());

                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit waypoint'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: controllerKey,
                                            style: const TextStyle(color: Colors.black),
                                            decoration: const InputDecoration(labelText: 'Waypoint key'),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: controllerLat,
                                            style: const TextStyle(color: Colors.black),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(labelText: 'Latitude'),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: controllerLng,
                                            style: const TextStyle(color: Colors.black),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(labelText: 'Longitude'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final newKey = controllerKey.text.trim();
                                            final newLat = double.tryParse(controllerLat.text.trim());
                                            final newLng = double.tryParse(controllerLng.text.trim());
                                            if (newKey.isEmpty || newLat == null || newLng == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid input')));
                                              return;
                                            }

                                            final ok = await WaypointService().updateWaypoint(
                                              originalKey: key,
                                              newKey: newKey == key ? null : newKey,
                                              latitude: newLat,
                                              longitude: newLng,
                                            );

                                            if (ok) {
                                              Navigator.pop(context, true);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update waypoint')));
                                            }
                                          },
                                          child: const Text('SAVE'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (result == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Waypoint updated')));
                                    // Signal to caller that a change occurred
                                    Navigator.pop(context, true);
                                  }
                                },
                              ),
                              // copy action removed per request
                            ],
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
