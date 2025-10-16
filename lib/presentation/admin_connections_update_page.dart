import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/models/edge.dart';
import 'package:hau_navigation_app/supabase_services/edge_service.dart';
import 'package:hau_navigation_app/supabase_services/waypoint_service.dart';

Future<String?> _showSearchableChooser(BuildContext context, String initial) async {
  final TextEditingController _search = TextEditingController();

  // Fetch current waypoint keys from the database each time the chooser opens
  final wps = await WaypointService().fetchWaypoints();
  final List<String> options = wps.map((w) => w.waypointKey).toList()..sort();
  List<String> filtered = List.from(options);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Select waypoint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _search,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search...'),
                onChanged: (v) {
                  final q = v.toLowerCase();
                  setState(() {
                    filtered = options.where((o) => o.toLowerCase().contains(q)).toList();
                  });
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.maxFinite,
                height: 240,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: ListTile(
                      title: Text(filtered[i]),
                      onTap: () => Navigator.pop(context, filtered[i]),
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('CANCEL'))],
        );
      });
    },
  );
}

class AdminConnectionsUpdatePage extends StatefulWidget {
  final List<Edge> connections;

  const AdminConnectionsUpdatePage({super.key, required this.connections});

  @override
  State<AdminConnectionsUpdatePage> createState() => _AdminConnectionsUpdatePageState();
}

class _AdminConnectionsUpdatePageState extends State<AdminConnectionsUpdatePage> {
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
  
  // waypoint keys are fetched dynamically by the chooser dialog

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.connections
        : widget.connections.where((c) => c.fromWaypoint.toLowerCase().contains(_query.toLowerCase()) || c.toWaypoint.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
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
                hintText: 'Search connection by waypoint key...',
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
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.search_off, size: 64, color: Colors.grey[400]), const SizedBox(height: 12), Text('No connections found', style: TextStyle(color: Colors.grey[600], fontSize: 16))]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Card(
                        child: ListTile(
                          title: Text('${c.fromWaypoint} → ${c.toWaypoint}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              // Open an edit dialog with searchable dropdowns for from/to
                              String fromSel = c.fromWaypoint;
                              String toSel = c.toWaypoint;

                              final res = await showDialog<bool>(
                                context: context,
                                builder: (context) => StatefulBuilder(builder: (context, setState) {
                                  String validationError = '';

                                  Widget buildPickerRow({required String label, required String value, required VoidCallback onTap, required IconData icon}) {
                                    return InkWell(
                                      onTap: onTap,
                                      child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(icon, color: Colors.grey[700]),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                                  const SizedBox(height: 2),
                                                  Text(value, style: const TextStyle(color: Colors.black, fontSize: 14), overflow: TextOverflow.ellipsis),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  final List<Widget> contentChildren = [
                                    buildPickerRow(
                                      label: 'From',
                                      value: fromSel,
                                      icon: Icons.travel_explore,
                                      onTap: () async {
                                        final pick = await _showSearchableChooser(context, fromSel);
                                        if (pick != null) setState(() => fromSel = pick);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    buildPickerRow(
                                      label: 'To',
                                      value: toSel,
                                      icon: Icons.place,
                                      onTap: () async {
                                        final pick = await _showSearchableChooser(context, toSel);
                                        if (pick != null) setState(() => toSel = pick);
                                      },
                                    ),
                                  ];

                                  if (validationError.isNotEmpty) {
                                    contentChildren.addAll([
                                      const SizedBox(height: 12),
                                      Text(validationError, style: const TextStyle(color: Colors.red)),
                                    ]);
                                  }

                                  return AlertDialog(
                                    title: const Text('Edit connection'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: contentChildren,
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                      ElevatedButton(onPressed: () async {
                                        // Local validation
                                        if (fromSel == toSel) {
                                          setState(() => validationError = 'From and To cannot be the same waypoint');
                                          return;
                                        }

                                        if (fromSel == c.fromWaypoint && toSel == c.toWaypoint) {
                                          Navigator.pop(context, false);
                                          return;
                                        }

                                        // Confirm before saving
                                        final confirm = await showDialog<bool>(context: context, builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Confirm change'),
                                            content: Text('Change connection from "${c.fromWaypoint} → ${c.toWaypoint}" to "${fromSel} → ${toSel}"?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('YES')),
                                            ],
                                          );
                                        });

                                        if (confirm != true) return;

                                        final ok = await EdgeService().updateEdgeEndpoints(
                                          originalFrom: c.fromWaypoint,
                                          originalTo: c.toWaypoint,
                                          newFrom: fromSel,
                                          newTo: toSel,
                                        );
                                        if (ok) Navigator.pop(context, true);
                                        else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update connection')));
                                      }, child: const Text('SAVE')),
                                    ],
                                  );
                                }),
                              );

                              if (res == true) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection updated')));
                                Navigator.pop(context, true);
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
