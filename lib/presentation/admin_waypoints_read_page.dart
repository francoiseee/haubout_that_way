import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';

class AdminWaypointsReadPage extends StatefulWidget {
	final Map<String, LatLng> waypoints;

	const AdminWaypointsReadPage({super.key, required this.waypoints});

	@override
	State<AdminWaypointsReadPage> createState() => _AdminWaypointsReadPageState();
}

class _AdminWaypointsReadPageState extends State<AdminWaypointsReadPage> {
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
