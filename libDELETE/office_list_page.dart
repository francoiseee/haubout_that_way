// presentation/office_list_page.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:hau_navigation_app/core/theme/app_theme.dart';


class OfficeListPage extends StatefulWidget {
  final String buildingName;
  final bool isAdmin;
  
  const OfficeListPage({
    super.key, 
    required this.buildingName,
    this.isAdmin = false
  });

  @override
  State<OfficeListPage> createState() => _OfficeListPageState();
}

class _OfficeListPageState extends State<OfficeListPage> {
  bool _editMode = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryRed,
      appBar: AppBar(
        title: Text(
          'HAUbout That Way',
          style: TextStyle(
            color: Colors.white,
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
          
          // Building title
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
          
          // EDIT button (only in edit mode and for admin)
          if (_editMode && widget.isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('EDIT'),
                ),
              ),
            ),
          
          // Offices list
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView(
                children: [
                  // Offices section
                  const Text(
                    'Offices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._offices.map((office) => ListTile(
                    title: Text(office),
                    trailing: (_editMode && widget.isAdmin) ? const Icon(Icons.edit) : null,
                  )).toList(),
                  
                  const Divider(height: 30),
                  
                  // Academic Hall section
                  const Text(
                    'Academic Hall',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._academicHalls.map((hall) => ListTile(
                    title: Text(hall),
                    trailing: (_editMode && widget.isAdmin) ? const Icon(Icons.edit) : null,
                  )).toList(),
                ],
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
        ],
      ),
    );
  }
}