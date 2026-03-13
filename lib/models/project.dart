class Project {
  final String id;
  final String userId; // L'ID de l'utilisateur à qui appartient le projet
  final String name;
  final String description;
  final String color; // On stocke la couleur sous forme de String (ex: "#FF5733")
  final DateTime createdAt;

  Project({ //contructeur
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();


  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Sérialisation : vers Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Désérialisation : depuis Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name, userId: $userId)';
}