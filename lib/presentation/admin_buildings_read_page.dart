import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/building_detail_page.dart';

class AdminBuildingsReadPage extends StatefulWidget {
	final List<Map<String, dynamic>> buildings;
	final bool isAdmin;

	const AdminBuildingsReadPage({super.key, required this.buildings, this.isAdmin = false});

	@override
	State<AdminBuildingsReadPage> createState() => _AdminBuildingsReadPageState();
}

class _AdminBuildingsReadPageState extends State<AdminBuildingsReadPage> {
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

											return Card(
												child: ListTile(
													title: Text(name),
													subtitle: (building['offices'] as List).isNotEmpty
															? Text('${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}')
															: null,
													onTap: () async {
														await Navigator.push(
															context,
															MaterialPageRoute(
																builder: (context) => BuildingDetailPage(
																	buildingName: name,
																	buildingOffices: List<String>.from(building['offices'] as List),
																	isAdmin: widget.isAdmin,
																),
															),
														);
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
