class Waypoint {
  final String waypointKey;
  final double latitude;
  final double longitude;

  Waypoint({
    required this.waypointKey,
    required this.latitude,
    required this.longitude,
  });

  factory Waypoint.fromMap(Map<String, dynamic> map) {
    return Waypoint(
      waypointKey: map['waypoint_key'],
      latitude: map['latitude'] is double ? map['latitude'] : double.parse(map['latitude'].toString()),
      longitude: map['longitude'] is double ? map['longitude'] : double.parse(map['longitude'].toString()),
    );
  }
}