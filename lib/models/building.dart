class Building {
  final String buildingId;
  final String buildingCode;
  final String name;
  final String description;

  Building({
    required this.buildingId,
    required this.buildingCode,
    required this.name,
    required this.description,
  });

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      buildingId: map['building_id'],
      buildingCode: map['building_code'],
      name: map['name'],
      description: map['description'],
    );
  }
}