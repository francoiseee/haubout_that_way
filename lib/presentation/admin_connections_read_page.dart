// Keep a compatibility export pointing to the new UpdatePage filename so older imports keep working.
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/models/edge.dart';

class AdminConnectionsReadPage extends StatefulWidget {
	final List<Edge> connections;

	const AdminConnectionsReadPage({super.key, required this.connections});

	@override
	State<AdminConnectionsReadPage> createState() => _AdminConnectionsReadPageState();
}

class _AdminConnectionsReadPageState extends State<AdminConnectionsReadPage> {
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
