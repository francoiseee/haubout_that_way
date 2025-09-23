// presentation/building_detail_page.dart (UPDATED - COMBINED)
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';


class BuildingDetailPage extends StatefulWidget {
  final String buildingName;
  final List<String> buildingOffices;
  final bool isAdmin;
  
  const BuildingDetailPage({
    super.key, 
    required this.buildingName,
    this.buildingOffices = const [],
    this.isAdmin = false
  });

  @override
  State<BuildingDetailPage> createState() => _BuildingDetailPageState();
}

class _BuildingDetailPageState extends State<BuildingDetailPage> {
  bool _editMode = false;
  final TextEditingController _infoController = TextEditingController();
  late List<String> _offices;
  final List<String> _academicHalls = [
    'Room 101', 'Room 102', 'Room 103', 'Room 104', 'Room 105',
    'Room 201', 'Room 202', 'Room 203', 'Room 204', 'Room 205',
  ];

  @override
  void initState() {
    super.initState();
    _offices = List.from(widget.buildingOffices);
    // Set initial building information
    _infoController.text = _getBuildingDescription(widget.buildingName);
  }

  String _getBuildingDescription(String buildingName) {
    // Add actual building descriptions here based on your data
    switch (buildingName) {
      case 'St. Joseph Hall Building (SJH)':
        return 'Main academic building housing multiple dean offices and classrooms. Central location for student activities.';
      case 'Mamerto G. Nepomuceno Building (MGN / Main Bldg.)':
        return 'Administrative center containing Registrar\'s Office, Finance Office, and CCS Office.';
      case 'San Francisco De Javier Building (SFJ)':
        return 'Houses the President\'s Office, University Library, and University Theater.';
      case 'Plaza De Corazon Building (Red Bldg.)':
        return 'Contains Human Resource Development Office and dormitory facilities.';
      default:
        return 'This building is part of Holy Angel University campus. It serves various academic and administrative functions for students and faculty.';
    }
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
                hintText: 'Search office or room...',
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
              textAlign: TextAlign.center,
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
                      'Building Information',
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
                            maxLines: 4,
                            decoration: const InputDecoration(
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
                    if (_offices.isNotEmpty) ...[
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
                              onPressed: _addNewOffice,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Offices list
                      ..._offices.asMap().entries.map((entry) => ListTile(
                        leading: const Icon(Icons.room, color: Colors.black),
                        title: _editMode && widget.isAdmin
                            ? TextField(
                                controller: TextEditingController(text: entry.value),
                                onChanged: (value) {
                                  _offices[entry.key] = value;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : Text(entry.value),
                        trailing: (_editMode && widget.isAdmin) 
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeOffice(entry.key),
                              )
                            : null,
                      )).toList(),
                      
                      const Divider(height: 30),
                    ],
                    
                    // Academic Hall section
                    Row(
                      children: [
                        const Text(
                          'Classrooms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_editMode && widget.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: _addNewClassroom,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Classrooms list
                    ..._academicHalls.asMap().entries.map((entry) => ListTile(
                      leading: const Icon(Icons.class_, color: Colors.black),
                      title: _editMode && widget.isAdmin
                          ? TextField(
                              controller: TextEditingController(text: entry.value),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            )
                          : Text(entry.value),
                      trailing: (_editMode && widget.isAdmin) 
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeClassroom(entry.key),
                            )
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
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'SAVE CHANGES',
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

  void _addNewOffice() {
    setState(() {
      _offices.add('New Office');
    });
  }

  void _removeOffice(int index) {
    setState(() {
      _offices.removeAt(index);
    });
  }

  void _addNewClassroom() {
    setState(() {
      _academicHalls.add('Room ${_academicHalls.length + 101}');
    });
  }

  void _removeClassroom(int index) {
    setState(() {
      _academicHalls.removeAt(index);
    });
  }

  void _saveChanges() {
    setState(() {
      _editMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully')),
    );
  }

  @override
  void dispose() {
    _infoController.dispose();
    super.dispose();
  }
}