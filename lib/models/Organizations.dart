class Organizations {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int userId;
  final String instanceType;

  Organizations({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.instanceType,
  });

  factory Organizations.fromMap(Map<String, dynamic> map) {
    return Organizations(
      id: map['id'] as int,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      userId: map['user_id'] as int,
      instanceType: map['instance_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'instance_type': instanceType,
    };
  }
}
