/// Permission model
class MPermission {
  final String id;
  final String name;
  final String description;
  final List<String>? dependencies;

  MPermission({required this.id, required this.name, required this.description, this.dependencies});

  factory MPermission.fromJson(Map<String, dynamic> json) {
    return MPermission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dependencies: json['dependencies'] != null ? (json['dependencies'] as List).cast<String>() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, if (dependencies != null) 'dependencies': dependencies};
  }
}
