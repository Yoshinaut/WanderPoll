class Location {
  final int? id;
  final String name;
  final String address;
  final String description;
  final String? imagePath;

  Location({
    this.id,
    required this.name,
    required this.address,
    required this.description,
    this.imagePath,
  });

  // Fixed: Changed 'Image' to 'imagePath' to precisely match your database schema
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'imagePath': imagePath, 
    };
  }

  // Fixed: Standardized the factory reading keys to match 'imagePath'
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
    );
  }
}
