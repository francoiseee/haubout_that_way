// presentation/map_page.dart (UPDATED WITH DRAGGABLE LIST)
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/building_detail_page.dart';

class MapPage extends StatefulWidget {
  final bool isAdmin;
  
  const MapPage({super.key, this.isAdmin = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<String> _buildings = [
    'Holy Angel University Main Bldg.',
    'Center for Kapampangan Studies Museum',
    'St. Joseph Hall',
    'Covered Court',
    'Mamerto G. Nepomuceno Building (MGN)',
    'Geromin G. Nepomuceno Building (GGN)',
    'Sacred Heart Building (SH)',
    'Peter G. Nepomuceno Building (PGN)',
    'Plaza De Corazon Building (Red Bldg.)',
    'St. Martha Hall Building',
    'St. Therese of Liseux Building (STL)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      appBar: AppBar(
        title: Text(
          'HAUbout That Way',
          style: TextStyle(
            color: AppTheme.primaryYellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Map view (full screen)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Map background (placeholder)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'HAU Campus Map',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search bar (positioned at top of map)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search building...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                
                // Building markers (clickable)
                Positioned(
                  top: 100,
                  left: 100,
                  child: _buildMapMarker(context, 'HAU Main Bldg.'),
                ),
                Positioned(
                  top: 150,
                  left: 180,
                  child: _buildMapMarker(context, 'CKS Museum'),
                ),
                Positioned(
                  top: 220,
                  left: 80,
                  child: _buildMapMarker(context, 'St. Joseph Hall'),
                ),
                Positioned(
                  bottom: 120,
                  right: 100,
                  child: _buildMapMarker(context, 'Covered Court'),
                ),
                
              ],
            ),
          ),
          
          // Draggable buildings list
          DraggableScrollableSheet(
            initialChildSize: 0.15, // Initial height (15% of screen)
            minChildSize: 0.15,     // Minimum height (15% of screen)
            maxChildSize: 0.7,      // Maximum height (70% of screen)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 60,
                      height: 5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    // List header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Buildings List',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Divider
                    const Divider(height: 1, thickness: 1),
                    
                    // Buildings list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _buildings.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_buildings[index]),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuildingDetailPage(
                                    buildingName: _buildings[index],
                                    isAdmin: widget.isAdmin,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapMarker(BuildContext context, String buildingName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuildingDetailPage(
              buildingName: buildingName,
              isAdmin: widget.isAdmin,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              buildingName,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}