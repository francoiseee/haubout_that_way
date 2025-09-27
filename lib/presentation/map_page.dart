// presentation/map_page.dart (UPDATED WITH DRAGGABLE LIST)
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/presentation/building_detail_page.dart';
import 'package:hau_navigation_app/widgets/hau_logo.dart';



class MapPage extends StatefulWidget {
  final bool isAdmin;
  
  const MapPage({super.key, this.isAdmin = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Map<String, dynamic>> _buildings = [
    {
      'name': 'Plaza De Corazon Building (Red Bldg.)',
      'offices': ['Human Resource Development Office', 'Dormitory'],
    },
    {
      'name': 'St. Martha Hall Building',
      'offices': ['Admissions Office & Testing Center', 'Dormitory'],
    },
    {
      'name': 'San Francisco De Javier Building (SFJ)',
      'offices': ['President\'s Office', 'University Library', 'University Theater'],
    },
    {
      'name': 'St. Therese of Liseux Building (STL)',
      'offices': ['School of Hospitality and Tourism Management Dean\'s Office'],
    },
    {
      'name': 'Warehouse & Carpentry',
      'offices': [],
    },
    {
      'name': 'St. Gabriel Hall Building (SGH)',
      'offices': [],
    },
    {
      'name': 'St. Raphael Hall Building (SRH)',
      'offices': [],
    },
    {
      'name': 'St. Michael Hall Building (SMH)',
      'offices': [],
    },
    {
      'name': 'Geromin G. Nepomuceno Building (GGN)',
      'offices': ['Principal\'s Office / Faculty Room', 'High School Library'],
    },
    {
      'name': 'Peter G. Nepomuceno Building (PGN)',
      'offices': [
        'OSSA - Scholarship & Grants Office',
        'School of Business and Accountancy Dean\'s Office',
        'PGN Auditorium'
      ],
    },
    {
      'name': 'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)',
      'offices': ['Registrar\'s Office', 'Finance Office', 'CCS Office'],
    },
    {
      'name': 'Archbishop Pedro Santos Building (APS)',
      'offices': [],
    },
    {
      'name': 'Mamerto G. Nepomuceno Building (MGN)',
      'offices': [
        'School of Nursing & Applied Medical Sciences Dean\'s Office',
        'College of Criminal Justice Education & Forensics Dean\'s Office'
      ],
    },
    {
      'name': 'Chapel of the Holy Guardian Angel',
      'offices': [],
    },
    {
      'name': 'Sister Josefina Nepomuceno Formation Center',
      'offices': [],
    },
    {
      'name': 'St. Joseph Hall Building (SJH)',
      'offices': [
        'School of Education Dean\'s Office',
        'School of Arts and Sciences Dean\'s Office',
        'School of Computing Dean\'s Office',
        'Academic Hall'
      ],
    },
    {
      'name': 'Sacred Heart Building (SH)',
      'offices': ['School of Engineering & Architecture Dean\'s Office'],
    },
    {
      'name': 'Covered Court',
      'offices': ['Immaculate Heart Gymnasium'],
    },
    {
      'name': 'Immaculate Heart Gymnasium',
      'offices': [],
    },
    {
      'name': 'Immaculate Heart Gymnasium Annex',
      'offices': [],
    },
    {
      'name': 'Yellow Food Court',
      'offices': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      appBar: AppBar(
       title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            HauLogoWidget(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 10),
            Text(
              'HAUbout That Way',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                
                // Building markers (clickable) - Adding key buildings from the image
                Positioned(
                  top: 100,
                  left: 100,
                  child: _buildMapMarker(context, 'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)'),
                ),
                Positioned(
                  top: 150,
                  left: 180,
                  child: _buildMapMarker(context, 'St. Joseph Hall Building (SJH)'),
                ),
                Positioned(
                  top: 220,
                  left: 80,
                  child: _buildMapMarker(context, 'San Francisco De Javier Building (SFJ)'),
                ),
                Positioned(
                  bottom: 120,
                  right: 100,
                  child: _buildMapMarker(context, 'Covered Court'),
                ),
                Positioned(
                  bottom: 180,
                  left: 150,
                  child: _buildMapMarker(context, 'Plaza De Corazon Building (Red Bldg.)'),
                ),
                Positioned(
                  top: 180,
                  right: 80,
                  child: _buildMapMarker(context, 'Sacred Heart Building (SH)'),
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
                        'HAU Buildings (${_buildings.length} buildings)',
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
                          final building = _buildings[index];
                          final hasOffices = (building['offices'] as List).isNotEmpty;
                          
                          return ListTile(
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              building['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: hasOffices 
                                ? Text(
                                    '${(building['offices'] as List).length} office${(building['offices'] as List).length > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuildingDetailPage(
                                    buildingName: building['name'] as String,
                                    buildingOffices: List<String>.from(building['offices'] as List),
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
        // Find the building data
        final building = _buildings.firstWhere(
          (b) => b['name'] == buildingName,
          orElse: () => {'name': buildingName, 'offices': []},
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuildingDetailPage(
              buildingName: buildingName,
              buildingOffices: List<String>.from(building['offices'] as List),
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
              _getAbbreviatedName(buildingName),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getAbbreviatedName(String fullName) {
    // Return abbreviated names for map markers
    if (fullName.contains('Don Juan D. Nepomuceno')) return 'Main Bldg.';
    if (fullName.contains('St. Joseph Hall')) return 'SJH';
    if (fullName.contains('San Francisco De Javier')) return 'SFJ';
    if (fullName.contains('Plaza De Corazon')) return 'Red Bldg.';
    if (fullName.contains('Sacred Heart')) return 'SH';
    if (fullName.contains('Covered Court')) return 'Court';
    
    // Return first 2 words for other buildings
    final words = fullName.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}' : fullName;
  }
}