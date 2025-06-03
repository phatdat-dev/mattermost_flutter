/// Emoji model
class MEmoji {
  final String id;
  final String name;
  final String creator;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MEmoji({
    required this.id,
    required this.name,
    required this.creator,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory MEmoji.fromJson(Map<String, dynamic> json) {
    return MEmoji(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      creator: json['creator_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creator_id': creator,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}
