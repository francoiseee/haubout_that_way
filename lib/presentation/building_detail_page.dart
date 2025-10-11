import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';
import 'package:hau_navigation_app/widgets/custom_app_bar.dart';




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
  final TextEditingController _searchController = TextEditingController();
  late List<String> _offices;
  final List<String> _classrooms = [
    'Room 101', 'Room 102', 'Room 103', 'Room 104', 'Room 105',
    'Room 201', 'Room 202', 'Room 203', 'Room 204', 'Room 205',
    'Room 301', 'Room 302', 'Room 303', 'Room 304', 'Room 305',
  ];

  // List of buildings that DON'T have classrooms
  final List<String> _nonAcademicBuildings = [
    'Plaza De Corazon Building (Red Bldg.)',  // Building 1
    'St. Martha Hall Building',               // Building 2
    'San Francisco De Javier Building (SFJ)', // Building 3
    'Warehouse & Carpentry',                  // Building 5
    'St. Gabriel Hall Building (SGH)',        // Building 6
    'Chapel of the Holy Guardian Angel',      // Building 15
    'Immaculate Heart Gymnasium',             // Building 19
    'Immaculate Heart Gymnasium Annex',       // Building 20
    'Yellow Food Court',
    ' Entrance'
  ];

  @override
  void initState() {
    super.initState();
    _offices = List.from(widget.buildingOffices);
    _infoController.text = _getBuildingDescription(widget.buildingName);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  bool get _hasClassrooms => !_nonAcademicBuildings.contains(widget.buildingName);

  String _getBuildingDescription(String buildingName) {
    switch (buildingName) {
      case ' Entrance':
        return 'Main entrance gate of Holy Angel University. First point of contact for visitors with security checkpoint and information services.';
      
      case 'St. Joseph Hall Building (SJH)':
        return 'Main academic building housing School of Education, Arts and Sciences, and Computing Dean\'s Offices. Contains the Academic Hall.';
      
      case 'Don Juan D. Nepomuceno Building (DJDN / Main Bldg.)':
        return 'Administrative center containing Registrar\'s Office, Finance Office, and CCS Office. Main building of the university.';
      
      case 'San Francisco De Javier Building (SFJ)':
        return 'Houses the President\'s Office, University Library, and University Theater. Central administrative building.';
      
      case 'Plaza De Corazon Building (Red Bldg.)':
        return 'Contains Human Resource Development Office and dormitory facilities. Recognizable red building.';
      
      case 'Sacred Heart Building (SH)':
        return 'Home to the School of Engineering & Architecture Dean\'s Office. Engineering and architecture classrooms.';
      
      case 'Peter G. Nepomuceno Building (PGN)':
        return 'Contains OSSA - Scholarship & Grants Office, School of Business and Accountancy Dean\'s Office, and PGN Auditorium.';
      
      case 'Mamerto G. Nepomuceno Building (MGN)':
        return 'Houses School of Nursing & Applied Medical Sciences and College of Criminal Justice Education & Forensics Dean\'s Offices.';
      
      case 'Geromin G. Nepomuceno Building (GGN)':
        return 'Contains Principal\'s Office / Faculty Room and High School Library. High school academic building.';
      
      case 'St. Martha Hall Building':
        return 'Admissions Office & Testing Center with dormitory facilities. Student services building.';
      
      case 'St. Therese of Liseux Building (STL)':
        return 'Home to School of Hospitality and Tourism Management Dean\'s Office. Hospitality and tourism classrooms.';
      
      case 'Covered Court':
        return 'Multi-purpose covered court used for sports events, gatherings, and Immaculate Heart Gymnasium activities.';
      
      case 'Warehouse & Carpentry':
        return 'Storage and maintenance facility containing the Yellow Food Court.';
      
      case 'St. Gabriel Hall Building (SGH)':
        return 'Dormitory building for university students.';
      
      case 'Chapel of the Holy Guardian Angel':
        return 'University chapel for religious services and spiritual activities.';
      
      case 'Immaculate Heart Gymnasium':
        return 'Main gymnasium for sports events and physical education activities.';
      
      case 'Immaculate Heart Gymnasium Annex':
        return 'Annex building supporting gymnasium activities.';
      
      case 'Yellow Food Court':
        return 'University 1st Canteen.';

      default:
        return 'This building is part of Holy Angel University campus. It serves various academic and administrative functions for students and faculty.';
    }
  }

  String _photoFor(String name) {
    final key = name.trim().toLowerCase();
    const map = {
      'entrance': 'assets/building_actualpic/entrance.jpg',
      'st. joseph hall building (sjh)': 'assets/building_actualpic/sjh.jpg',
      'don juan d. nepomuceno building (djdn / main bldg.)': 'assets/building_actualpic/djdn.jpg',
      'san francisco de javier building (sfj)': 'assets/building_actualpic/sfj.jpg',
      'plaza de corazon building (red bldg.)': 'assets/building_actualpic/red.jpg',
      'sacred heart building (sh)': 'assets/building_actualpic/sh.png',
      'peter g. nepomuceno building (pgn)': 'assets/building_actualpic/pgn.jpg',
      'mamerto g. nepomuceno building (mgn)': 'assets/building_actualpic/mgn.png',
      'geromin g. nepomuceno building (ggn)': 'assets/building_actualpic/ggn.png',
      'st. martha hall building': 'assets/building_actualpic/st_martha.jpg',
      'st. therese of liseux building (stl)': 'assets/building_actualpic/stl.jpg',
      'covered court': 'assets/building_actualpic/covered_court.jpg',
      'warehouse & carpentry': 'assets/building_actualpic/warehouse.jpg',
      'st. gabriel hall building (sgh)': 'assets/building_actualpic/sgh.jpg',
      'chapel of the holy guardian angel': 'assets/building_actualpic/chapel.jpg',
      'immaculate heart gymnasium': 'assets/building_actualpic/gym.png',
      'immaculate heart gymnasium annex': 'assets/building_actualpic/gym_annex.jpg',
      'yellow food court': 'assets/building_actualpic/yellow_food_court.jpg',
    };
    return map[key] ?? 'assets/building_actualpic/main-entrance.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      appBar: CustomAppBar(
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
                  // Reset to original data when canceling edit
                  _offices = List.from(widget.buildingOffices);
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search office or room...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (val) => setState(() {}),
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
                            style: const TextStyle(color: Colors.black),
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
                    
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          _photoFor(widget.buildingName),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: const Color(0xFFEFEFEF),
                            alignment: Alignment.center,
                            child: const Text(
                              'Photo not available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Actual Building – ${widget.buildingName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Offices section (only show if building has offices)
                    if (_offices.isNotEmpty) ..._buildOfficesSection(),
                    
                    // Classrooms section (only show for academic buildings)
                    if (_hasClassrooms) ..._buildClassroomsSection(),
                    
                    // Special message for non-academic buildings
                    if (!_hasClassrooms && _offices.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            'This building does not contain offices or classrooms.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action buttons
          ..._buildActionButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildOfficesSection() {
    final query = _searchController.text.toLowerCase().trim();
    final filteredOffices = query.isEmpty
        ? _offices
        : _offices.where((o) => o.toLowerCase().contains(query)).toList();

    return [
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
      if (filteredOffices.isEmpty && query.isNotEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text('No matching offices', style: TextStyle(color: Colors.grey)),
        ),
      ...filteredOffices.asMap().entries.map((entry) => ListTile(
        leading: const Icon(Icons.room, color: Colors.black),
        title: _editMode && widget.isAdmin
            ? TextField(
                controller: TextEditingController(text: entry.value),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    // update the index in the original _offices list
                    final originalIndex = _offices.indexWhere((o) => o == entry.value);
                    if (originalIndex != -1) _offices[originalIndex] = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Office name',
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
      
      if (_hasClassrooms) const Divider(height: 30),
    ];
  }

  List<Widget> _buildClassroomsSection() {
    final query = _searchController.text.toLowerCase().trim();
    final filteredClassrooms = query.isEmpty
        ? _classrooms
        : _classrooms.where((c) => c.toLowerCase().contains(query)).toList();

    return [
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
      if (filteredClassrooms.isEmpty && query.isNotEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text('No matching classrooms', style: TextStyle(color: Colors.grey)),
        ),
      ...filteredClassrooms.asMap().entries.map((entry) => ListTile(
        leading: const Icon(Icons.class_, color: Colors.black),
        title: _editMode && widget.isAdmin
            ? TextField(
                controller: TextEditingController(text: entry.value),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    // update the index in the original _classrooms list
                    final originalIndex = _classrooms.indexWhere((c) => c == entry.value);
                    if (originalIndex != -1) _classrooms[originalIndex] = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Classroom name',
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
    ];
  }

  List<Widget> _buildActionButtons() {
    final buttons = <Widget>[];
    
    if (_editMode && widget.isAdmin) {
      // Show Save Changes button when in edit mode
      buttons.add(
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
      );
    } else {
      // Show Navigate button when NOT in edit mode
      buttons.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Handle navigation to this building - directly start navigation
              Navigator.pop(context, widget.buildingName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'NAVIGATE TO THIS BUILDING',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    
    return buttons;
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
      _classrooms.add('Room ${_classrooms.length + 101}');
    });
  }

  void _removeClassroom(int index) {
    setState(() {
      _classrooms.removeAt(index);
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
    _searchController.dispose();
    super.dispose();
  }
}