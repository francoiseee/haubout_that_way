class Edge {
  final String fromWaypoint;
  final String toWaypoint;
  final double distanceMeters;

  Edge({
    required this.fromWaypoint,
    required this.toWaypoint,
    required this.distanceMeters,
  });

  factory Edge.fromMap(Map<String, dynamic> map) {
    return Edge(
      fromWaypoint: map['from_waypoint'],
      toWaypoint: map['to_waypoint'],
      distanceMeters: map['distance_meters'] is double
        ? map['distance_meters']
        : double.parse(map['distance_meters'].toString()),
    );
  }
}