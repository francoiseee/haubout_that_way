// presentation/building_list_page.dart
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/presentation/building_detail_page.dart';



class BuildingDetailPage extends StatefulWidget {
  final String buildingName;
  final bool isAdmin;
  
  const BuildingDetailPage({
    super.key, 
    required this.buildingName,
    this.isAdmin = false
  });

  @override
  State<BuildingDetailPage> createState() => _BuildingDetailPageState();
}

class _BuildingDetailPageState extends State<BuildingDetailPage> {
  bool _editMode = false;
  final TextEditingController _infoController = TextEditingController();
  final List<String> _offices = [
    'School of Education (SED) Dean\'s Office (Room #)',
    'School of Arts and Sciences (SAS) Dean\'s Office (Room #)',
    'School of Computing (SOC) Dean\'s Office (Room #)',
  ];
  final List<String> _academicHalls = [
    'Room 101',
    'Room 102',
    'Room 103',
    'Room 104',
    'Room 105',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial building information
    _infoController.text = 
      'NYENYENYENYENYENYENYENYENYENYEN '
      'YENYENYENYENYENYENYENYENYENYENYE '
      'NYENYENYENYENYENYENYENYENYENYEN '
      'NYENYENYENYENYENYENYENYENYENYEN '
      'YENYENYENYENYENYENYENYENYENYENYE '
      'NYENYENYENYENYENYENYENYENYENYEN';
  }

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
        actions: widget.isAdmin ? [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                setState(() {
                  _editMode = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _editMode = false;
                });
              },
            ),
        ] : null,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search office...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          
          // Building name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.buildingName,
              style: TextStyle(
                color: AppTheme.primaryYellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Building content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information title
                    const Text(
                      'Information about the building',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Building information (editable for admin)
                    _editMode && widget.isAdmin
                        ? TextField(
                            controller: _infoController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter building information',
                            ),
                          )
                        : Text(
                            _infoController.text,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.justify,
                          ),
                    
                    const SizedBox(height: 20),
                    
                    // Offices section
                    Row(
                      children: [
                        const Text(
                          'Offices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_editMode && widget.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              // Add new office
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Offices list
                    ..._offices.map((office) => ListTile(
                      leading: const Icon(Icons.room, color: Colors.black),
                      title: Text(office),
                      trailing: (_editMode && widget.isAdmin) 
                          ? const Icon(Icons.edit) 
                          : null,
                    )).toList(),
                    
                    const Divider(height: 30),
                    
                    // Academic Hall section
                    Row(
                      children: [
                        const Text(
                          'Academic Hall',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_editMode && widget.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              // Add new classroom
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Classrooms list
                    ..._academicHalls.map((hall) => ListTile(
                      leading: const Icon(Icons.class_, color: Colors.black),
                      title: Text(hall),
                      trailing: (_editMode && widget.isAdmin) 
                          ? const Icon(Icons.edit) 
                          : null,
                    )).toList(),
                  ],
                ),
              ),
            ),
          ),
          
          // SAVE button (only in edit mode and for admin)
          if (_editMode && widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _editMode = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Changes saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Navigation button (for both admin and visitor)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle navigation to this building
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'NAVIGATE TO THIS BUILDING',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }
}