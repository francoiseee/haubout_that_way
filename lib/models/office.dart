class Office {
  final String id;
  final String name;
  final String buildingCode;

  Office({
    required this.id,
    required this.name,
    required this.buildingCode,
  });

  factory Office.fromMap(Map<String, dynamic> map) {
    return Office(
      id: map['id'],
      name: map['name'],
      buildingCode: map['building_code'],
    );
  }
}